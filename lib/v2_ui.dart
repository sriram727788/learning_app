import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'dart:math' as math;

class LetterTracingPage extends StatefulWidget {
  const LetterTracingPage({super.key});

  @override
  State<LetterTracingPage> createState() => _LetterTracingPageState();
}

class _LetterTracingPageState extends State<LetterTracingPage> {
  String currentLetter = 'A';

  void moveToNextLetter() {
    setState(() {
      if (currentLetter == 'D') {
        currentLetter = 'A';
      } else {
        currentLetter = String.fromCharCode(currentLetter.codeUnitAt(0) + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trace Letter: $currentLetter',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: LetterTracingGame(
                  letter: currentLetter,
                  onLetterCompleted: moveToNextLetter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LetterTracingGame extends StatefulWidget {
  final String letter;
  final VoidCallback onLetterCompleted;

  const LetterTracingGame({
    super.key,
    required this.letter,
    required this.onLetterCompleted,
  });

  @override
  State<LetterTracingGame> createState() => _LetterTracingGameState();
}

class PathSegment {
  final Path path;
  final List<Offset> points;
  double progress;
  bool isCompleted;
  final double length;

  PathSegment(this.path, this.points, {this.progress = 0.0, this.isCompleted = false})
      : length = path.computeMetrics().first.length;
}

class _LetterTracingGameState extends State<LetterTracingGame> {
  List<PathSegment> pathSegments = [];
  bool isDrawing = false;
  int currentSegmentIndex = 0;
  Offset? lastValidPoint;
  static const double threshold = 15.0;
  // Add variables to track continuous tracing
  List<Offset> currentTrace = [];
  double requiredContinuousProgress = 0.1;
  double lastProgress = 0.0; // Track last valid progress

  @override
  void initState() {
    super.initState();
    initializePathSegments();
  }

  @override
  void didUpdateWidget(LetterTracingGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.letter != widget.letter) {
      currentSegmentIndex = 0;
      initializePathSegments();
    }
  }

  List<String> getLetterPaths(String letter) {
    final Map<String, List<String>> letterPaths = {
      'A': [
        'M150,40 L60,250', // Left diagonal
        'M150,40 L240,250', // Right diagonal
        'M90,170 L210,170' // Cross bar
      ],
      'B': [
        'M60,40 L60,250', // Vertical line
        'M60,40 Q180,40 180,110 Q180,145 60,145', // Top curve
        'M60,145 Q200,145 200,195 Q200,250 60,250' // Bottom curve
      ],
      'C': ['M240,85 Q240,40 180,40 Q60,40 60,145 Q60,250 180,250 Q240,250 240,205'],
      'D': [
        'M60,40 L60,250', // Vertical line
        'M60,40 Q220,40 220,145 Q220,250 60,250' // Curved side
      ],
    };
    return letterPaths[letter] ?? letterPaths['A']!;
  }

  void initializePathSegments() {
    setState(() {
      pathSegments = [];
      final List<String> paths = getLetterPaths(widget.letter);

      for (String pathData in paths) {
        final Path path = parseSvgPathData(pathData);
        final List<Offset> points = extractPointsFromPath(path);
        pathSegments.add(PathSegment(path, points));
      }
      lastValidPoint = null;
      currentSegmentIndex = 0;
    });
  }

  List<Offset> extractPointsFromPath(Path path) {
    final List<Offset> points = [];
    path.computeMetrics().forEach((metric) {
      for (double i = 0; i <= metric.length; i += 2) {
        final tangent = metric.getTangentForOffset(i);
        if (tangent != null) {
          points.add(tangent.position);
        }
      }
    });
    return points;
  }

  bool isPointNearPath(Offset point, List<Offset> pathPoints, {bool checkDirection = true}) {
    if (pathPoints.isEmpty) return false;

    int closestIndex = 0;
    double minDistance = double.infinity;

    // Find the closest point on the path
    for (int i = 0; i < pathPoints.length; i++) {
      double distance = (point - pathPoints[i]).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    if (minDistance > threshold) return false;

    if (checkDirection && lastValidPoint != null) {
      // Find the last valid point's index
      int lastValidIndex = pathPoints.indexWhere((p) => (p - lastValidPoint!).distance < threshold);

      if (lastValidIndex != -1) {
        // Only allow forward progress within a reasonable range
        if (closestIndex <= lastValidIndex || closestIndex > lastValidIndex + 10) {
          return false;
        }

        // Check if the movement is continuous
        if (currentTrace.isNotEmpty) {
          Offset lastTrace = currentTrace.last;
          if ((point - lastTrace).distance > threshold * 1.5) {
            return false;
          }
        }
      }
    }

    lastValidPoint = pathPoints[closestIndex];
    return true;
  }

  void _checkSegmentProgress(Offset point) {
    if (currentSegmentIndex >= pathSegments.length) return;

    PathSegment currentSegment = pathSegments[currentSegmentIndex];
    if (!currentSegment.isCompleted) {
      // Add point to current trace
      currentTrace.add(point);

      if (isPointNearPath(point, currentSegment.points)) {
        setState(() {
          int closestIndex = 0;
          double minDistance = double.infinity;

          for (int i = 0; i < currentSegment.points.length; i++) {
            double distance = (point - currentSegment.points[i]).distance;
            if (distance < minDistance) {
              minDistance = distance;
              closestIndex = i;
            }
          }

          // Calculate new progress based on closest point
          double newProgress = closestIndex / (currentSegment.points.length - 1);

          // Only update progress if it's a small increment from the current progress
          if (newProgress > currentSegment.progress &&
              newProgress <= currentSegment.progress + requiredContinuousProgress) {
            currentSegment.progress = newProgress;

            if (currentSegment.progress > 0.9) {
              // Verify that we have a continuous trace before completing
              if (_isTraceContinuous()) {
                currentSegment.isCompleted = true;
                currentSegmentIndex++;
                lastValidPoint = null;
                currentTrace.clear();

                if (currentSegmentIndex >= pathSegments.length) {
                  Future.delayed(const Duration(milliseconds: 500), () {
                    widget.onLetterCompleted();
                  });
                }
              }
            }
          }
        });
      } else {
        // Reset progress if we go off path
        setState(() {
          currentSegment.progress = 0.0;
          lastValidPoint = null;
          currentTrace.clear();
        });
      }
    }
  }

  bool _isTraceContinuous() {
    if (currentTrace.length < 2) return false;

    for (int i = 1; i < currentTrace.length; i++) {
      double distance = (currentTrace[i] - currentTrace[i - 1]).distance;
      if (distance > threshold * 1.5) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        if (currentSegmentIndex < pathSegments.length) {
          setState(() {
            currentTrace.clear();
            isDrawing = isPointNearPath(
              details.localPosition,
              pathSegments[currentSegmentIndex].points,
              checkDirection: false,
            );
            if (isDrawing) {
              currentTrace.add(details.localPosition);
            }
          });
        }
      },
      onPanUpdate: (details) {
        if (isDrawing) {
          _checkSegmentProgress(details.localPosition);
        }
      },
      onPanEnd: (details) {
        setState(() {
          isDrawing = false;
          lastValidPoint = null;
          // currentTrace.clear();
          // Reset progress if the segment wasn't completed
          // if (currentSegmentIndex < pathSegments.length && !pathSegments[currentSegmentIndex].isCompleted) {
          //   pathSegments[currentSegmentIndex].progress = 0.0;
          // }
        });
      },
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(300, 300),
            painter: LetterGuidePainter(
              pathSegments: pathSegments,
              currentSegmentIndex: currentSegmentIndex,
            ),
          ),
          CustomPaint(
            size: const Size(300, 300),
            painter: LetterPainter(
              pathSegments: pathSegments,
              currentSegmentIndex: currentSegmentIndex,
            ),
          ),
        ],
      ),
    );
  }
}

class LetterGuidePainter extends CustomPainter {
  final List<PathSegment> pathSegments;
  final int currentSegmentIndex;

  LetterGuidePainter({
    required this.pathSegments,
    required this.currentSegmentIndex,
  });

  void drawArrow(Canvas canvas, Offset start, Offset vector, Paint paint) {
    const double arrowSize = 15.0;
    final double angle = math.atan2(vector.dy, vector.dx) - (math.pi);

    final Path arrowPath = Path();
    arrowPath.moveTo(
      start.dx + arrowSize * math.cos(angle - math.pi / 6),
      start.dy + arrowSize * math.sin(angle - math.pi / 6),
    );
    arrowPath.lineTo(start.dx, start.dy);
    arrowPath.lineTo(
      start.dx + arrowSize * math.cos(angle + math.pi / 6),
      start.dy + arrowSize * math.sin(angle + math.pi / 6),
    );

    canvas.drawPath(arrowPath, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];
      final bool isActive = i == currentSegmentIndex;

      // Draw guide path
      final Paint guidePaint = Paint()
        ..color = isActive ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(segment.path, guidePaint);

      // Draw direction arrows for active segment
      if (isActive) {
        final Paint arrowPaint = Paint()
          ..color = Colors.blue.withOpacity(0.8)
          ..style = PaintingStyle.fill;

        final metrics = segment.path.computeMetrics().first;
        final int numArrows = (metrics.length / 100).ceil();

        for (int j = 0; j < numArrows; j++) {
          final distance = j * metrics.length / numArrows;
          if (distance < metrics.length) {
            final tangent = metrics.getTangentForOffset(distance);
            if (tangent != null) {
              drawArrow(canvas, tangent.position, tangent.vector, arrowPaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LetterGuidePainter oldDelegate) =>
      currentSegmentIndex != oldDelegate.currentSegmentIndex;
}

class LetterPainter extends CustomPainter {
  final List<PathSegment> pathSegments;
  final int currentSegmentIndex;

  LetterPainter({
    required this.pathSegments,
    required this.currentSegmentIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pathSegments.length; i++) {
      final segment = pathSegments[i];

      if (i < currentSegmentIndex || (i == currentSegmentIndex && segment.progress > 0)) {
        final Paint progressPaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 40
          ..strokeCap = StrokeCap.round;

        final PathMetrics metrics = segment.path.computeMetrics();
        for (final metric in metrics) {
          final Path extractPath = metric.extractPath(
            0,
            metric.length * (i < currentSegmentIndex ? 1.0 : segment.progress),
          );
          canvas.drawPath(extractPath, progressPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant LetterPainter oldDelegate) => true;
}
