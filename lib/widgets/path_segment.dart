import 'dart:ui';

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
  int progressIndex = 0;
  List<bool> pointsVisited;

  PathSegment(this.path, this.points) : pointsVisited = List.filled(points.length, false) {
    length = calculatePathLength();
  }

  void reset() {
    progressIndex = 0;
    progress = 0.0;
    clearProgress = 0.0;
    isClearing = false; // Reset clearing state
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
