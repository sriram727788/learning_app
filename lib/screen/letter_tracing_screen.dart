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
  double _scale = 20.0;
  Offset _offset = Offset.zero;
  static const double threshold = 50;

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

  void _calculateScaleAndOffset(Size screenSize) {
    // Original viewport size is 450x450
    const originalSize = 450.0;

    // Calculate scale based on screen width with some padding
    _scale = (screenSize.width) / (originalSize - 50);

    // Calculate center offset
    _offset = Offset((screenSize.width - (originalSize * _scale)) / 2, 0);
  }

  // Modified method to transform points based on scale and offset
  Offset _transformPoint(Offset point) {
    return (point - _offset) / _scale;
  }

  void startClearAnimation() {
    if (currentSegmentIndex >= pathSegments.length) return;

    PathSegment segment = pathSegments[currentSegmentIndex];
    if (segment.isClearing) return;

    setState(() {
      segment.isClearing = true;
      segment.clearProgress = 1.0;

      // Schedule the reset after animation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            segment.reset();
            lastValidPoint = null;
            // Don't set isDrawing here - let it be controlled by touch events
          });
        }
      });
    });
  }

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

  bool isPointNearPath(Offset point, List<Offset> pathPoints, {bool checkDirection = true}) {
    if (pathPoints.isEmpty) return false;

    PathSegment currentSegment = pathSegments[currentSegmentIndex];
    Offset transformedPoint = _transformPoint(point);

    // For initial touch, only check near the start
    if (!isDrawing || !checkDirection) {
      int startRange = (pathPoints.length * 0.1).round(); // 10% of path length
      double minStartDistance = double.infinity;
      int startIndex = -1;

      for (int i = 0; i < startRange; i++) {
        double distance = (transformedPoint - pathPoints[i]).distance;
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
      double distance = (transformedPoint - pathPoints[i]).distance;
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
    /* final Map<String, List<String>> letterPaths = {
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
        'M300,80 L140,80 L140,200',
        'M140,200 Q200,180 240,180 A67,67 0 0,1 240,350 Q200,350 190,350 Q140,340 140,320'
      ],
      '6': [
        'M300,140 Q300,80 260,80 L180,80 Q140,80 140,140 L140,300 Q140,360 180,360 L260,360 Q300,360 300,300 L300,280 Q300,220 260,220 L180,220'
      ],
      '7': ['M140,80 L280,80', 'M280,80 L160,360'],
      '8': [
        'M200,80 Q120,80 120,140 Q120,220 200,220 Q280,220 280,300 Q280,360 200,360 Q120,360 120,300 Q120,220 200,220 Q280,220 280,140 Q280,80 200,80',
      ],
      '9': [
        'M260,220 260,220 L180,220 Q140,220 140,180 L140,140 Q140,80 180,80 L260,80 Q300,80 300,140 L300,300 Q300,360 260,360 L180,360 Q140,360 140,300'
      ]
    }; */
    final Map<String, List<String>> letterPaths = {
      'A': [
        'M225,45 L90,405', // Left diagonal
        'M225,45 L360,405', // Right diagonal
        'M135,270 L315,270' // Cross bar
      ],
      'B': [
        'M135,45 L135,405', // Vertical line
        'M135,45 195,45 A75,75 0 0,1 195,225 L135,225', // Top curve
        'M135,225 225,225 A75,75 0 0,1 225,405 L135,405', // Bottom curve
      ],
      'C': ['M360,135 Q360,45 270,45 Q90,45 90,225 Q90,405 270,405 Q360,405 360,315'],
      'D': [
        'M135,45 L135,405', // Vertical line
        'M135,45 Q330,45 330,225 Q330,405 135,405' // Curved side
      ],
      'E': [
        'M135,45 L135,405', // Vertical line
        'M135,45 L315,45', // Top line
        'M135,225 L270,225', // Middle line
        'M135,405 L315,405' // Bottom line
      ],
      'F': [
        'M135,45 L135,405', // Vertical line
        'M135,45 L315,45', // Top line
        'M135,225 L270,225' // Middle line
      ],
      'G': [
        'M360,135 Q360,45 270,45 L225,45 A75,75 0 0,0 270,405 Q360,405 360,225 L225,225' // Middle line
      ],
      'H': [
        'M113,45 L113,405', // Left vertical
        'M338,45 L338,405', // Right vertical
        'M113,225 L338,225' // Middle line
      ],
      'I': [
        'M225,45 L225,405', // Vertical line
        'M135,45 L315,45', // Top line
        'M135,405 L315,405' // Bottom line
      ],
      'J': [
        'M180,45 L338,45',
        'M270,45 L270,315 270,315 Q270,405 203,405 Q113,405 113,315' // Bottom curve
      ],
      'K': [
        'M135,45 L135,405', // Vertical line
        'M338,45 L135,225', // Upper diagonal
        'M135,225 L338,405' // Lower diagonal
      ],
      'L': [
        'M135,45 L135,405', // Vertical line
        'M135,405 L315,405' // Bottom line
      ],
      'M': [
        'M113,45 L113,405', // Left vertical
        'M113,45 L225,225', // Left diagonal
        'M225,225 L338,45', // Right diagonal
        'M338,45 L338,405' // Right vertical
      ],
      'N': [
        'M135,45 L135,405', // Left vertical
        'M135,45 L315,405', // Diagonal
        'M315,405 L315,45' // Right vertical
      ],
      'O': ['M225,45 Q113,45 113,225 Q113,405 225,405 Q338,405 338,225 Q338,45 225,45'],
      'P': [
        'M135,45 L135,405', // Vertical line
        'M135,45 225,45 A75,75 0 0,1 225,225 L135,225', // Top curve
      ],
      'Q': [
        'M225,45 Q113,45 113,225 Q113,405 225,405 Q338,405 338,225 Q338,45 225,45',
        'M270,360 L338,428' // Tail
      ],
      'R': [
        'M135,45 L135,405', // Vertical line
        'M135,45 225,45 A75,75 0 0,1 225,225 L135,225', // Top curve
        'M225,225 L315,405' // Diagonal
      ],
      'S': [
        'M315,135 Q315,45 225,45 Q135,45 135,135 Q135,225 225,225 Q315,225 315,315 Q315,405 225,405 Q135,405 135,315'
      ],
      'T': [
        'M225,45 L225,405', // Vertical line
        'M113,45 L338,45' // Top line
      ],
      'U': ['M113,45 L113,315 Q113,405 225,405 Q338,405 338,315 L338,45'],
      'V': [
        'M113,45 L225,405', // Left diagonal
        'M338,45 L225,405' // Right diagonal
      ],
      'W': [
        'M90,45 L135,405', // First diagonal
        'M135,405 L225,225', // Middle peak
        'M225,225 L315,405', // Second diagonal
        'M315,405 L360,45' // Last diagonal
      ],
      'X': [
        'M100,45 L350,405', // Forward diagonal
        'M350,45 L100 ,405' // Backward diagonal
      ],
      'Y': [
        'M100,45 L225,250', // Left diagonal
        'M350,45 L225,250', // Right diagonal
        'M225,250 L225,405' // Bottom vertical
      ],
      'Z': [
        'M135,45 L315,45', // Top line
        'M315,45 L135,405', // Diagonal
        'M135,405 L315,405' // Bottom line
      ],
      '0': ['M225,45 Q135,45 135,225 Q135,405 225,405 Q315,405 315,225 Q315,45 225,45'],
      '1': ['M150,105 L225,45', 'M225,45 L225,405', 'M150,405 300,405'],
      '2': [
        'M158,135 Q158,45 203,45 L293,45 Q338,45 338,135 L338,180 Q338,225 293,225 L203,225 Q158,225 158,270 L158,405 L338,405'
      ],
      '3': [
        'M158,135 Q158,45 225,45 Q293,45 293,135 Q293,225 225,225',
        'M225,225 Q293,225 293,315 Q293,405 225,405 Q158,405 158,315'
      ],
      '4': ['M270,45 L135,270', 'M135,270 L315,270', 'M270,45 L270,405'],
      '5': [
        'M338,45 L158,45 L158,180',
        'M158,180 Q225,158 270,158 A75,75 0 0,1 270,394 Q225,394 214,394 Q158,383 158,315'
      ],
      '6': [
        'M338,135 Q338,45 293,45 L203,45 Q158,45 158,135 L158,315 Q158,405 203,405 L293,405 Q338,405 338,315 L338,270 Q338,225 293,225 L203,225'
      ],
      '7': ['M158,45 L315,45', 'M315,45 L180,405'],
      '8': [
        'M225,45 Q135,45 135,135 Q135,225 225,225 Q315,225 315,315 Q315,405 225,405 Q135,405 135,315 Q135,225 225,225 Q315,225 315,135 Q315,45 225,45',
      ],
      '9': [
        'M293,225 293,225 L203,225 Q158,225 158,180 L158,135 Q158,45 203,45 L293,45 Q338,45 338,135 L338,315 Q338,405 293,405 L203,405 Q158,405 158,315'
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

  void onPanStart(DragStartDetails details) {
    setState(() {
      // Find first uncompleted segment
      while (currentSegmentIndex < pathSegments.length && pathSegments[currentSegmentIndex].isCompleted) {
        currentSegmentIndex++;
      }

      if (currentSegmentIndex < pathSegments.length) {
        PathSegment currentSegment = pathSegments[currentSegmentIndex];

        // Only reset if not currently clearing
        if (!currentSegment.isClearing) {
          currentSegment.reset();
        }

        // Check if the touch point is valid for starting
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
  }

  void onPanUpdate(DragUpdateDetails details) {
    // Allow updates only if we're drawing and not clearing
    if (!isDrawing || (currentSegmentIndex < pathSegments.length && pathSegments[currentSegmentIndex].isClearing)) {
      return;
    }

    if (currentSegmentIndex < pathSegments.length) {
      checkSegmentProgress(details.localPosition);
    }
  }

  void onPanEnd(DragEndDetails details) {
    setState(() {
      if (isDrawing && currentSegmentIndex < pathSegments.length && !pathSegments[currentSegmentIndex].isCompleted) {
        startClearAnimation();
      }
      isDrawing = false;
      lastValidPoint = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    _calculateScaleAndOffset(screenSize);

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
                      size: Size(450 * _scale, 450 * _scale),
                      painter: LetterPainter(
                        pathSegments: pathSegments,
                        currentSegmentIndex: currentSegmentIndex,
                        clearProgress: currentSegmentIndex < pathSegments.length
                            ? pathSegments[currentSegmentIndex].clearProgress
                            : 0.0,
                        animationValue: 0,
                        scale: _scale,
                        offset: _offset,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        GestureDetector(
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: Visibility(
            visible: !_showNextButton,
            child: AnimatedLetterPainter(
              pathSegments: pathSegments,
              currentSegmentIndex: currentSegmentIndex,
              clearProgress:
                  currentSegmentIndex < pathSegments.length ? pathSegments[currentSegmentIndex].clearProgress : 0.0,
              scale: _scale,
              offset: _offset,
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
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 50,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }
}
