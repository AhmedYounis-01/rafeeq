import 'package:flutter/material.dart';

class CustomTypingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;
  final Curve curve;

  const CustomTypingText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(seconds: 2),
    this.delay = Duration.zero,
    this.curve = Curves.linear,
  });

  @override
  State<CustomTypingText> createState() => _CustomTypingTextState();
}

class _CustomTypingTextState extends State<CustomTypingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _typingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _typingAnimation = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      try {
        _controller.forward();
      } catch (_) {}
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          try {
            _controller.forward();
          } catch (_) {}
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _typingAnimation,
      builder: (context, child) {
        // Use clamp to ensure we never get a RangeError, even if animation goes out of bounds
        final int visibleCount = _typingAnimation.value.clamp(
          0,
          widget.text.length,
        );
        String visibleText = widget.text.substring(0, visibleCount);
        return Text(visibleText, style: widget.style);
      },
    );
  }
}
