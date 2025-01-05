import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:kids_learning/painter/letter_painter.dart';
import 'package:kids_learning/screen/writing_pad.dart';
import 'package:kids_learning/widgets/path_segment.dart';
import 'package:path_drawing/path_drawing.dart';

class LetterTracingScreen extends StatefulWidget {
  final String letter;
  final VoidCallback onLetterCompleted;

  const LetterTracingScreen({
    super.key,
    required this.letter,
    required this.onLetterCompleted,
  });

  @override
  State<LetterTracingScreen> createState() => _LetterTracingScreenState();
}

class _LetterTracingScreenState extends State<LetterTracingScreen> with TickerProviderStateMixin {
  List<PathSegment> pathSegments = [];
  bool isDrawing = false;
  int currentSegmentIndex = 0;
  Offset? lastValidPoint;
  List<Offset> currentTrace = [];
  bool isAnimating = false;
  late ConfettiController _confettiController;
  bool _showNextButton = false;

  static const double threshold = 25;
  static const double offTrackTolerance = 1.0;

  // Add celebration animation controller
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _jumpAnimation;

  @override
  void initState() {
    super.initState();
    initializePathSegments();

    _confettiController = ConfettiController(duration: const Duration(seconds: 2));

    // Initialize celebration animation controller
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

// Create jump animation
    _jumpAnimation = TweenSequence<Offset>([
      // Initial jump up
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(0, -0.3),
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15.0,
      ),
      // Stay up during spin
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: const Offset(0, -0.3),
        ),
        weight: 50.0,
      ),
      // Fall down with bounce
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.3),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 35.0,
      ),
    ]).animate(_celebrationController);

// Create rotation animation
    _rotationAnimation = TweenSequence<double>([
      // No rotation during initial jump
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0),
        weight: 15.0,
      ),
      // Spin 4 times on Y-axis
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 3).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50.0,
      ),
      // No more rotation during landing
      TweenSequenceItem(
        tween: Tween<double>(begin: 3, end: 3),
        weight: 35.0,
      ),
    ]).animate(_celebrationController);

