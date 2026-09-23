import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rafeeq/core/themes/app_colors.dart';
import 'package:rafeeq/features/tasbih/logic/tasbih_cubit.dart';
import 'package:rafeeq/features/tasbih/logic/tasbih_state.dart';
import 'widgets/tasbih_config.dart';
import 'widgets/selection_screen.dart';
import 'widgets/counter_screen.dart';

export 'widgets/tasbih_config.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TasbihCubit(),
      child: const _TasbihConsumer(),
    );
  }
}

class _TasbihConsumer extends StatefulWidget {
  const _TasbihConsumer();

  @override
  State<_TasbihConsumer> createState() => _TasbihConsumerState();
}

class _TasbihConsumerState extends State<_TasbihConsumer> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = context.locale.languageCode;
    context.read<TasbihCubit>().loadData(lang);
  }

  @override
  Widget build(BuildContext context) {
    final langCode = context.locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cfg = TasbihConfig(context);
    final primary = AppColors.getPrimary(context);
    final isRtl = langCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: BlocBuilder<TasbihCubit, TasbihState>(
        builder: (context, state) {
          if (state.loading) {
            return Center(child: CircularProgressIndicator(color: primary));
          }

          final cubit = context.read<TasbihCubit>();

          return PopScope(
            canPop: state.selectedIdx == null,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              cubit.selectDhikr(null);
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 380),
              transitionBuilder: (child, anim) => SlideTransition(
                position:
                    Tween<Offset>(
                      begin: state.selectedIdx != null
                          ? const Offset(1, 0)
                          : const Offset(-1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                    ),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: state.selectedIdx == null
                  ? SelectionScreen(
                      key: const ValueKey('selection'),
                      isDark: isDark,
                      isRtl: isRtl,
                      cfg: cfg,
                      primary: primary,
                      adhkar: state.adhkar,
                      searchQuery: state.searchQuery,
                      activeCat: state.activeCat,
                      onSearch: cubit.updateSearch,
                      onCategorySelect: cubit.updateCategory,
                      onSelect: cubit.selectDhikr,
                      sessions: state.sessions,
                      todayTotal: state.todayTotal,
                    )
                  : CounterScreen(
                      key: const ValueKey('counter'),
                      isDark: isDark,
                      isRtl: isRtl,
                      cfg: cfg,
                      primary: primary,
                      dhikr: state.currentDhikr!,
                      count: state.count,
                      completed: state.completed,
                      silentMode: state.silent,
                      sessions: state.sessions,
                      todayTotal: state.todayTotal,
                      onTap: cubit.incrementCount,
                      onReset: cubit.resetCount,
                      onBack: () => cubit.selectDhikr(null),
                      onNext: cubit.goNext,
                      onPrev: cubit.goPrev,
                      onSilentToggle: cubit.toggleSilent,
                    ),
            ),
          );
        },
      ),
    );
  }
}
