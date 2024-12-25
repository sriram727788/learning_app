// // letter_tracing_page.dart
// import 'package:flutter/material.dart';
// import 'dart:math';

// class LetterTracingPage extends StatefulWidget {
//   const LetterTracingPage({super.key});

//   @override
//   State<LetterTracingPage> createState() => _LetterTracingPageState();
// }

// class _LetterTracingPageState extends State<LetterTracingPage> {
//   String currentLetter = 'A';

//   void moveToNextLetter() {
//     setState(() {
//       // Get next letter in alphabet
//       if (currentLetter == 'Z') {
//         currentLetter = 'A';
//       } else {
//         currentLetter = String.fromCharCode(currentLetter.codeUnitAt(0) + 1);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tracing Letter: $currentLetter'),
//       ),
//       body: Center(
//         child: LetterTracingGame(
//           letter: currentLetter,
//           onLetterCompleted: moveToNextLetter,
//         ),
//       ),
//     );
//   }
// }

// class LetterTracingGame extends StatefulWidget {
//   final String letter;
//   final VoidCallback onLetterCompleted;

//   const LetterTracingGame({
//     super.key,
//     required this.letter,
//     required this.onLetterCompleted,
//   });

//   @override
//   State<LetterTracingGame> createState() => _LetterTracingGameState();
// }

// class Dot {
//   final Offset position;
//   bool isConnected;

//   Dot(this.position, {this.isConnected = false});
// }

// // ... [Previous LetterTracingPage and other class definitions remain the same until _LetterTracingGameState] ...

// class _LetterTracingGameState extends State<LetterTracingGame> {
//   List<List<Dot>> strokeDots = [];
//   bool isDrawing = false;
//   int currentStrokeIndex = 0;
//   Dot? lastConnectedDot;

//   @override
//   void initState() {
//     super.initState();
//     initializeStrokeDots();
//   }

//   @override
//   void didUpdateWidget(LetterTracingGame oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.letter != widget.letter) {
//       resetGame();
//     }
//   }

//   void resetGame() {
//     setState(() {
//       currentStrokeIndex = 0;
//       lastConnectedDot = null;
//       initializeStrokeDots();
//     });
//   }

//   List<List<Offset>> getLetterStrokes(Size size, String letter) {
//     double centerX = size.width / 2;
//     double centerY = size.height / 2;
//     double letterHeight = size.height * 0.6;
//     double letterWidth = letterHeight * 0.8;

