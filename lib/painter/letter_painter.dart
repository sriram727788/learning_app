// import 'dart:math';
// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:kids_learning/widgets/path_segment.dart';

// class LetterPainter extends CustomPainter {
//   final List<PathSegment> pathSegments;
//   final int currentSegmentIndex;
//   final double clearProgress;
//   final ui.Picture? pointerSvg;
//   final double animationValue;
//   final double scale;
//   final Offset offset;

//   LetterPainter({
//     required this.pathSegments,
//     required this.currentSegmentIndex,
//     required this.clearProgress,
//     required this.animationValue,
//     required this.scale,
//     required this.offset,
//     this.pointerSvg,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Apply scaling and centering transformation
//     canvas.save();
//     canvas.translate(offset.dx, offset.dy);
//     canvas.scale(scale);

//     for (int i = 0; i < pathSegments.length; i++) {
//       final segment = pathSegments[i];
//       final bool isActive = i == currentSegmentIndex;

//       // Draw background guide path
//       if (!segment.isCompleted) {
//         final Paint guidePaint = Paint()
//           ..color = isActive ? Colors.blue.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.3)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 60 // This will be scaled automatically
//           ..strokeCap = StrokeCap.round;

//         canvas.drawPath(segment.path, guidePaint);

//         // Enhanced dotted line visibility
//         final Paint dottedPaint = Paint()
//           ..color = Colors.blue.withValues(alpha: isActive ? 0.6 : 0.3)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 5;

//         final Path dashPath = Path.from(segment.path);
//         canvas.drawPath(dashPath, dottedPaint);

//         if (isActive) {
//           final startPoint = segment.points.first;
//           final Paint startPointPaint = Paint()
//             ..color = Colors.blue
//             ..style = PaintingStyle.fill;

//           canvas.drawCircle(startPoint, 30, startPointPaint); // Inner fill
//         }
//       }

//       // Draw completed segments with enhanced visibility
//       if (segment.isCompleted) {
//         final Paint completedPaint = Paint()
//           ..color = Colors.green
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 60
//           ..strokeCap = StrokeCap.round;

//         canvas.drawPath(segment.path, completedPaint);
//       } else if (isActive && segment.currentTrace.isNotEmpty) {
//         final Paint progressPaint = Paint()
//           ..color = Colors.blue.withValues(alpha: segment.isClearing ? 1 - segment.clearProgress : 1)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 60
//           ..strokeCap = StrokeCap.round;

//         final ui.PathMetrics metrics = segment.path.computeMetrics();
//         for (final metric in metrics) {
//           final Path extractPath = metric.extractPath(
//             0,
//             metric.length * segment.progress,
//           );
//           canvas.drawPath(extractPath, progressPaint);
//         }
//       }

//       // Draw animated pointer SVG for active segment
//       if (isActive && !segment.isCompleted && pointerSvg != null) {
//         final ui.PathMetrics metrics = segment.path.computeMetrics();
//         for (final metric in metrics) {
//           final double distance = metric.length * animationValue;
//           final ui.Tangent? tangent = metric.getTangentForOffset(distance);

//           if (tangent != null) {
//             final double angle = atan2(tangent.vector.dy, tangent.vector.dx);
//             const double strokeOffset = -35.0;

//             final Offset pointerPosition = Offset(
//               tangent.position.dx + strokeOffset * cos(angle - pi / 2),
//               tangent.position.dy + strokeOffset * sin(angle - pi / 2),
//             );

//             canvas.save();
//             canvas.translate(pointerPosition.dx, pointerPosition.dy);
//             canvas.rotate(angle - pi / 2);
//             canvas.scale(0.15); // Pointer scale remains constant relative to stroke width
//             canvas.drawPicture(pointerSvg!);
//             canvas.restore();
//           }
//         }
//       }
//     }
//     canvas.restore();
//   }

//   @override
//   bool shouldRepaint(LetterPainter oldDelegate) {
//     return oldDelegate.currentSegmentIndex != currentSegmentIndex ||
//         oldDelegate.clearProgress != clearProgress ||
//         oldDelegate.pointerSvg != pointerSvg ||
//         oldDelegate.animationValue != animationValue ||
//         oldDelegate.scale != scale ||
//         oldDelegate.offset != offset;
//   }
// }

// class AnimatedLetterPainter extends StatefulWidget {
//   final List<PathSegment> pathSegments;
//   final int currentSegmentIndex;
//   final double clearProgress;
//   final double scale;
//   final Offset offset;

//   const AnimatedLetterPainter({
//     super.key,
//     required this.pathSegments,
//     required this.currentSegmentIndex,
//     required this.clearProgress,
//     required this.scale,
//     required this.offset,
//   });

//   @override
//   State<AnimatedLetterPainter> createState() => _AnimatedLetterPainterState();
// }

// class _AnimatedLetterPainterState extends State<AnimatedLetterPainter> with SingleTickerProviderStateMixin {
//   late Ticker _ticker;
//   double _animationValue = 0.0;
//   ui.Picture? pointerSvg;

