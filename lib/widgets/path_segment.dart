import 'dart:ui';

/* class PathSegment {
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
 */

class PathSegment {
  final Path path;
  final List<Offset> points;
  bool isCompleted = false;
  bool isClearing = false;
  double progress = 0.0;
  double clearProgress = 0.0;
  List<Offset> currentTrace = [];
  bool wasStartedCorrectly = false;
  double length = 0;
  int progressIndex = 0; // Track exact progress position
  List<bool> pointsVisited; // Track which points have been visited

  PathSegment(this.path, this.points) : pointsVisited = List.filled(points.length, false) {
    length = calculatePathLength();
  }

  void reset() {
    progressIndex = 0;
    progress = 0.0;
    currentTrace.clear();
    pointsVisited = List.filled(points.length, false);
    wasStartedCorrectly = false;
  }

  double calculatePathLength() {
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
    }
    return total;
  }
}
