import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Widget that renders text with LaTeX/Math expressions
/// Supports inline math: $...$  and display math: $$...$$
class MathTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Color? mathColor;

  const MathTextWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.mathColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> spans = [];
    final buffer = StringBuffer();
    bool inMath = false;
    bool inDisplayMath = false;
    int i = 0;

    while (i < text.length) {
      // Check for display math $$...$$
      if (i < text.length - 1 && text[i] == '\$' && text[i + 1] == '\$') {
        if (inDisplayMath) {
          // End display math
          final mathText = buffer.toString();
          buffer.clear();
          spans.add(_buildDisplayMath(mathText));
          inDisplayMath = false;
          i += 2;
          continue;
        } else if (!inMath) {
          // Start display math
          if (buffer.isNotEmpty) {
            spans.add(TextSpan(text: buffer.toString()));
            buffer.clear();
          }
          inDisplayMath = true;
          i += 2;
          continue;
        }
      }

      // Check for inline math $...$
      if (text[i] == '\$' && !inDisplayMath) {
        if (inMath) {
          // End inline math
          final mathText = buffer.toString();
          buffer.clear();
          spans.add(_buildInlineMath(mathText));
          inMath = false;
          i++;
          continue;
        } else {
          // Start inline math
          if (buffer.isNotEmpty) {
            spans.add(TextSpan(text: buffer.toString()));
            buffer.clear();
          }
          inMath = true;
          i++;
          continue;
        }
      }

      // Regular character
      buffer.write(text[i]);
      i++;
    }

    // Add remaining text
    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer.toString()));
    }

    return RichText(
      text: TextSpan(
        style:
            textStyle ?? const TextStyle(fontSize: 14, color: Colors.black87),
        children: spans,
      ),
    );
  }

  WidgetSpan _buildInlineMath(String latex) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Math.tex(
          latex,
          textStyle: textStyle?.copyWith(fontSize: (textStyle?.fontSize ?? 14)),
          mathStyle: MathStyle.text,
          textScaleFactor: 1.0,
          onErrorFallback: (error) {
            return Text(
              '\$$latex\$',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: textStyle?.fontSize,
              ),
            );
          },
        ),
      ),
    );
  }

  WidgetSpan _buildDisplayMath(String latex) {
    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Math.tex(
            latex,
            textStyle: textStyle?.copyWith(
              fontSize: (textStyle?.fontSize ?? 14) * 1.2,
            ),
            mathStyle: MathStyle.display,
            textScaleFactor: 1.2,
            onErrorFallback: (error) {
              return Text(
                '\$\$$latex\$\$',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: textStyle?.fontSize,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
