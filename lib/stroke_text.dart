import 'package:flutter/material.dart';

class StrokeText extends StatelessWidget {
  const StrokeText(
    this.text, {
    super.key,
    required this.style,
    required this.strokeColor,
    required this.strokeWidth,
    this.gradientShader,
    this.maxLines,
    this.textAlign,
    this.overflow,
  });
  final String text;
  final TextStyle? style;
  final Color strokeColor;
  final double strokeWidth;
  final Shader? gradientShader;
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Text(
          text,
          style: style?.copyWith(
            foreground:
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = strokeWidth
                  ..color = strokeColor
                  ..shader = gradientShader,
          ),
          maxLines: maxLines,
          textAlign: textAlign,
          overflow: overflow,
        ),
        Text(
          text,
          style: style,
          maxLines: maxLines,
          textAlign: textAlign,
          overflow: overflow,
        ),
      ],
    );
  }
}