//     Map<String, List<List<Offset>>> letterStrokes = {
//       'A': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//       ],
//       'B': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.5),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 4),
//           Offset(centerX + letterWidth / 3, centerY),
//           Offset(centerX - letterWidth / 2, centerY),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY),
//           Offset(centerX + letterWidth / 3, centerY),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 4),
//           Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.5),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//       ],
//       'C': [
//         [
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
//           Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.2),
//           Offset(centerX, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 3, centerY - letterHeight / 3),
//           Offset(centerX - letterWidth / 2, centerY),
//           Offset(centerX - letterWidth / 3, centerY + letterHeight / 3),
//           Offset(centerX, centerY + letterHeight / 2),
//           Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
//         ],
//       ],
//       'D': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 4, centerY - letterHeight / 2.2),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
//           Offset(centerX + letterWidth * 0.6, centerY),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
//           Offset(centerX + letterWidth / 4, centerY + letterHeight / 2.2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//       ],
//       'E': [
//         [
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY),
//           Offset(centerX + letterWidth / 3, centerY),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
//         ],
//       ],
//       'F': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY),
//           Offset(centerX + letterWidth / 3, centerY),
//         ],
//       ],
//       'G': [
//         [
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
//           Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.2),
//           Offset(centerX, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 3, centerY - letterHeight / 3),
//           Offset(centerX - letterWidth / 2, centerY),
//           Offset(centerX - letterWidth / 3, centerY + letterHeight / 3),
//           Offset(centerX, centerY + letterHeight / 2),
//           Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
//         ],
//         [
//           Offset(centerX + letterWidth / 2, centerY),
//           Offset(centerX, centerY),
//         ],
//       ],
//       'H': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY),
//           Offset(centerX + letterWidth / 2, centerY),
//         ],
//       ],
//       'I': [
//         [
//           Offset(centerX, centerY - letterHeight / 2),
//           Offset(centerX, centerY + letterHeight / 2),
//         ],
//       ],
//       'J': [
//         [
//           Offset(centerX + letterWidth / 3, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 3, centerY + letterHeight / 4),
//           Offset(centerX + letterWidth / 4, centerY + letterHeight / 2.5),
//           Offset(centerX, centerY + letterHeight / 2),
//           Offset(centerX - letterWidth / 4, centerY + letterHeight / 2.5),
//           Offset(centerX - letterWidth / 3, centerY + letterHeight / 4),
//         ],
//       ],
//       'K': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
//         ],
//       ],
//       'L': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
//         ],
//       ],
//       'M': [
//         [
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX, centerY + letterHeight / 4),
//         ],
//         [
//           Offset(centerX, centerY + letterHeight / 4),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//         ],
//         [
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
//         ],
//       ],
//       'N': [
//         [
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//         ],
//       ],
//       'O': [
//         [
//           Offset(centerX, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 3, centerY - letterHeight / 2.2),
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 3),
//           Offset(centerX - letterWidth * 0.6, centerY),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 3),
//           Offset(centerX - letterWidth / 3, centerY + letterHeight / 2.2),
//           Offset(centerX, centerY + letterHeight / 2),
//           Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
//           Offset(centerX + letterWidth * 0.6, centerY),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
//           Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.2),
//           Offset(centerX, centerY - letterHeight / 2),
//         ],
//       ],
//       'P': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 3, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
//           Offset(centerX + letterWidth / 3, centerY),
//           Offset(centerX - letterWidth / 2, centerY),
//         ],
//       ],
//       'Q': [
//         [
//           Offset(centerX, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 3, centerY - letterHeight / 2.2),
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 3),
//           Offset(centerX - letterWidth * 0.6, centerY),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 3),
//           Offset(centerX - letterWidth / 3, centerY + letterHeight / 2.2),
//           Offset(centerX, centerY + letterHeight / 2),
//           Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
//           Offset(centerX + letterWidth * 0.6, centerY),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
//           Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.2),
//           Offset(centerX, centerY - letterHeight / 2),
//         ],
//         [
//           Offset(centerX, centerY + letterHeight / 6),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
//         ],
//       ],
//       'R': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 3, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
//           Offset(centerX + letterWidth / 3, centerY),
//           Offset(centerX - letterWidth / 2, centerY),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
//         ],
//       ],
//       'S': [
//         [
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 3),
//           Offset(centerX + letterWidth / 3, centerY - letterHeight / 2.2),
//           Offset(centerX, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 3, centerY - letterHeight / 2.2),
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 3),
//           Offset(centerX - letterWidth / 3, centerY - letterHeight / 6),
//           Offset(centerX, centerY),
//           Offset(centerX + letterWidth / 3, centerY + letterHeight / 6),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 3),
//           Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
//           Offset(centerX, centerY + letterHeight / 2),
//           Offset(centerX - letterWidth / 3, centerY + letterHeight / 2.2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 3),
//         ],
//       ],
//       'T': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//         ],
//         [
//           Offset(centerX, centerY - letterHeight / 2),
//           Offset(centerX, centerY + letterHeight / 2),
//         ],
//       ],
//       'U': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 4),
//           Offset(centerX - letterWidth / 3, centerY + letterHeight / 2.2),
//           Offset(centerX, centerY + letterHeight / 2),
//           Offset(centerX + letterWidth / 3, centerY + letterHeight / 2.2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 4),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//         ],
//       ],
//       'V': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX, centerY + letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//         ],
//       ],
//       'W': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 4, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 4, centerY + letterHeight / 2),
//           Offset(centerX, centerY - letterHeight / 4),
//         ],
//         [
//           Offset(centerX, centerY - letterHeight / 4),
//           Offset(centerX + letterWidth / 4, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX + letterWidth / 4, centerY + letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//         ],
//       ],
//       'X': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//       ],
//       'Y': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX, centerY),
//         ],
//         [
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX, centerY),
//         ],
//         [
//           Offset(centerX, centerY),
//           Offset(centerX, centerY + letterHeight / 2),
//         ],
//       ],
//       'Z': [
//         [
//           Offset(centerX - letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//         ],
//         [
//           Offset(centerX + letterWidth / 2, centerY - letterHeight / 2),
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//         ],
//         [
//           Offset(centerX - letterWidth / 2, centerY + letterHeight / 2),
//           Offset(centerX + letterWidth / 2, centerY + letterHeight / 2),
//         ],
//       ],
//     };

