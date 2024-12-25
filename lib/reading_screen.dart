import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String currentLetter = 'A';
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late ScrollController _scrollController;

  final Map<String, String> letterWords = {
    'A': 'Apple',
    'B': 'Ball',
    'C': 'Cat',
    'D': 'Dog',
    'E': 'Elephant',
    'F': 'Fish',
    'G': 'Giraffe',
    'H': 'Horse',
    'I': 'Ice Cream',
    'J': 'Joker',
    'K': 'Kangaroo',
    'L': 'Lion',
    'M': 'Monkey',
    'N': 'Nest',
    'O': 'Owl',
    'P': 'Penguin',
    'Q': 'Queen',
    'R': 'Rose',
    'S': 'Ship',
    'T': 'Tiger',
    'U': 'Umbrella',
    'V': 'Violin',
    'W': 'Wolf',
    'X': 'Xmas',
    'Y': 'Yak',
    'Z': 'Zebra'
  };

  // Rainbow colors for letter buttons
  final List<Color> rainbowColors = [
    const Color(0xFFFF6B6B), // Red
    const Color(0xFFFFB84D), // Orange
    const Color(0xFFFFED4D), // Yellow
    const Color(0xFF4DFF7C), // Green
    const Color(0xFF4DACFF), // Blue
    const Color(0xFFB84DFF), // Purple
  ];

  final List<Color> pastelRainbowColors = [
    const Color(0xFFFFB3BA), // Pastel Red
    const Color(0xFFFFDFBA), // Pastel Orange
    const Color(0xFFFFFFBA), // Pastel Yellow
    const Color(0xFFBAFFBA), // Pastel Green
    const Color(0xFFBAE1FF), // Pastel Blue
    const Color(0xFFE8BAFF), // Pastel Purple
  ];
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation =
        Tween<double>(begin: 1, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _scrollController = ScrollController();
  }

  void _playSound(String word) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/${word.toLowerCase().replaceAll(" ", "")}.mp3'));
      _controller.forward().then((_) => _controller.reverse());
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  void scrollToSelectedLetter() {
    final index = letterWords.keys.toList().indexOf(currentLetter);
    if (index != -1) {
      _scrollController.animateTo(
        index * 80.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // More playful background with bubbles pattern
          // image: DecorationImage(
          //   image: AssetImage('assets/images/bubble_background.png'), // Add a subtle bubble pattern background
          //   fit: BoxFit.cover,
          // ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 233, 138, 183), Color.fromARGB(255, 164, 199, 239)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Add a fun header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Let's Learn ABC!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[700],
                    shadows: [
                      Shadow(
                        offset: const Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.purple.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced Image Container
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: GestureDetector(
                          onTap: () => _playSound(letterWords[currentLetter]!),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Add decorative elements around the image
                              ...List.generate(8, (index) {
                                return Positioned(
                                  left: cos(index * pi / 4) * 140,
                                  top: sin(index * pi / 4) * 140,
                                  child: Transform.rotate(
                                    angle: index * pi / 4,
                                    child: Icon(
                                      Icons.star,
                                      size: 30,
                                      color: pastelRainbowColors[index % 6],
                                    ),
                                  ),
                                );
                              }),
                              Container(
                                height: 350,
                                width: 280,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.3),
                                      blurRadius: 25,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Image.asset(
                                    'assets/images/${letterWords[currentLetter]!.toLowerCase().replaceAll(" ", "")}.jpeg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                              ),
                              // Enhanced sound button
                              Positioned(
                                bottom: -30,
                                right: 20,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: FloatingActionButton(
                                    onPressed: () => _playSound(letterWords[currentLetter]!),
                                    backgroundColor: Colors.purple,
                                    child: const Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Enhanced Letter and Word Display
                      Column(
                        children: [
                          // Text(
                          //   currentLetter,
                          //   style: TextStyle(
                          //     fontSize: 100,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.purple[700],
                          //     fontFamily: 'Comic Sans MS',
                          //   ),
                          // ),
                          const SizedBox(height: 15),
                          GestureDetector(
                            onTap: () => scrollToSelectedLetter(),
                            child: Text(
                              letterWords[currentLetter]!,
                              style: TextStyle(
                                fontSize: 70,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Enhanced Letter Selection Area
              Container(
                height: 150,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: letterWords.length,
                  itemBuilder: (context, index) {
                    final letter = letterWords.keys.elementAt(index);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: currentLetter == letter ? 15 : 5),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            currentLetter = letter;
                          });
                          _playSound(letterWords[currentLetter]!);

                          _controller.forward().then((_) => _controller.reverse());
                        },
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 200),
                          tween: Tween(
                            begin: 0.8,
                            end: currentLetter == letter ? 1.3 : 1.0,
                          ),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Container(
                                width: 70,
                                height: 70, // Added fixed height
                                margin: const EdgeInsets.symmetric(vertical: 14), // Added margin
                                decoration: BoxDecoration(
                                  color: rainbowColors[index % rainbowColors.length],
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: rainbowColors[index % rainbowColors.length].withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
