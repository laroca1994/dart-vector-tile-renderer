import 'dart:math';
import 'dart:ui';

import 'expression/caching_expression.dart';
import 'expression/expression.dart';

class TextHaloFactory {
  static Expression<List<Shadow>>? toHaloFunction(
    Expression<Color> colorExpression,
    Expression<double>? haloWidth, [
    Expression<double>? haloBlur,
  ]) {
    return cache(TextHaloExpression(colorExpression, haloWidth, haloBlur));
  }
}

class TextHaloExpression extends Expression<List<Shadow>> {
  final Expression<Color> colorExpression;
  final Expression<double>? haloWidth;
  final Expression<double>? haloBlur;

  TextHaloExpression(this.colorExpression, this.haloWidth, [this.haloBlur])
    : super(
        'textHalo(${colorExpression.cacheKey},${haloWidth?.cacheKey},${haloBlur?.cacheKey})',
        {
          ...colorExpression.properties(),
          ...(haloWidth?.properties() ?? {}),
          ...(haloBlur?.properties() ?? {}),
          'zoom',
        },
      );

  @override
  List<Shadow>? evaluate(EvaluationContext context) {
    final color = colorExpression.evaluate(context);
    if (color == null) {
      return null;
    }
    final width = haloWidth?.evaluate(context);
    if (width == null) {
      return null;
    }
    double factor = max(1.0, context.zoomScaleFactor);
    double offset = width / factor;
    // `text-halo-blur` is a separate style property whose default is 0: the
    // halo is a distance from the glyph outline, not a cloud around it.
    // Previously the blur radius was the halo width, so every label paid for
    // four blurred draws that the style never asked for.
    double radius = (haloBlur?.evaluate(context) ?? 0.0) / factor;
    return [
      Shadow(
        offset: Offset(-offset, -offset),
        blurRadius: radius,
        color: color,
      ),
      Shadow(offset: Offset(offset, offset), blurRadius: radius, color: color),
      Shadow(offset: Offset(offset, -offset), blurRadius: radius, color: color),
      Shadow(offset: Offset(-offset, offset), blurRadius: radius, color: color),
    ];
  }

  @override
  bool get isConstant => false;
}
