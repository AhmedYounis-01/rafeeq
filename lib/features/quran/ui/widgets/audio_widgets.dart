import 'dart:async';

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Audio Button
// ═══════════════════════════════════════════════════════════════════════════
class AudioBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  final bool filled;

  const AudioBtn({
    super.key,
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size + 14,
      height: size + 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color.withValues(alpha: 0.15) : Colors.transparent,
        border: Border.all(color: color.withValues(alpha: filled ? 0.5 : 0.25)),
      ),
      child: Icon(icon, color: color, size: size),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// Equalizer Bars
// ═══════════════════════════════════════════════════════════════════════════
class EqBars extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double size;

  const EqBars({
    super.key,
    required this.isPlaying,
    required this.color,
    this.size = 22,
  });

  @override
  State<EqBars> createState() => _EqBarsState();
}

class _EqBarsState extends State<EqBars> with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + i * 80),
      ),
    );
    _anims = _ctrls
        .map(
          (c) => Tween<double>(
            begin: 0.2,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)),
        )
        .toList();
    if (widget.isPlaying) _start();
  }

  void _start() {
    for (int i = 0; i < _ctrls.length; i++) {
      Future.delayed(Duration(milliseconds: i * 60), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  void _stop() {
    for (final c in _ctrls) {
      c.animateTo(0.2, duration: const Duration(milliseconds: 200));
    }
  }

  @override
  void didUpdateWidget(EqBars old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying != old.isPlaying) {
      widget.isPlaying ? _start() : _stop();
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.size,
    height: widget.size,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(
        4,
        (i) => AnimatedBuilder(
          animation: _anims[i],
          builder: (_, _) => Container(
            width: widget.size * 0.14,
            height: widget.size * _anims[i].value,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    ),
  );
}
