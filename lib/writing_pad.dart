import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'dart:math' as math;

class WritingPad extends StatelessWidget {
  final String letter;

  const WritingPad({
    super.key,
    required this.letter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Write "$letter"',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.green),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[100]!, Colors.green[50]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: LetterTracingGame(
                      letter: letter,
                      onLetterCompleted: () {
                        // Show completion animation and navigate back
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => _buildCompletionDialog(context),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Follow the dotted line to write "$letter"',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Comic Sans MS',
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 50,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            Text(
              'Great job!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
                fontFamily: 'Comic Sans MS',
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You wrote "$letter" perfectly!',
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Comic Sans MS',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                String nextLetter = String.fromCharCode(letter.codeUnitAt(0) + 1);
                if (nextLetter == '{') Navigator.of(context).pop(); // Wrap around to 'A'
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => WritingPad(letter: nextLetter),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PathSegment {
  final Path path;
  final List<Offset> points;
  double progress;
  bool isCompleted;
  final double length;
  List<Offset> currentTrace;
  double clearProgress;
  bool isClearing; // New flag to track clearing state
  bool wasStartedCorrectly = false; // Add this line

  PathSegment(
    this.path,
    this.points, {
    this.progress = 0.0,
    this.isCompleted = false,
    this.clearProgress = 0.0,
    this.isClearing = false,
  })  : length = path.computeMetrics().first.length,
        currentTrace = [];
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

class _LetterTracingGameState extends State<LetterTracingGame> with SingleTickerProviderStateMixin {
  List<PathSegment> pathSegments = [];
  bool isDrawing = false;
  int currentSegmentIndex = 0;
  Offset? lastValidPoint;
  List<Offset> currentTrace = [];
  bool isAnimating = false;

  // Adjusted thresholds for better precision
  static const double threshold = 25; // Increased from 15.0
  static const double offTrackTolerance = 0.5; // 50% off-track tolerance

  @override
  void initState() {
    super.initState();
    initializePathSegments();
  }

  bool isPointNearPath(Offset point, List<Offset> pathPoints, {bool checkDirection = true}) {
    if (pathPoints.isEmpty) return false;

    int closestIndex = 0;
    double minDistance = double.infinity;

    // If we have a last valid point, start searching from there
    int searchStartIndex = 0;
    if (lastValidPoint != null && checkDirection) {
      int lastIndex = pathPoints.indexWhere((p) => (p - lastValidPoint!).distance < threshold);
      if (lastIndex != -1) {
        searchStartIndex = lastIndex;
      }
    }

    // Only search forward from the last valid point
    for (int i = searchStartIndex; i < pathPoints.length; i++) {
      double distance = (point - pathPoints[i]).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    // Apply adjusted tolerance
    double currentThreshold = threshold;
    if (minDistance > currentThreshold * (1 + offTrackTolerance)) return false;

    // For initial touch, ensure it's near the start of the path
    if (!isDrawing && checkDirection) {
      int allowedStartRange = (pathPoints.length * 0.15).round();
      if (closestIndex > allowedStartRange) {
        return false;
      }
    }

    // Enforce forward progression more strictly
    if (checkDirection && lastValidPoint != null) {
      int lastValidIndex = pathPoints.indexWhere((p) => (p - lastValidPoint!).distance < currentThreshold);
      if (lastValidIndex != -1) {
        // Only allow forward movement within a reasonable range
        if (closestIndex < lastValidIndex) {
          return false;
        }
      }
    }

    lastValidPoint = pathPoints[closestIndex];
    return true;
  }

  void checkSegmentProgress(Offset point) {
    if (currentSegmentIndex >= pathSegments.length) return;

    PathSegment currentSegment = pathSegments[currentSegmentIndex];
    if (currentSegment.isClearing) return; // Prevent progress while clearing

    if (currentSegment.isCompleted) {
      // Move to the next segment if the current one is completed
      if (currentSegmentIndex + 1 < pathSegments.length) {
        currentSegmentIndex++;
        lastValidPoint = null;
      }
      return;
    }

    currentSegment.currentTrace.add(point);

    // Ensure the user starts correctly
    if (!currentSegment.wasStartedCorrectly) {
      int startRange = (currentSegment.points.length * 0.15).round();
      List<Offset> startPoints = currentSegment.points.sublist(0, startRange);
      if (!isPointNearPath(point, startPoints, checkDirection: true)) return;

      currentSegment.wasStartedCorrectly = true;
    }

    // Update progress only if user is on the path
    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < currentSegment.points.length; i++) {
      double distance = (point - currentSegment.points[i]).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    if (minDistance <= threshold) {
      setState(() {
        double newProgress = closestIndex / (currentSegment.points.length - 1);
        if (newProgress > currentSegment.progress) {
          currentSegment.progress = newProgress;

          // Check if segment is completed
          if (currentSegment.progress == 1 &&
              isTraceContinuous(currentSegment.currentTrace) &&
              hasMinimumTraceLength(currentSegment)) {
            completeSegment();
          }
        }
      });
    } else {
      // Drain progress when off path
      startClearAnimation();
    }
  }

// Update the completeSegment method
  void completeSegment() {
    setState(() {
      pathSegments[currentSegmentIndex].isCompleted = true;

      // Move to next segment if available
      if (currentSegmentIndex < pathSegments.length - 1) {
        currentSegmentIndex++;
        lastValidPoint = null;
      } else {
        // Only show completion dialog when all segments are done
        bool allCompleted = pathSegments.every((segment) => segment.isCompleted);
        if (allCompleted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            widget.onLetterCompleted();
          });
        }
      }
    });
  }

// Update isTraceContinuous method to be more strict
  bool isTraceContinuous(List<Offset> trace) {
    if (trace.length < 2) return false;

    for (int i = 1; i < trace.length; i++) {
      double distance = (trace[i] - trace[i - 1]).distance;
      if (distance > threshold) {
        return false; // No gaps allowed
      }
    }
    return true;
  }

  bool hasMinimumTraceLength(PathSegment segment) {
    // Ensure the trace covers at least 60% of the path length
    if (segment.currentTrace.length < 2) return false;

    double totalDistance = 0;
    for (int i = 1; i < segment.currentTrace.length; i++) {
      totalDistance += (segment.currentTrace[i] - segment.currentTrace[i - 1]).distance;
    }

    return totalDistance >= segment.length * 0.6;
  }

  void startClearAnimation() {
    if (currentSegmentIndex >= pathSegments.length) return;

    PathSegment segment = pathSegments[currentSegmentIndex];
    if (segment.isClearing) return; // Prevent overlapping animations

    setState(() {
      segment.isClearing = true;
    });

    // Animate clearing progress
    setState(() {
      segment.clearProgress = 1.0; // Trigger clearing animation
    });
    setState(() {
      segment.progress = 0.0;
      segment.clearProgress = 0.0;
      segment.isClearing = false;
      segment.currentTrace.clear();
    });
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

  List<String> getLetterPaths(String letter) {
    final Map<String, List<String>> letterPaths = {
      'A': [
        'M150,40 L60,250', // Left diagonal
        'M150,40 L240,250', // Right diagonal
        'M90,170 L210,170' // Cross bar
      ],
      'B': [
        'M90,45 L90,255', // Vertical line
        'M90,45 130,45 A50,50 0 0,1 130,150 L90,150', // Top curve
        'M90,150 150,150 A50,50 0 0,1 150,255 L90,255', // Top curve
      ],
      'C': ['M240,85 Q240,40 180,40 Q60,40 60,145 Q60,250 180,250 Q240,250 240,205'],
      'D': [
        'M60,40 L60,250', // Vertical line
        'M60,40 Q220,40 220,145 Q220,250 60,250' // Curved side
      ],
      'E': [
        'M60,40 L60,250', // Vertical line
        'M60,40 L220,40', // Top line
        'M60,145 L180,145', // Middle line
        'M60,250 L220,250' // Bottom line
      ],
      'F': [
        'M60,40 L60,250', // Vertical line
        'M60,40 L220,40', // Top line
        'M60,145 L180,145' // Middle line
      ],
      'G': [
        'M240,85 Q240,40 180,40 L150,40 A50,50 0 0,0 180,250 Q240,250 240,145',
        'M240,145 L150,145' // Middle line
      ],
      'H': [
        'M60,40 L60,250', // Left vertical
        'M220,40 L220,250', // Right vertical
        'M60,145 L220,145' // Middle line
      ],
      'I': [
        'M140,40 L140,250', // Vertical line
        'M80,40 L200,40', // Top line
        'M80,250 L200,250' // Bottom line
      ],
      'J': [
        'M110,40 L250,40',
        'M180,40 L180,200, 180,200 Q180,250 120,250 Q60,250 60,200' // Bottom curve
      ],
      'K': [
        'M60,40 L60,250', // Vertical line
        'M220,40 L60,170', // Upper diagonal
        'M100,135 L220,250' // Lower diagonal
      ],
      'L': [
        'M60,40 L60,250', // Vertical line
        'M60,250 L220,250' // Bottom line
      ],
      'M': [
        'M60,40 L60,250', // Left vertical
        'M60,40 L140,150', // Left diagonal
        'M140,150 L220,40', // Right diagonal
        'M220,40 L220,250' // Right vertical
      ],
      'N': [
        'M60,40 L60,250', // Left vertical
        'M60,40 L220,250', // Diagonal
        'M220,250 L220,40' // Right vertical
      ],
      'O': ['M140,40 Q60,40 60,145 Q60,250 140,250 Q220,250 220,145 Q220,40 140,40'],
      'P': [
        'M90,45 L90,255', // Vertical line
        'M90,45 150,45 A50,50 0 0,1 150,155 L90,155', // Top curve
      ],
      'Q': [
        'M140,40 Q60,40 60,145 Q60,250 140,250 Q220,250 220,145 Q220,40 140,40',
        'M170,210 L220,260' // Tail
      ],
      'R': [
        'M90,45 L90,255', // Vertical line
        'M90,45 150,45 A50,50 0 0,1 150,155 L90,155', // Top curve
        'M150,155 L210,255' // Diagonal
      ],
      'S': ['M220,85 Q220,40 140,40 Q60,40 60,85 Q60,145 140,145 Q220,145 220,205 Q220,250 140,250 Q60,250 60,205'],
      'T': [
        'M140,40 L140,250', // Vertical line
        'M60,40 L220,40' // Top line
      ],
      'U': ['M60,40 L60,200 Q60,250 140,250 Q220,250 220,200 L220,40'],
      'V': [
        'M60,40 L140,250', // Left diagonal
        'M220,40 L140,250' // Right diagonal
      ],
      'W': [
        'M60,40 L90,250', // First diagonal
        'M90,250 L150,150', // Middle peak
        'M150,150 L210,250', // Second diagonal
        'M210,250 L240,40' // Last diagonal
      ],
      'X': [
        'M60,40 L220,250', // Forward diagonal
        'M220,40 L60,250' // Backward diagonal
      ],
      'Y': [
        'M60,40 L140,145', // Left diagonal
        'M220,40 L140,145', // Right diagonal
        'M140,145 L140,250' // Bottom vertical
      ],
      'Z': [
        'M60,40 L220,40', // Top line
        'M220,40 L60,250', // Diagonal
        'M60,250 L220,250' // Bottom line
      ],
      '0': [
        'M140,40 Q60,40 60,145 Q60,250 140,250 Q220,250 220,145 Q220,40 140,40' // Perfect oval shape, similar to 'O' letter
      ],
      '1': [" M80,90 L150,50", "M150,50 L150,250", "M80,250 L220,250"],
      '2': [
        "M80,90 Q80,50 120,50 L200,50 Q240,50 240,90 L240,130 Q240,170 200,170 L120,170 Q80,170 80,210 L80,250 L240,250"
      ],
      '3': [
        'M80,90 Q80,50 150,50 Q220,50 220,90 Q220,150 150,150',
        'M150,150 Q220,150 220,210 Q220,250 150,250 Q80,250 80,210'
      ],
      '4': [
        'M180,40 L60,180 ',
        'M60,180 L220,180', // Horizontal line
        'M180,40 L180,250' // Vertical line
      ],
      '5': ['M220,50 L80,50 L80,160', 'M80,160 Q120,140 180,130 A50,50 0 0,1 180,250 Q150,250 120,240 Q80,230 80,230'],
      '6': [
        "M240,90 Q240,50 200,50 L120,50 Q80,50 80,90 L80,210 Q80,250 120,250 L200,250 Q240,250 240,210 L240,190 Q240,150 200,150 L120,150 "
      ],
      '7': [
        'M80,40 L220,40', // Top line
        'M220,40 L100,250' // Diagonal line
      ],
      '8': [
        "M 150 30 Q 60 30 60 90 Q 60 150 150 150 Q 240 150 240 90 Q 240 30 150 30",
        "M 150 150 Q 60 150 60 210 Q 60 270 150 270 Q 240 270 240 210 Q 240 150 150 150"
      ],
      '9': [
        "M200,150 200,150 L120,150 Q80,150 80,110 L80,90 Q80,50 120,50 L200,50 Q240,50 240,90 L240,210 Q240,250 200,250 L120,250 Q80,250 80,210"
      ],
      // '9': ['M140,40 Q40,40 40,100 Q40,150 140,150 Q120,150 120,145 Q140,40 140,40']
    };
    return letterPaths[letter] ?? letterPaths['A']!;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          // Find the first uncompleted segment
          while (currentSegmentIndex < pathSegments.length && pathSegments[currentSegmentIndex].isCompleted) {
            currentSegmentIndex++;
          }

          if (currentSegmentIndex < pathSegments.length) {
            PathSegment currentSegment = pathSegments[currentSegmentIndex];
            currentSegment.currentTrace.clear();
            currentSegment.wasStartedCorrectly = false;

            isDrawing = isPointNearPath(
              details.localPosition,
              currentSegment.points,
              checkDirection: true,
            );

            if (isDrawing) {
              currentSegment.wasStartedCorrectly = true;
              currentSegment.currentTrace.add(details.localPosition);
            }
          }
        });
      },
      onPanUpdate: (details) {
        if (isDrawing) {
          if (currentSegmentIndex < pathSegments.length) {
            PathSegment currentSegment = pathSegments[currentSegmentIndex];

            // Check if the current point is near the path
            if (!isPointNearPath(details.localPosition, currentSegment.points)) {
              // If off path, start clearing animation and stop drawing
              setState(() {
                isDrawing = false;
                startClearAnimation();
              });
            } else {
              // If on path, update progress
              checkSegmentProgress(details.localPosition);
            }
          }
        }
      },
      onPanEnd: (details) {
        setState(() {
          if (isDrawing) {
            // Start clearing animation if stroke wasn't completed
            if (currentSegmentIndex < pathSegments.length && !pathSegments[currentSegmentIndex].isCompleted) {
              startClearAnimation();
            }
          }
          isDrawing = false;
          lastValidPoint = null;
        });
      },
      child: CustomPaint(
        size: const Size(300, 300),
        painter: LetterPainter(
          pathSegments: pathSegments,
          currentSegmentIndex: currentSegmentIndex,
          clearProgress:
              currentSegmentIndex < pathSegments.length ? pathSegments[currentSegmentIndex].clearProgress : 0.0,
        ),
      ),
    );
  }
}

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
          ..color = isActive ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.1) // Changed to blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 40
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(segment.path, guidePaint);

