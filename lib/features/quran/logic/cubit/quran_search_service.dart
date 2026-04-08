part of 'quran_cubit.dart';

// ═══════════════════════════════════════════════════════════════════════════
// _SE — Index Entry (lives entirely inside the search isolate's memory)
// ═══════════════════════════════════════════════════════════════════════════
class _SE {
  final int s, a;
  final String nm; // surah name (Arabic)
  final String t; // original verse text
  final String sd; // pre-stripped diacritics for fast matching
  const _SE(this.s, this.a, this.nm, this.t, this.sd);
}

// ═══════════════════════════════════════════════════════════════════════════
// _QuranSearchService — manages a persistent isolate with a pre-built index
//
// Protocol (main → isolate):  List<dynamic> [requestId, queryString]
// Protocol (isolate → main):  List<dynamic> [requestId, isDone(0|1), s,a,nm,t, ...]
//                              or String 'ready' once index is built
//                              or SendPort on startup
// ═══════════════════════════════════════════════════════════════════════════
class _QuranSearchService {
  Isolate? _isolate;
  SendPort? _toIsolate;
  ReceivePort? _port;

  bool _ready = false;
  int _reqId = 0;

  void Function(List<AyahSearchResult> batch, bool isDone)? _cb;

  bool get isReady => _ready;

  // ── Start & wire up ────────────────────────────────────────────────────
  Future<void> start(
    void Function(List<AyahSearchResult> batch, bool isDone) onResults, {
    RootIsolateToken? token,
  }) async {
    _cb = onResults;
    _port = ReceivePort();
    _isolate = await Isolate.spawn(_entry, [_port!.sendPort, token]);
    _port!.listen(_onMsg);
  }

  // ── Handle messages from isolate ───────────────────────────────────────
  void _onMsg(dynamic msg) {
    if (msg is SendPort) {
      _toIsolate = msg;
    } else if (msg == 'ready') {
      _ready = true;
    } else if (msg is List && msg.length >= 2) {
      final id = msg[0] as int;
      if (id != _reqId) return; // stale response → discard

      final isDone = (msg[1] as int) == 1;
      final results = <AyahSearchResult>[];
      for (int i = 2; i + 3 < msg.length; i += 4) {
        results.add(
          AyahSearchResult(
            surah: msg[i] as int,
            ayah: msg[i + 1] as int,
            surahName: msg[i + 2] as String,
            verseText: msg[i + 3] as String,
          ),
        );
      }
      _cb?.call(results, isDone);
    }
  }

  // ── Send a search query ────────────────────────────────────────────────
  void search(String query) {
    if (!_ready || _toIsolate == null) return;
    _reqId++;
    _toIsolate!.send([_reqId, query]);
  }

  // ── Invalidate current request (responses ignored by id mismatch) ──────
  void cancel() => _reqId++;

  // ── Cleanup ────────────────────────────────────────────────────────────
  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _port?.close();
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ISOLATE ENTRY — runs in its own thread
  // ═══════════════════════════════════════════════════════════════════════
  static void _entry(List<dynamic> args) {
    final out = args[0] as SendPort;
    final token = args[1] as RootIsolateToken?;
    if (token != null)
      BackgroundIsolateBinaryMessenger.ensureInitialized(token);

    final inp = ReceivePort();
    out.send(inp.sendPort); // hand back our receive port

    // ── Build index once ────────────────────────────────────────────────
    // Pre-strips diacritics for all 6236 verses at startup so searches
    // never need to repeat this work.
    final idx = <_SE>[];
    for (int s = 1; s <= 114; s++) {
      final cnt = getVerseCount(s);
      final nm = getSurahNameArabic(s);
      for (int a = 1; a <= cnt; a++) {
        final t = getVerse(s, a);
        idx.add(_SE(s, a, nm, t, _sd(t)));
      }
    }
    out.send('ready'); // signal main isolate

    int latest = 0; // tracks latest requestId for cancellation

    inp.listen((raw) {
      if (raw is! List || raw.length < 2) return;
      final id = raw[0] as int;
      final q = raw[1] as String;
      latest = id;

      // ── Empty / cancel ────────────────────────────────────────────────
      if (q.isEmpty) {
        out.send([id, 1]); // done, no results
        return;
      }

      // ── Reference lookup: "2:255" or "2-255" ─────────────────────────
      final rm = RegExp(r'^(\d+)[:\-](\d+)$').firstMatch(q);
      if (rm != null) {
        final s_raw = int.tryParse(rm.group(1)!);
        final a_raw = int.tryParse(rm.group(2)!);
        final resp = <dynamic>[id, 1]; // always done in one shot
        if (s_raw != null && a_raw != null && s_raw >= 1 && s_raw <= 114) {
          final cnt = getVerseCount(s_raw);
          if (a_raw >= 1 && a_raw <= cnt) {
            // O(1) lookup: compute offset into flat index
            int off = 0;
            for (int x = 1; x < s_raw; x++) off += getVerseCount(x);
            final e = idx[off + a_raw - 1];
            resp.addAll([e.s, e.a, e.nm, e.t]);
          }
        }
        out.send(resp);
        return;
      }

      // ── Full-text search (the hot path) ───────────────────────────────
      final qs = _sd(q);
      if (qs.length < 2) {
        out.send([id, 1]);
        return;
      }

      // Split into words for "AND" search (all words must be present)
      final words = qs
          .split(RegExp(r'\s+'))
          .where((w) => w.isNotEmpty)
          .toList();
      if (words.isEmpty) {
        out.send([id, 1]);
        return;
      }

      const firstBatchSize = 20; // send these immediately for instant UI
      const hardLimit = 120; // cap total results

      var buf = <dynamic>[id, 0]; // 0 = not done yet
      bool firstBatchSent = false;
      int found = 0;

      for (final e in idx) {
        if (latest != id) return; // a newer query arrived → abort

        // Match ALL words (even if not adjacent)
        bool match = true;
        for (final w in words) {
          if (!e.sd.contains(w)) {
            match = false;
            break;
          }
        }
        if (!match) continue;

        buf.addAll([e.s, e.a, e.nm, e.t]);
        found++;

        // ── Flush first batch for immediate display ────────────────────
        if (!firstBatchSent && found == firstBatchSize) {
          out.send(List<dynamic>.from(buf));
          firstBatchSent = true;
          buf = [id, 0];
          found = 0;
        }

        if (found >= hardLimit) break;
      }

      // Send remaining results (or the only batch if < firstBatchSize)
      buf[1] = 1; // mark done
      out.send(List<dynamic>.from(buf));
    });
  }

  static String _sd(String text) {
    if (text.isEmpty) return '';
    var s = text;
    // 1. Normalize complex letters
    s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا'); // Alef
    s = s.replaceAll(RegExp(r'[ئى]'), 'ي'); // Ya / Alef Maksura
    s = s.replaceAll('ؤ', 'و'); // Waw Hamza
    s = s.replaceAll('ة', 'ه'); // Ta Marbuta
    // 2. Remove Tatweel
    s = s.replaceAll('ـ', '');
    // 3. Remove all non-letter characters (including all diacritics and markers)
    // Keep only basic Arabic letters \u0621 to \u064A and spaces
    s = s.replaceAll(RegExp(r'[^\u0621-\u064A\s]'), '');
    // 4. Normalize whitespace
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
