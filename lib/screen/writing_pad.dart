import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:kids_learning/screen/letter_tracing_screen.dart';

class WritingPad extends StatefulWidget {
  // Change to StatefulWidget
  final String letter;

  const WritingPad({
    super.key,
    required this.letter,
  });

  @override
  State<WritingPad> createState() => _WritingPadState();
}

class _WritingPadState extends State<WritingPad> with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late Animation<double> _buttonAnimation;
  late AnimationController _buttonController;

  bool _showNextButton = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _buttonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  void onLetterComplete() {
    _confettiController.play();
    _buttonController.forward();
    setState(() {
      _showNextButton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Write "${widget.letter}"',
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
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        width: 400,
                        height: 400,
                        child: LetterTracingScreen(
                          letter: widget.letter,
                          onLetterCompleted: onLetterComplete, // Pass the callback here
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Follow the dotted line to write "${widget.letter}"',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Comic Sans MS',
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: math.pi / 2,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 40,
                  gravity: 0.1,
                ),
              ),
              if (_showNextButton)
                Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: InkWell(
                    onTap: () {
                      String nextLetter = String.fromCharCode(widget.letter.codeUnitAt(0) + 1);
                      if (nextLetter == '[' || nextLetter == ':') {
                        Navigator.of(context).pop();
                        return;
                      }
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => WritingPad(letter: nextLetter),
                        ),
                      );
                    },
                    child: FadeTransition(
                      opacity: _buttonAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: Offset.zero,
                        ).animate(_buttonAnimation),
                        child: Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(bottom: 80),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