        // Enhanced dotted line visibility
        final Paint dottedPaint = Paint()
          ..color = Colors.blue.withOpacity(isActive ? 0.6 : 0.3) // Changed to blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

        final Path dashPath = Path.from(segment.path);
        canvas.drawPath(dashPath, dottedPaint);
        if (isActive) {
          final startPoint = segment.points.first;
          final Paint startPointPaint = Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.fill;

          canvas.drawCircle(startPoint, 20, startPointPaint);
        }
      }

      // Draw completed segments with enhanced visibility
      if (segment.isCompleted) {
        final Paint completedPaint = Paint()
          ..color = Colors.green.withOpacity(0.7) // Keeps green for completed segments
          ..style = PaintingStyle.stroke
          ..strokeWidth = 40
          ..strokeCap = StrokeCap.round;

        canvas.drawPath(segment.path, completedPaint);
      }
      // Draw current trace with clearing animation
      else if (isActive && segment.currentTrace.isNotEmpty) {
        final Paint progressPaint = Paint()
          ..color = Colors.blue.withOpacity(segment.isClearing ? 1 - segment.clearProgress : 1) // Changed to blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 40
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
            final Paint arrowPaint = Paint()
              ..color = Colors.blue // Changed to blue
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
    final double angle = math.atan2(vector.dy, vector.dx);

    final Path arrowPath = Path()
      ..moveTo(
        start.dx - size * math.cos(angle - math.pi / 6),
        start.dy - size * math.sin(angle - math.pi / 6),
      )
      ..lineTo(start.dx, start.dy)
      ..lineTo(
        start.dx - size * math.cos(angle + math.pi / 6),
        start.dy - size * math.sin(angle + math.pi / 6),
      );

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(LetterPainter oldDelegate) => true;
  // currentSegmentIndex != oldDelegate.currentSegmentIndex || clearProgress != oldDelegate.clearProgress;
}
