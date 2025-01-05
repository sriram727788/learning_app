/* import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kids_learning/widgets/path_segment.dart';

class LetterPainter extends CustomPainter {
  final List<PathSegment> pathSegments;
  final int currentSegmentIndex;
  final double clearProgress;

  LetterPainter({
    required this.pathSegments,
    required this.currentSegmentIndex,
    required this.clearProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];
      final bool isActive = i == currentSegmentIndex;

      // Draw background guide path
      if (!segment.isCompleted) {
        final Paint guidePaint = Paint()
          ..color = isActive ? Colors.blue.withValues(alpha:0.2) : Colors.grey.withValues(alpha:0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 60
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(segment.path, guidePaint);

        // Enhanced dotted line visibility
        final Paint dottedPaint = Paint()
          ..color = Colors.blue.withValues(alpha:isActive ? 0.6 : 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;

        final Path dashPath = Path.from(segment.path);
        canvas.drawPath(dashPath, dottedPaint);

        if (isActive) {
          final startPoint = segment.points.first;
          final Paint startPointPaint = Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill;

          canvas.drawCircle(startPoint, 30, startPointPaint); // Inner fill
        }
      }

      /* final Paint completedStrokePaint = Paint()
        ..color = Colors.black.withValues(alpha:0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 44
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(segment.path, completedStrokePaint); */
      // Draw completed segments with enhanced visibility
      if (segment.isCompleted) {
        // Draw stroke for completed segments

        final Paint completedPaint = Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 60
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(segment.path, completedPaint);
      }
      // Draw current trace with clearing animation
      else if (isActive && segment.currentTrace.isNotEmpty) {
        final Paint progressPaint = Paint()
          ..color = Colors.blue.withValues(alpha:segment.isClearing ? 1 - segment.clearProgress : 1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 60
          ..strokeCap = StrokeCap.round;

        final PathMetrics metrics = segment.path.computeMetrics();
        for (final metric in metrics) {
          final Path extractPath = metric.extractPath(
            0,
            metric.length * segment.progress,
          );
          canvas.drawPath(extractPath, progressPaint);
        }
      }

      // Draw direction indicators with enhanced visibility
      if (isActive && !segment.isCompleted && !segment.isClearing) {
        final metrics = segment.path.computeMetrics().first;
        for (double t = 0; t < 1.0; t += 0.2) {
          final tangent = metrics.getTangentForOffset(metrics.length * t);
          if (tangent != null) {
            // Draw arrow fill
            final Paint arrowPaint = Paint()
              ..color = Colors.blue
              ..style = PaintingStyle.fill;

            drawArrow(
              canvas,
              tangent.position,
              tangent.vector,
              arrowPaint,
              size: 12,
            );
          }
        }
      }
    }
  }

  void drawArrow(Canvas canvas, Offset start, Offset vector, Paint paint, {double size = 15}) {
    final double angle = atan2(vector.dy, vector.dx);

    final Path arrowPath = Path()
      ..moveTo(
        start.dx - size * cos(angle - pi / 6),
        start.dy - size * sin(angle - pi / 6),
      )
      ..lineTo(start.dx, start.dy)
      ..lineTo(
        start.dx - size * cos(angle + pi / 6),
        start.dy - size * sin(angle + pi / 6),
      );

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(LetterPainter oldDelegate) => true;
}  */
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kids_learning/widgets/path_segment.dart';

class LetterPainter extends CustomPainter {
  final List<PathSegment> pathSegments;
  final int currentSegmentIndex;
  final double clearProgress;
  final ui.Picture? pointerSvg;
  final double animationValue; // Add animation value for pointer movement