//     return letterStrokes[letter] ?? letterStrokes['A']!;
//   }

//   void initializeStrokeDots() {
//     Size size = const Size(300, 300);
//     List<List<Offset>> strokes = getLetterStrokes(size, widget.letter);
//     strokeDots = [];

//     for (var stroke in strokes) {
//       if (stroke.length == 2) {
//         // Simple straight line
//         strokeDots.add(createDotsAlongStroke(stroke[0], stroke[1]));
//       } else {
//         // Multiple points for curved lines
//         List<Dot> dots = [];
//         for (int i = 0; i < stroke.length - 1; i++) {
//           dots.addAll(createDotsAlongStroke(stroke[i], stroke[i + 1]));
//         }
//         strokeDots.add(dots);
//       }
//     }
//   }

//   List<Dot> createDotsAlongStroke(Offset start, Offset end) {
//     List<Dot> dots = [];
//     int numberOfDots = 5;

//     for (int i = 0; i < numberOfDots; i++) {
//       double t = i / (numberOfDots - 1);
//       Offset position = Offset(
//         start.dx + (end.dx - start.dx) * t,
//         start.dy + (end.dy - start.dy) * t,
//       );
//       dots.add(Dot(position));
//     }
//     return dots;
//   }

//   bool isPointNearDot(Offset point, Dot dot) {
//     const double threshold = 20.0;
//     return (point - dot.position).distance <= threshold;
//   }

//   void _checkDotsConnection(Offset point) {
//     if (currentStrokeIndex >= strokeDots.length) return;

//     List<Dot> currentDots = strokeDots[currentStrokeIndex];

//     for (int i = 0; i < currentDots.length; i++) {
//       if (!currentDots[i].isConnected && isPointNearDot(point, currentDots[i])) {
//         // Check if this is the next dot in sequence
//         if (i == 0 || currentDots[i - 1].isConnected) {
//           setState(() {
//             currentDots[i].isConnected = true;
//             lastConnectedDot = currentDots[i];
//           });

//           // Check if all dots in current stroke are connected
//           if (currentDots.every((dot) => dot.isConnected)) {
//             setState(() {
//               currentStrokeIndex++;
//               lastConnectedDot = null;

//               // Check if all strokes are completed
//               if (currentStrokeIndex >= strokeDots.length) {
//                 Future.delayed(const Duration(milliseconds: 500), () {
//                   widget.onLetterCompleted();
//                 });
//               }
//             });
//           }
//         }
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 300,
//       height: 300,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: GestureDetector(
//         onPanStart: (details) {
//           isDrawing = true;
//         },
//         onPanUpdate: (details) {
//           if (!isDrawing) return;
//           _checkDotsConnection(details.localPosition);
//         },
//         onPanEnd: (details) {
//           isDrawing = false;
//         },
//         child: CustomPaint(
//           painter: LetterPainter(
//             letter: widget.letter,
//             strokeDots: strokeDots,
//             currentStrokeIndex: currentStrokeIndex,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class LetterPainter extends CustomPainter {
//   final String letter;
//   final List<List<Dot>> strokeDots;
//   final int currentStrokeIndex;

