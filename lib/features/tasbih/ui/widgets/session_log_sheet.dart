import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/tasbih/logic/tasbih_state.dart';
import 'tasbih_config.dart';

class SheetHandle extends StatelessWidget {
  final Color primary;
  const SheetHandle({super.key, required this.primary});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 12, bottom: 4),
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: primary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

class SessionLogSheet extends StatelessWidget {
  final List<TasbihSession> sessions;
  final bool isDark;
  final TasbihConfig cfg;
  final Color primary;
  final int todayTotal;

  const SessionLogSheet({
    super.key,
    required this.sessions,
    required this.isDark,
    required this.cfg,
    required this.primary,
    required this.todayTotal,
  });

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.7,
    ),
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
    decoration: BoxDecoration(
      color: isDark ? AppColors.backgroundCardDark : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      border: Border.all(color: primary.withValues(alpha: 0.15)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHandle(primary: primary),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_rounded, color: primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'tasbih.sessionLog'.tr(),
                style: TasbihTextStyles.amiriBold(cfg.titleFont * 0.85, primary),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.auto_awesome_rounded, color: primary, size: 16),
              const SizedBox(width: 8),
              Text(
                'tasbih.totalCount'.tr(namedArgs: {'total': '$todayTotal'}),
                style: TasbihTextStyles.amiriBold(cfg.labelFont + 2, primary),
              ),
            ],
          ),
        ),
        sessions.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'tasbih.noSessions'.tr(),
                  style: TasbihTextStyles.amiri(
                    cfg.labelFont + 1,
                    isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              )
            : Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  itemBuilder: (_, i) {
                    final s = sessions[sessions.length - 1 - i];
                    final t =
                        '${s.time.hour.toString().padLeft(2, '0')}:${s.time.minute.toString().padLeft(2, '0')}';
                    return Column(
                      children: [
                        if (i > 0)
                          Divider(
                            height: 1,
                            color: primary.withValues(alpha: 0.07),
                          ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primary.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: primary,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            s.dhikrText,
                            textDirection: TextDirection.rtl,
                            style: TasbihTextStyles.amiriQuran(
                              cfg.labelFont + 1,
                              isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            tr(
                              'tasbih.times',
                              namedArgs: {'count': '${s.count}'},
                            ),
                            style: TasbihTextStyles.amiri(cfg.labelFont, primary),
                          ),
                          trailing: Text(
                            t,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ],
    ),
  );
}