  LetterPainter({
    required this.pathSegments,
    required this.currentSegmentIndex,
    required this.clearProgress,
    required this.animationValue,
    this.pointerSvg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];
      final bool isActive = i == currentSegmentIndex;

      // Draw background guide path
      if (!segment.isCompleted) {
        final Paint guidePaint = Paint()
          ..color = isActive ? Colors.blue.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 60
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(segment.path, guidePaint);

        // Enhanced dotted line visibility
        final Paint dottedPaint = Paint()
          ..color = Colors.blue.withValues(alpha: isActive ? 0.6 : 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;

        final Path dashPath = Path.from(segment.path);
        canvas.drawPath(dashPath, dottedPaint);

        if (isActive) {
          final startPoint = segment.points.first;
          final Paint startPointPaint = Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill;

          canvas.drawCircle(startPoint, 30, startPointPaint); // Inner fill
        }
      }

      // Draw completed segments with enhanced visibility
      if (segment.isCompleted) {
        final Paint completedPaint = Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 60
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(segment.path, completedPaint);
      } else if (isActive && segment.currentTrace.isNotEmpty) {
        final Paint progressPaint = Paint()
          ..color = Colors.blue.withValues(alpha: segment.isClearing ? 1 - segment.clearProgress : 1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 60
          ..strokeCap = StrokeCap.round;

        final ui.PathMetrics metrics = segment.path.computeMetrics();
        for (final metric in metrics) {
          final Path extractPath = metric.extractPath(
            0,
            metric.length * segment.progress,
          );
          canvas.drawPath(extractPath, progressPaint);
        }
      }

      // Draw animated pointer SVG for active segment
      if (isActive && !segment.isCompleted && pointerSvg != null) {
        final ui.PathMetrics metrics = segment.path.computeMetrics();
        for (final metric in metrics) {
          // Calculate position along the path based on animation value
          final double distance = metric.length * animationValue;
          final ui.Tangent? tangent = metric.getTangentForOffset(distance);

          if (tangent != null) {
            // Calculate pointer position outside the stroke
            final double angle = atan2(tangent.vector.dy, tangent.vector.dx);
            const double strokeOffset = -35.0; // Adjust this value to position pointer further from stroke

            final Offset pointerPosition = Offset(tangent.position.dx + strokeOffset * cos(angle - pi / 2),
                tangent.position.dy + strokeOffset * sin(angle - pi / 2));

            canvas.save();
            canvas.translate(pointerPosition.dx, pointerPosition.dy);
            // Rotate pointer to point towards the path
            canvas.rotate(angle - pi / 2);
            canvas.scale(0.15); // Adjust scale as needed
            canvas.drawPicture(pointerSvg!);
            canvas.restore();
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(LetterPainter oldDelegate) {
    return oldDelegate.currentSegmentIndex != currentSegmentIndex ||
        oldDelegate.clearProgress != clearProgress ||
        oldDelegate.pointerSvg != pointerSvg ||
        oldDelegate.animationValue != animationValue;
  }
}

class AnimatedLetterPainter extends StatefulWidget {
  final List<PathSegment> pathSegments;
  final int currentSegmentIndex;
  final double clearProgress;

  const AnimatedLetterPainter({
    super.key,
    required this.pathSegments,
    required this.currentSegmentIndex,
    required this.clearProgress,
  });

  @override
  State<AnimatedLetterPainter> createState() => _AnimatedLetterPainterState();
}

class _AnimatedLetterPainterState extends State<AnimatedLetterPainter> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _animationValue = 0.0;
  ui.Picture? pointerSvg;

  @override
  void initState() {
    super.initState();
    _loadPointerSvg();
    _ticker = createTicker((elapsed) {
      setState(() {
        // Slower animation speed for pointer
        _animationValue = (elapsed.inMilliseconds / 3000.0) % 1.0;
      });
    });
    _ticker.start();
  }

  void _loadPointerSvg() async {
    final picture = await _loadSvgAsset('assets/images/pointer.svg');
    setState(() {
      pointerSvg = picture;
    });
  }

  Future<ui.Picture> _loadSvgAsset(String assetPath) async {
    final String rawSvg = await DefaultAssetBundle.of(context).loadString(assetPath);
    final PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(rawSvg), null);
    return pictureInfo.picture;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LetterPainter(
        pathSegments: widget.pathSegments,
        currentSegmentIndex: widget.currentSegmentIndex,
        clearProgress: widget.clearProgress,
        pointerSvg: pointerSvg,
        animationValue: _animationValue,
      ),
      size: Size.infinite,
    );
  }
}


//================================= Arrow animation ================================================

/* class LetterPainter extends CustomPainter {
  final List<PathSegment> pathSegments;
  final int currentSegmentIndex;
  final double clearProgress;
  final double arrowAnimationOffset;

  LetterPainter({
    required this.pathSegments,
    required this.currentSegmentIndex,
    required this.clearProgress,
    required this.arrowAnimationOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];
      final bool isActive = i == currentSegmentIndex;

      // Draw background guide path
      if (!segment.isCompleted) {
        final Paint guidePaint = Paint()
          ..color = isActive ? Colors.blue.withValues(alpha:0.2) : Colors.grey.withValues(alpha:0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 60
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(segment.path, guidePaint);

        // Enhanced dotted line visibility
        final Paint dottedPaint = Paint()
          ..color = Colors.blue.withValues(alpha:isActive ? 0.6 : 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;

        final Path dashPath = Path.from(segment.path);
        canvas.drawPath(dashPath, dottedPaint);

        if (isActive) {
          final startPoint = segment.points.first;
          final Paint startPointPaint = Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill;

          canvas.drawCircle(startPoint, 30, startPointPaint); // Inner fill
        }
      }

      // Draw completed segments with enhanced visibility
      if (segment.isCompleted) {
        // Draw stroke for completed segments

        final Paint completedPaint = Paint()
          ..color = Colors.green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 60
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(segment.path, completedPaint);
      }
      // Draw current trace with clearing animation
      else if (isActive && segment.currentTrace.isNotEmpty) {
        final Paint progressPaint = Paint()
          ..color = Colors.blue.withValues(alpha:segment.isClearing ? 1 - segment.clearProgress : 1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 60
          ..strokeCap = StrokeCap.round;

        final PathMetrics metrics = segment.path.computeMetrics();
        for (final metric in metrics) {
          final Path extractPath = metric.extractPath(
            0,
            metric.length * segment.progress,
          );
          canvas.drawPath(extractPath, progressPaint);
        }
      }

      // Draw direction indicators with enhanced visibility
      // Draw animated direction indicators
      if (isActive && !segment.isCompleted && !segment.isClearing) {
        final metrics = segment.path.computeMetrics().first;
        const int numArrows = 5;
        const double spacing = 1.0 / numArrows;

        for (int j = 0; j < numArrows; j++) {
          double t = (j * spacing + arrowAnimationOffset) % 1.0;
          final tangent = metrics.getTangentForOffset(metrics.length * t);

          if (tangent != null) {
            final double opacity = sin(t * pi) * 0.8;
            final Paint arrowPaint = Paint()
              ..color = Colors.blue.withValues(alpha:opacity)
              ..style = PaintingStyle.fill;

            drawArrow(
              canvas,
              tangent.position,
              tangent.vector,
              arrowPaint,
              size: 20,
            );
          }
        }
      }
    }
  }

  Offset? findClosestPointOnPath(Offset point, List<Offset> pathPoints) {
    double minDistance = double.infinity;
    Offset? closestPoint;

    for (Offset pathPoint in pathPoints) {
      double distance = (point - pathPoint).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = pathPoint;
      }
    }

    return closestPoint;
  }

  void drawArrow(Canvas canvas, Offset start, Offset vector, Paint paint, {double size = 15}) {
    final double angle = atan2(vector.dy, vector.dx);

    final Path arrowPath = Path()
      ..moveTo(
        start.dx - size * cos(angle - pi / 6),
        start.dy - size * sin(angle - pi / 6),
      )
      ..lineTo(start.dx, start.dy)
      ..lineTo(
        start.dx - size * cos(angle + pi / 6),
        start.dy - size * sin(angle + pi / 6),
      );

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(LetterPainter oldDelegate) {
    return oldDelegate.currentSegmentIndex != currentSegmentIndex ||
        oldDelegate.clearProgress != clearProgress ||
        oldDelegate.arrowAnimationOffset != arrowAnimationOffset;
  }
}

class AnimatedLetterPainter extends StatefulWidget {
  final List<PathSegment> pathSegments;
  final int currentSegmentIndex;
  final double clearProgress;

  const AnimatedLetterPainter({
    super.key,
    required this.pathSegments,
    required this.currentSegmentIndex,
    required this.clearProgress,
  });

  @override
  State<AnimatedLetterPainter> createState() => _AnimatedLetterPainterState();
}

class _AnimatedLetterPainterState extends State<AnimatedLetterPainter> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _arrowOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
        _arrowOffset = (elapsed.inMilliseconds / 2000.0) % 1.0;
      });
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LetterPainter(
        pathSegments: widget.pathSegments,
        currentSegmentIndex: widget.currentSegmentIndex,
        clearProgress: widget.clearProgress,
        arrowAnimationOffset: _arrowOffset,
      ),
      size: Size.infinite,
    );
  }
}
 */