//   LetterPainter({
//     required this.letter,
//     required this.strokeDots,
//     required this.currentStrokeIndex,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     // Draw connecting lines between connected dots
//     for (int strokeIndex = 0; strokeIndex < strokeDots.length; strokeIndex++) {
//       List<Dot> connectedDots = strokeDots[strokeIndex].where((dot) => dot.isConnected).toList();

//       if (connectedDots.length >= 2) {
//         final Paint linePaint = Paint()
//           ..color = Colors.blue
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 3;

//         final path = Path();
//         path.moveTo(connectedDots[0].position.dx, connectedDots[0].position.dy);

//         for (int i = 1; i < connectedDots.length; i++) {
//           path.lineTo(connectedDots[i].position.dx, connectedDots[i].position.dy);
//         }

//         canvas.drawPath(path, linePaint);
//       }
//     }

//     // Draw dots
//     for (int strokeIndex = 0; strokeIndex < strokeDots.length; strokeIndex++) {
//       for (var dot in strokeDots[strokeIndex]) {
//         final Paint dotPaint = Paint()
//           ..color = dot.isConnected ? Colors.blue : (strokeIndex == currentStrokeIndex ? Colors.green : Colors.grey)
//           ..style = PaintingStyle.fill;
//         canvas.drawCircle(dot.position, 6, dotPaint);
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

// // import 'package:flutter/material.dart';
// // import 'dart:math';

// // void main() {
// //   runApp(MaterialApp(
// //     home: LetterTracingPage(),
// //   ));
// // }

// // class LetterTracingPage extends StatefulWidget {
// //   const LetterTracingPage({Key? key}) : super(key: key);

// //   @override
// //   State<LetterTracingPage> createState() => _LetterTracingPageState();
// // }

// // class _LetterTracingPageState extends State<LetterTracingPage> {
// //   String currentLetter = 'A';