//   @override
//   void initState() {
//     super.initState();
//     _loadPointerSvg();
//     _ticker = createTicker((elapsed) {
//       setState(() {
//         _animationValue = (elapsed.inMilliseconds / 3000.0) % 1.0;
//       });
//     });
//     _ticker.start();
//   }

//   void _loadPointerSvg() async {
//     final picture = await _loadSvgAsset('assets/images/pointer.svg');
//     setState(() {
//       pointerSvg = picture;
//     });
//   }

//   Future<ui.Picture> _loadSvgAsset(String assetPath) async {
//     final String rawSvg = await DefaultAssetBundle.of(context).loadString(assetPath);
//     final PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(rawSvg), null);
//     return pictureInfo.picture;
//   }

//   @override
//   void dispose() {
//     _ticker.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomPaint(
//       painter: LetterPainter(
//         pathSegments: widget.pathSegments,
//         currentSegmentIndex: widget.currentSegmentIndex,
//         clearProgress: widget.clearProgress,
//         pointerSvg: pointerSvg,
//         animationValue: _animationValue,
//         scale: widget.scale,
//         offset: widget.offset,
//       ),
//       size: Size(450 * widget.scale, 450 * widget.scale),
//     );
//   }
// }

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kids_learning/widgets/path_segment.dart';

class LetterPainter extends CustomPainter {
  final List<PathSegment> pathSegments;
  final int currentSegmentIndex;
  final double clearProgress;
  final double arrowAnimationProgress;
  final double arrowSpacing;
  final double scale;
  final Offset offset;

  LetterPainter({
    required this.pathSegments,
    required this.currentSegmentIndex,
    required this.clearProgress,
    required this.arrowAnimationProgress,
    this.arrowSpacing = 150.0,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

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

          canvas.drawCircle(startPoint, 30, startPointPaint);
        }
      }

      // Draw completed segments
      if (segment.isCompleted) {
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
          ..color = Colors.blue.withValues(alpha: segment.isClearing ? 1 - segment.clearProgress : 1)
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

      // Draw animated arrows with uniform speed
      if (isActive && !segment.isCompleted && !segment.isClearing) {
        final metrics = segment.path.computeMetrics().first;
        final double pathLength = metrics.length;

        // Calculate number of arrows based on path length and desired spacing
        final int numArrows = max(2, (pathLength / arrowSpacing).ceil());

        for (int j = 0; j < numArrows; j++) {
          // Calculate position along path (0.0 to 1.0)
          double baseOffset = j / numArrows;
          // Add animation progress and wrap around
          double t = (baseOffset + (arrowAnimationProgress / pathLength)) % 1.0;

          // Get position and direction at current point
          final tangent = metrics.getTangentForOffset(t * pathLength);

          if (tangent != null) {
            // Calculate opacity using sine wave for smooth fade
            // final double opacity = (sin(t * 2 * pi) * 0.5 + 0.5) * 0.8;

            final Paint arrowPaint = Paint()
              ..color = Colors.blue
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

  void drawArrow(Canvas canvas, Offset position, Offset direction, Paint paint, {double size = 15}) {
    final double angle = atan2(direction.dy, direction.dx);

    // Create arrow path with improved shape
    final Path arrowPath = Path()
      ..moveTo(
        position.dx - size * cos(angle - pi / 6),
        position.dy - size * sin(angle - pi / 6),
      )
      ..lineTo(position.dx, position.dy)
      ..lineTo(
        position.dx - size * cos(angle + pi / 6),
        position.dy - size * sin(angle + pi / 6),
      );

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(LetterPainter oldDelegate) {
    return oldDelegate.currentSegmentIndex != currentSegmentIndex ||
        oldDelegate.clearProgress != clearProgress ||
        oldDelegate.arrowAnimationProgress != arrowAnimationProgress;
  }
}

class AnimatedLetterPainter extends StatefulWidget {
  final List<PathSegment> pathSegments;
  final int currentSegmentIndex;
  final double clearProgress;
  final double scale;
  final Offset offset;

  const AnimatedLetterPainter({
    super.key,
    required this.pathSegments,
    required this.currentSegmentIndex,
    required this.clearProgress,
    required this.scale,
    required this.offset,
  });

  @override
  State<AnimatedLetterPainter> createState() => _AnimatedLetterPainterState();
}

class _AnimatedLetterPainterState extends State<AnimatedLetterPainter> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _arrowProgress = 0.0;
  static const animationSpeed = 100.0; // Desired arrow speed in logical pixels per second

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
        // Increment arrow progress based on fixed speed
        _arrowProgress = (elapsed.inMilliseconds / 1000) * animationSpeed;
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
        arrowAnimationProgress: _arrowProgress,
        scale: widget.scale,
        offset: widget.offset,
      ),
      size: Size(450 * widget.scale, 450 * widget.scale),
    );
  }
}
