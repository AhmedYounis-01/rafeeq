import 'package:flutter/material.dart';

class TapButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color primary;
  final int count, target;
  final bool completed, isDark;

  const TapButton({
    super.key,
    required this.onTap,
    required this.primary,
    required this.count,
    required this.target,
    required this.completed,
    required this.isDark,
  });

  @override
  State<TapButton> createState() => _TapButtonState();
}

class _TapButtonState extends State<TapButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.93,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width * 0.52;
    final progress = widget.target > 0 ? widget.count / widget.target : 0.0;
    final coreBg = widget.isDark
        ? const Color(0xFF0F1E16)
        : const Color(0xFF143022);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.primary.withValues(
                        alpha: widget.isDark ? 0.12 : 0.08,
                      ),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              Container(
                width: size * 0.95,
                height: size * 0.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.primary.withValues(alpha: 0.18),
                    width: 1.5,
                  ),
                ),
              ),
              SizedBox(
                width: size * 0.86,
                height: size * 0.86,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  builder: (_, val, _) => CircularProgressIndicator(
                    value: val,
                    strokeWidth: 5,
                    backgroundColor: widget.primary.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      widget.completed
                          ? const Color(0xFF4CAF50)
                          : widget.primary,
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
              Container(
                width: size * 0.74,
                height: size * 0.74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.primary.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
              ),
              Container(
                width: size * 0.66,
                height: size * 0.66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 0.9,
                    colors: [
                      widget.primary.withValues(alpha: 0.28),
                      widget.primary.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                  border: Border.all(
                    color: widget.primary.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: size * 0.48,
                height: size * 0.48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: coreBg,
                  border: Border.all(
                    color: widget.primary.withValues(alpha: 0.45),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.primary.withValues(alpha: 0.18),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: size * 0.16,
                      color: widget.completed
                          ? const Color(0xFF4CAF50)
                          : widget.primary,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.count}',
                      style: TextStyle(
                        fontSize: size * 0.08,
                        fontWeight: FontWeight.bold,
                        color: widget.completed
                            ? const Color(0xFF4CAF50)
                            : widget.primary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