// //   void moveToNextLetter() {
// //     setState(() {
// //       if (currentLetter == 'Z') {
// //         currentLetter = 'A';
// //       } else {
// //         currentLetter = String.fromCharCode(currentLetter.codeUnitAt(0) + 1);
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Learn to Write: $currentLetter'),
// //         backgroundColor: Colors.blue.shade100,
// //       ),
// //       body: Container(
// //         decoration: BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //             colors: [Colors.blue.shade50, Colors.white],
// //           ),
// //         ),
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Text(
// //                 'Trace the letter',
// //                 style: TextStyle(
// //                   fontSize: 24,
// //                   color: Colors.blue.shade900,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               const SizedBox(height: 20),
// //               LetterTracingGame(
// //                 letter: currentLetter,
// //                 onLetterCompleted: moveToNextLetter,
// //               ),
// //               const SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: () => resetGame(),
// //                 child: const Text('Reset'),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: Colors.blue.shade100,
// //                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   void resetGame() {
// //     setState(() {
// //       // This will trigger didUpdateWidget in LetterTracingGame
// //       currentLetter = currentLetter;
// //     });
// //   }
// // }

// // class LetterTracingGame extends StatefulWidget {
// //   final String letter;
// //   final VoidCallback onLetterCompleted;

// //   const LetterTracingGame({
// //     Key? key,
// //     required this.letter,
// //     required this.onLetterCompleted,
// //   }) : super(key: key);

// //   @override
// //   State<LetterTracingGame> createState() => _LetterTracingGameState();
// // }

// // class Segment {
// //   final Path path;
// //   bool isCompleted;
// //   final List<Offset> checkpoints;
// //   int currentCheckpointIndex;

// //   Segment(this.path, this.checkpoints)
// //       : isCompleted = false,
// //         currentCheckpointIndex = 0;
// // }

// // class _LetterTracingGameState extends State<LetterTracingGame> {
// //   List<Segment> segments = [];
// //   bool isDrawing = false;
// //   Offset? currentPosition;
// //   double progress = 0.0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     initializeLetterSegments();
// //   }

// //   @override
// //   void didUpdateWidget(LetterTracingGame oldWidget) {
// //     super.didUpdateWidget(oldWidget);
// //     if (oldWidget.letter != widget.letter) {
// //       resetGame();
// //     }
// //   }

// //   void resetGame() {
// //     setState(() {
// //       initializeLetterSegments();
// //       progress = 0.0;
// //     });
// //   }

// //   void initializeLetterSegments() {
// //     segments = createLetterSegments(widget.letter);
// //   }

// //   List<Segment> createLetterSegments(String letter) {
// //     Size size = const Size(300, 300);
// //     double centerX = size.width / 2;
// //     double centerY = size.height / 2;
// //     double letterHeight = size.height * 0.6;
// //     double letterWidth = letterHeight * 0.6;
// //     double strokeWidth = letterHeight * 0.15;

// //     List<Segment> letterSegments = [];

// //     switch (letter) {
// //       case 'A':
// //         // Left diagonal
// //         {
// //           Path path = Path();
// //           path.moveTo(centerX - letterWidth / 2, centerY + letterHeight / 2);
// //           path.lineTo(centerX, centerY - letterHeight / 2);

// //           List<Offset> checkpoints = List.generate(
// //             5,
// //             (i) {
// //               double t = i / 4;
// //               return Offset(
// //                 centerX - letterWidth / 2 + letterWidth / 2 * t,
// //                 centerY + letterHeight / 2 - letterHeight * t,
// //               );
// //             },
// //           );

// //           letterSegments.add(Segment(path, checkpoints));
// //         }

// //         // Right diagonal
// //         {
// //           Path path = Path();
// //           path.moveTo(centerX, centerY - letterHeight / 2);
// //           path.lineTo(centerX + letterWidth / 2, centerY + letterHeight / 2);

// //           List<Offset> checkpoints = List.generate(
// //             5,
// //             (i) {
// //               double t = i / 4;
// //               return Offset(
// //                 centerX + letterWidth / 2 * t,
// //                 centerY - letterHeight / 2 + letterHeight * t,
// //               );
// //             },
// //           );

// //           letterSegments.add(Segment(path, checkpoints));
// //         }

// //         // Middle bar
// //         {
// //           Path path = Path();
// //           path.moveTo(centerX - letterWidth / 3, centerY);
// //           path.lineTo(centerX + letterWidth / 3, centerY);

// //           List<Offset> checkpoints = List.generate(
// //             5,
// //             (i) {
// //               double t = i / 4;
// //               return Offset(
// //                 centerX - letterWidth / 3 + (2 * letterWidth / 3) * t,
// //                 centerY,
// //               );
// //             },
// //           );

// //           letterSegments.add(Segment(path, checkpoints));
// //         }
// //         break;

// //       // Add more letters following the same pattern...
// //       default:
// //         // Default to 'A' if letter not implemented
// //         return createLetterSegments('A');
// //     }

// //     return letterSegments;
// //   }

// //   bool isNearCheckpoint(Offset point, Offset checkpoint) {
// //     return (point - checkpoint).distance < 20.0;
// //   }

// //   void _handlePanUpdate(DragUpdateDetails details) {
// //     if (!isDrawing) return;

// //     setState(() {
// //       currentPosition = details.localPosition;

// //       for (var segment in segments) {
// //         if (segment.isCompleted) continue;

// //         if (segment.currentCheckpointIndex < segment.checkpoints.length &&
// //             isNearCheckpoint(details.localPosition, segment.checkpoints[segment.currentCheckpointIndex])) {
// //           segment.currentCheckpointIndex++;

// //           if (segment.currentCheckpointIndex == segment.checkpoints.length) {
// //             segment.isCompleted = true;
// //             // Calculate overall progress
// //             progress = segments.where((s) => s.isCompleted).length / segments.length;

// //             if (progress == 1.0) {
// //               Future.delayed(const Duration(milliseconds: 500), () {
// //                 widget.onLetterCompleted();
// //               });
// //             }
// //           }
// //         }
// //       }
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: 300,
// //       height: 300,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(15),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.blue.shade100,
// //             blurRadius: 10,
// //             spreadRadius: 2,
// //           ),
// //         ],
// //       ),
// //       child: GestureDetector(
// //         onPanStart: (details) {
// //           setState(() {
// //             isDrawing = true;
// //             currentPosition = details.localPosition;
// //           });
// //         },
// //         onPanUpdate: _handlePanUpdate,
// //         onPanEnd: (details) {
// //           setState(() {
// //             isDrawing = false;
// //             currentPosition = null;
// //           });
// //         },
// //         child: Stack(
// //           children: [
// //             CustomPaint(
// //               painter: LetterPainter(
// //                 letter: widget.letter,
// //                 segments: segments,
// //                 currentPosition: currentPosition,
// //                 progress: progress,
// //               ),
// //             ),
// //             Positioned(
// //               top: 10,
// //               right: 10,
// //               child: Container(
// //                 padding: const EdgeInsets.all(8),
// //                 decoration: BoxDecoration(
// //                   color: Colors.blue.shade50,
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //                 child: Text(
// //                   '${(progress * 100).toInt()}%',
// //                   style: TextStyle(
// //                     color: Colors.blue.shade900,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class LetterPainter extends CustomPainter {
// //   final String letter;
// //   final List<Segment> segments;
// //   final Offset? currentPosition;
// //   final double progress;

// //   LetterPainter({
// //     required this.letter,
// //     required this.segments,
// //     this.currentPosition,
// //     required this.progress,
// //   });

// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     // Draw hollow letter
// //     for (var segment in segments) {
// //       final Paint hollowPaint = Paint()
// //         ..color = Colors.grey.shade300
// //         ..style = PaintingStyle.stroke
// //         ..strokeWidth = 15;
// //       canvas.drawPath(segment.path, hollowPaint);
// //     }

// //     // Draw completed segments
// //     for (var segment in segments) {
// //       if (segment.isCompleted) {
// //         final Paint completedPaint = Paint()
// //           ..color = Colors.blue
// //           ..style = PaintingStyle.stroke
// //           ..strokeWidth = 15
// //           ..strokeCap = StrokeCap.round;
// //         canvas.drawPath(segment.path, completedPaint);
// //       } else if (segment.currentCheckpointIndex > 0) {
// //         // Draw partially completed segment
// //         final Paint progressPaint = Paint()
// //           ..color = Colors.blue
// //           ..style = PaintingStyle.stroke
// //           ..strokeWidth = 15
// //           ..strokeCap = StrokeCap.round;

// //         final Path progressPath = Path();
// //         progressPath.moveTo(
// //           segment.checkpoints[0].dx,
// //           segment.checkpoints[0].dy,
// //         );

// //         for (int i = 1; i < segment.currentCheckpointIndex; i++) {
// //           progressPath.lineTo(
// //             segment.checkpoints[i].dx,
// //             segment.checkpoints[i].dy,
// //           );
// //         }

// //         canvas.drawPath(progressPath, progressPaint);
// //       }
// //     }

// //     // Draw current position indicator
// //     if (currentPosition != null) {
// //       final Paint currentPaint = Paint()
// //         ..color = Colors.blue.shade200
// //         ..style = PaintingStyle.fill;
// //       canvas.drawCircle(currentPosition!, 10, currentPaint);
// //     }

// //     // Draw checkpoints for debugging (comment out in production)
// //     // for (var segment in segments) {
// //     //   for (var checkpoint in segment.checkpoints) {
// //     //     final Paint checkpointPaint = Paint()
// //     //       ..color = Colors.red.withOpacity(0.3)
// //     //       ..style = PaintingStyle.fill;
// //     //     canvas.drawCircle(checkpoint, 10, checkpointPaint);
// //     //   }
// //     // }
// //   }

// //   @override
// //   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// // }