// Create scale animation
    _scaleAnimation = TweenSequence<double>([
      // Scale up during jump
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15.0,
      ),
      // Maintain scale during spin
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.2),
        weight: 50.0,
      ),
      // Scale down during landing
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 35.0,
      ),
    ]).animate(_celebrationController);

    _celebrationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _celebrationController.reset();
      }
    });
  }

  /* void startClearAnimation() {
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
  } */

  void startClearAnimation() {
    if (currentSegmentIndex >= pathSegments.length) return;

    PathSegment segment = pathSegments[currentSegmentIndex];
    if (segment.isClearing) return;

    setState(() {
      segment.isClearing = true;
      segment.clearProgress = 1.0;

      // Reset all progress tracking
      segment.reset();
      lastValidPoint = null;
    });
  }

  /* void initializePathSegments() {
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
  } */

  void initializePathSegments() {
    setState(() {
      pathSegments = [];
      final List<String> paths = getLetterPaths(widget.letter);

      // Initialize segments with sequence indices
      for (int i = 0; i < paths.length; i++) {
        final Path path = parseSvgPathData(paths[i]);
        final List<Offset> points = extractPointsFromPath(path);
        pathSegments.add(PathSegment(path, points));
      }
      lastValidPoint = null;
      currentSegmentIndex = 0;
    });
  }

  /* bool isPointNearPath(Offset point, List<Offset> pathPoints, {bool checkDirection = true}) {
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
      int allowedStartRange = (pathPoints.length * 0.2).round();
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
  } */

  /* bool isPointNearPath(Offset point, List<Offset> pathPoints, {bool checkDirection = true}) {
    if (pathPoints.isEmpty) return false;

    PathSegment currentSegment = pathSegments[currentSegmentIndex];
    int closestIndex = 0;
    double minDistance = double.infinity;

    // Calculate search range based on current progress
    int searchStartIndex = 0;
    int searchEndIndex = pathPoints.length;

    if (lastValidPoint != null && checkDirection) {
      // Find the last valid point's index
      int lastIndex = pathPoints.indexWhere((p) => (p - lastValidPoint!).distance < threshold);
      if (lastIndex != -1) {
        searchStartIndex = lastIndex;
        // Limit forward search to prevent jumping too far ahead
        searchEndIndex = min(lastIndex + (pathPoints.length ~/ 4), pathPoints.length);
      }
    }

    // Search only within the valid range for the current segment
    for (int i = searchStartIndex; i < searchEndIndex; i++) {
      double distance = (point - pathPoints[i]).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    // Apply adjusted tolerance
    if (minDistance > threshold * (1 + offTrackTolerance)) return false;

    // For initial touch, ensure it's near the start of the path
    if (!isDrawing && checkDirection) {
      int allowedStartRange = (pathPoints.length * 0.2).round();
      if (closestIndex > allowedStartRange) {
        return false;
      }
    }

    // Check if point is in the correct sequence
    if (checkDirection && lastValidPoint != null) {
      int lastValidIndex = pathPoints.indexWhere((p) => (p - lastValidPoint!).distance < threshold);
      if (lastValidIndex != -1) {
        // Only allow forward movement within the current segment
        if (closestIndex < lastValidIndex) {
          return false;
        }
      }
    }

    lastValidPoint = pathPoints[closestIndex];
    return true;
  } */

  void goToNextLetter() {
    String nextLetter = String.fromCharCode(widget.letter.codeUnitAt(0) + 1);
    if (nextLetter == '{') {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => WritingPad(letter: nextLetter),
      ),
    );
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

  /* void checkSegmentProgress(Offset point) {
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
  } */

  /* void checkSegmentProgress(Offset point) {
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

    // Don't add points or update progress if drawing is disabled
    if (!isDrawing) return;

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
    }
  } */
  bool isPointNearPath(Offset point, List<Offset> pathPoints, {bool checkDirection = true}) {
    if (pathPoints.isEmpty) return false;

    PathSegment currentSegment = pathSegments[currentSegmentIndex];

    // For initial touch, only check near the start
    if (!isDrawing || !checkDirection) {
      int startRange = (pathPoints.length * 0.1).round(); // 10% of path length
      double minStartDistance = double.infinity;
      int startIndex = -1;

      for (int i = 0; i < startRange; i++) {
        double distance = (point - pathPoints[i]).distance;
        if (distance < minStartDistance) {
          minStartDistance = distance;
          startIndex = i;
        }
      }

      if (minStartDistance <= threshold) {
        currentSegment.progressIndex = startIndex;
        lastValidPoint = pathPoints[startIndex];
        return true;
      }
      return false;
    }

    // For continued tracing, look ahead from current progress
    int searchStart = currentSegment.progressIndex;
    int searchEnd = min(searchStart + 20, pathPoints.length); // Look ahead max 20 points

    double minDistance = double.infinity;
    int closestIndex = -1;

    // Only search forward from current position
    for (int i = searchStart; i < searchEnd; i++) {
      double distance = (point - pathPoints[i]).distance;
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    if (closestIndex != -1 && minDistance <= threshold) {
      // Only update progress if moving forward
      if (closestIndex >= currentSegment.progressIndex) {
        // Mark points as visited
        for (int i = currentSegment.progressIndex; i <= closestIndex; i++) {
          currentSegment.pointsVisited[i] = true;
        }
        currentSegment.progressIndex = closestIndex;
        lastValidPoint = pathPoints[closestIndex];
        return true;
      }
    }

    return false;
  }

  void checkSegmentProgress(Offset point) {
    if (currentSegmentIndex >= pathSegments.length) return;

    PathSegment currentSegment = pathSegments[currentSegmentIndex];
    if (currentSegment.isClearing || !isDrawing) return;

    if (currentSegment.isCompleted) {
      if (currentSegmentIndex + 1 < pathSegments.length) {
        currentSegmentIndex++;
        lastValidPoint = null;
      }
      return;
    }

    // Check if point is valid for current segment
    if (!isPointNearPath(point, currentSegment.points)) {
      startClearAnimation();
      isDrawing = false;
      return;
    }

    currentSegment.currentTrace.add(point);

    // Update progress based on visited points
    setState(() {
      currentSegment.progress = currentSegment.progressIndex / (currentSegment.points.length - 1);

      // Check for completion
      if (currentSegment.progress > 0.95 &&
          isTraceContinuous(currentSegment.currentTrace) &&
          hasMinimumTraceLength(currentSegment)) {
        completeSegment();
      }
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

  List<String> getLetterPaths(String letter) {
    final Map<String, List<String>> letterPaths = {
      'A': [
        'M200,80 L80,360', // Left diagonal
        'M200,80 L320,360', // Right diagonal
        'M120,254 L280,254' // Cross bar
      ],
      'B': [
        'M120,80 L120,360', // Vertical line
        'M120,80 173,80 A67,67 0 0,1 173,220 L120,220', // Top curve
        'M120,220 200,220 A67,67 0 0,1 200,360 L120,360', // Bottom curve
      ],
      'C': ['M320,140 Q320,80 240,80 Q80,80 80,220 Q80,360 240,360 Q320,360 320,300'],
      'D': [
        'M120,80 L120,360', // Vertical line
        'M120,80 Q293,80 293,220 Q293,360 120,360' // Curved side
      ],
      'E': [
        'M120,80 L120,360', // Vertical line
        'M120,80 L280,80', // Top line
        'M120,220 L240,220', // Middle line
        'M120,360 L280,360' // Bottom line
      ],
      'F': [
        'M120,80 L120,360', // Vertical line
        'M120,80 L280,80', // Top line
        'M120,220 L240,220' // Middle line
      ],
      'G': [
        'M320,140 Q320,80 240,80 L200,80 A67,67 0 0,0 240,360 Q320,360 320,220 L200,220' // Middle line
      ],
      'H': [
        'M100,80 L100,360', // Left vertical
        'M300,80 L300,360', // Right vertical
        'M100,220 L300,220' // Middle line
      ],
      'I': [
        'M200,80 L200,360', // Vertical line
        'M120,80 L280,80', // Top line
        'M120,360 L280,360' // Bottom line
      ],
      'J': [
        'M160,80 L300,80',
        'M240,80 L240,280 240,280 Q240,360 180,360 Q100,360 100,280' // Bottom curve
      ],
      'K': [
        'M120,80 L120,360', // Vertical line
        'M300,80 L120,220', // Upper diagonal
        'M10,200 L300,360' // Lower diagonal
      ],
      'L': [
        'M120,80 L120,360', // Vertical line
        'M120,360 L280,360' // Bottom line
      ],
      'M': [
        'M100,80 L100,360', // Left vertical
        'M100,80 L200,220', // Left diagonal
        'M200,220 L300,80', // Right diagonal
        'M300,80 L300,360' // Right vertical
      ],
      'N': [
        'M120,80 L120,360', // Left vertical
        'M120,80 L280,360', // Diagonal
        'M280,360 L280,80' // Right vertical
      ],
      'O': ['M200,80 Q100,80 100,220 Q100,360 200,360 Q300,360 300,220 Q300,80 200,80'],
      'P': [
        'M120,80 L120,360', // Vertical line
        'M120,80 200,80 A67,67 0 0,1 200,220 L120,220', // Top curve
      ],
      'Q': [
        'M200,80 Q100,80 100,220 Q100,360 200,360 Q300,360 300,220 Q300,80 200,80',
        'M240,320 L300,380' // Tail
      ],
      'R': [
        'M120,80 L120,360', // Vertical line
        'M120,80 200,80 A67,67 0 0,1 200,220 L120,220', // Top curve
        'M200,220 L280,360' // Diagonal
      ],
      'S': [
        'M280,140 Q280,80 200,80 Q120,80 120,140 Q120,220 200,220 Q280,220 280,300 Q280,360 200,360 Q120,360 120,300'
      ],
      'T': [
        'M200,80 L200,360', // Vertical line
        'M100,80 L300,80' // Top line
      ],
      'U': ['M100,80 L100,280 Q100,360 200,360 Q300,360 300,280 L300,80'],
      'V': [
        'M100,80 L200,360', // Left diagonal
        'M300,80 L200,360' // Right diagonal
      ],
      'W': [
        'M80,80 L120,360', // First diagonal
        'M120,360 L200,220', // Middle peak
        'M200,220 L280,360', // Second diagonal
        'M280,360 L320,80' // Last diagonal
      ],
      'X': [
        'M120,80 L280,360', // Forward diagonal
        'M280,80 L120,360' // Backward diagonal
      ],
      'Y': [
        'M120,80 L200,220', // Left diagonal
        'M280,80 L200,220', // Right diagonal
        'M200,220 L200,360' // Bottom vertical
      ],
      'Z': [
        'M120,80 L280,80', // Top line
        'M280,80 L120,360', // Diagonal
        'M120,360 L280,360' // Bottom line
      ],
      // Numbers follow the same centering pattern
      '0': ['M200,80 Q120,80 120,220 Q120,360 200,360 Q280,360 280,220 Q280,80 200,80'],
      '1': ['M160,140 L200,80', 'M200,80 L200,360', 'M140,360 L260,360'],
      '2': [
        'M140,140 Q140,80 180,80 L260,80 Q300,80 300,140 L300,180 Q300,220 260,220 L180,220 Q140,220 140,260 L140,360 L300,360'
      ],
      '3': [
        'M140,140 Q140,80 200,80 Q260,80 260,140 Q260,220 200,220',
        'M200,220 Q260,220 260,300 Q260,360 200,360 Q140,360 140,300'
      ],
      '4': ['M240,80 L120,260', 'M120,260 L280,260', 'M240,80 L240,360'],
      '5': [
        'M280,80 L140,80 L140,220',
        'M140,220 Q180,200 240,180 A67,67 0 0,1 240,360 Q200,360 180,340 Q140,320 140,320'
      ],
      '6': [
        'M300,140 Q300,80 260,80 L180,80 Q140,80 140,140 L140,300 Q140,360 180,360 L260,360 Q300,360 300,300 L300,280 Q300,220 260,220 L180,220'
      ],
      '7': ['M140,80 L280,80', 'M280,80 L160,360'],
      '8': [
        'M200,80 Q120,80 120,140 Q120,220 200,220 Q280,220 280,300 Q280,360 200,360 Q120,360 120,300 Q120,220 200,220 Q280,220 280,140 Q280,80 220,80',
        /* Q280,220 280,140 Q280,80 200,80 */
      ],
      /* 
      lh:left half circle
      rh:right half circle
      rbh: right bottom half circle
      lbh: left bottom half circle
       */
      '9': [
        'M260,220 260,220 L180,220 Q140,220 140,180 L140,140 Q140,80 180,80 L260,80 Q300,80 300,140 L300,300 Q300,360 260,360 L180,360 Q140,360 140,300'
      ]
    };
    return letterPaths[letter] ?? letterPaths['A']!;
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void startCelebration() {
    _celebrationController.forward();
    _confettiController.play();
    widget.onLetterCompleted();
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
        // Only show completion celebration when all segments are done
        bool allCompleted = pathSegments.every((segment) => segment.isCompleted);
        if (allCompleted) {
          Future.delayed(const Duration(milliseconds: 500), () {
            startCelebration();
            setState(() {
              _showNextButton = true;
            });
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Visibility(
          visible: _showNextButton,
          child: AnimatedBuilder(
            animation: _celebrationController,
            builder: (context, child) {
              return Transform.translate(
                offset: _jumpAnimation.value * 100, // Multiply by desired jump height
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(_rotationAnimation.value * pi * 2),
                  alignment: Alignment.center,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: CustomPaint(
                      size: const Size(400, 400),
                      painter: LetterPainter(
                        pathSegments: pathSegments,
                        currentSegmentIndex: currentSegmentIndex,
                        clearProgress: currentSegmentIndex < pathSegments.length
                            ? pathSegments[currentSegmentIndex].clearProgress
                            : 0.0,
                        animationValue: 0,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        /* GestureDetector(
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
            if (!isDrawing) return; // Exit early if drawing is disabled

            if (currentSegmentIndex < pathSegments.length) {
              PathSegment currentSegment = pathSegments[currentSegmentIndex];

              // Check if the current point is near the path
              if (!isPointNearPath(details.localPosition, currentSegment.points)) {
                // If off path, start clearing animation and disable drawing
                setState(() {
                  isDrawing = false;
                  startClearAnimation();
                });
              } else {
                // If on path, update progress
                checkSegmentProgress(details.localPosition);
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
          child: Visibility(
            visible: !_showNextButton,
            child: AnimatedLetterPainter(
                pathSegments: pathSegments,
                currentSegmentIndex: currentSegmentIndex,
                clearProgress:
                    currentSegmentIndex < pathSegments.length ? pathSegments[currentSegmentIndex].clearProgress : 0.0),
          ),
        ), */
        GestureDetector(
          onPanStart: (details) {
            setState(() {
              while (currentSegmentIndex < pathSegments.length && pathSegments[currentSegmentIndex].isCompleted) {
                currentSegmentIndex++;
              }

              if (currentSegmentIndex < pathSegments.length) {
                PathSegment currentSegment = pathSegments[currentSegmentIndex];
                currentSegment.reset(); // Reset segment state

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
            if (!isDrawing) return;

            if (currentSegmentIndex < pathSegments.length) {
              checkSegmentProgress(details.localPosition);
            }
          },
          onPanEnd: (details) {
            setState(() {
              if (isDrawing &&
                  currentSegmentIndex < pathSegments.length &&
                  !pathSegments[currentSegmentIndex].isCompleted) {
                startClearAnimation();
              }
              isDrawing = false;
              lastValidPoint = null;
            });
          },
          child: Visibility(
            visible: !_showNextButton,
            child: AnimatedLetterPainter(
              pathSegments: pathSegments,
              currentSegmentIndex: currentSegmentIndex,
              clearProgress:
                  currentSegmentIndex < pathSegments.length ? pathSegments[currentSegmentIndex].clearProgress : 0.0,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }
}
