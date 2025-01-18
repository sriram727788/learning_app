import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kids_learning/service/audio_service.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> with SingleTickerProviderStateMixin {
  String currentLetter = 'A';
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late ScrollController _scrollController;
  late PageController _pageController;

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
// Darker shades of rainbow colors for letter buttons
  final List<Color> rainbowColors = [
    const Color(0xFFE05A5A), // Darker Red
    const Color(0xFFE69A3F), // Darker Orange
    const Color(0xFFE6D243), // Darker Yellow
    const Color(0xFF3FBF63), // Darker Green
    const Color(0xFF3A91E0), // Darker Blue
    const Color(0xFF9A3FE0), // Darker Purple
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
    AudioService.createPlayer('learning_screen');
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation =
        Tween<double>(begin: 1, end: 1.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _scrollController = ScrollController();
    _pageController = PageController();
  }

  void _playSound(String word) async {
    try {
      await AudioService.playAudio(
          "learning_screen", "sounds/${word.toLowerCase().replaceAll(" ", "")}.mp3", 0.8, ReleaseMode.release, (v) {});
      _controller.forward().then((_) => _controller.reverse());
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    AudioService.disposeAudio("learning_screen");
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

  void _updatePageController() {
    final index = letterWords.keys.toList().indexOf(currentLetter);
    if (index != -1) {
      _pageController.jumpToPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
                        color: Colors.purple.withValues(alpha: 0.3),
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
                              SizedBox(
                                height: 400,
                                width: double.infinity,
                                child: PageView.builder(
                                  itemBuilder: (context, index) {
                                    return Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        height: 350, // Height of the inner container
                                        width: 280,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(32),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.purple.withValues(alpha: 0.3), // Corrected the opacity setting
                                              blurRadius: 8,
                                              offset: const Offset(5, 5),
                                            )
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(32),
                                          child: Image.asset(
                                            'assets/images/${letterWords.values.elementAt(index).toLowerCase().replaceAll(" ", "")}.jpeg',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  onPageChanged: (value) {
                                    setState(() {
                                      currentLetter = letterWords.keys.elementAt(value);
                                    });
                                    _playSound(letterWords[currentLetter]!);
                                    scrollToSelectedLetter();
                                  },
                                  itemCount: letterWords.length,
                                  scrollDirection: Axis.horizontal,
                                  controller: _pageController,
                                ),
                              ),

                              // Enhanced sound button
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.purple.withValues(alpha: 0.3),
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
                      // Enhanced Letter and Word Display
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
                          _updatePageController();

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
                                      color: rainbowColors[index % rainbowColors.length].withValues(alpha: 0.3),
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
// import 'dart:math';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import 'package:kids_learning/service/audio_service.dart';

// // Separating constants for better maintainability
// class _Constants {
//   static const animationDuration = Duration(milliseconds: 300);
//   static const letterSize = 70.0;
//   static const letterSpacing = 80.0;
//   static const cardContainerHeight = 420.0; // Increased to accommodate FAB
//   static const imageSize = 350.0;
//   static const imageWidth = 280.0;

//   static const rainbowColors = [
//     Color(0xFFFF6B6B),
//     Color(0xFFFFB84D),
//     Color(0xFFFFED4D),
//     Color(0xFF4DFF7C),
//     Color(0xFF4DACFF),
//     Color(0xFFB84DFF),
//   ];

//   static const pastelRainbowColors = [
//     Color(0xFFFFB3BA),
//     Color(0xFFFFDFBA),
//     Color(0xFFFFFFBA),
//     Color(0xFFBAFFBA),
//     Color(0xFFBAE1FF),
//     Color(0xFFE8BAFF),
//   ];
// }

// // Separating data model
// class AlphabetItem {
//   final String letter;
//   final String word;
//   final String audioPath;
//   final String imagePath;

//   AlphabetItem({
//     required this.letter,
//     required this.word,
//     String? customAudioPath,
//     String? customImagePath,
//   })  : audioPath = customAudioPath ?? 'sounds/${word.toLowerCase().replaceAll(" ", "")}.mp3',
//         imagePath = customImagePath ?? 'assets/images/${word.toLowerCase().replaceAll(" ", "")}.jpeg';
// }

// class LearningScreen extends StatefulWidget {
//   const LearningScreen({super.key});

//   @override
//   State<LearningScreen> createState() => _LearningScreenState();
// }

// class _LearningScreenState extends State<LearningScreen> with SingleTickerProviderStateMixin {
//   // Using a more efficient data structure
//   static final List<AlphabetItem> _alphabetItems = [
//     AlphabetItem(letter: 'A', word: 'Apple'),
//     AlphabetItem(letter: 'B', word: 'Ball'),
//     //  Add remaining items
//     AlphabetItem(letter: 'Z', word: 'Zebra'),
//   ];

//   late final AnimationController _controller;
//   late final Animation<double> _scaleAnimation;
//   late final ScrollController _scrollController;
//   late final PageController _imagePageController;

//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _setupListeners();
//   }

//   void _initializeControllers() {
//     AudioService.createPlayer('learning_screen');

//     _controller = AnimationController(
//       duration: _Constants.animationDuration,
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(begin: 1, end: 1.2).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );

//     _scrollController = ScrollController();
//     _imagePageController = PageController();
//   }

//   void _setupListeners() {
//     _imagePageController.addListener(() {
//       final page = _imagePageController.page?.round() ?? 0;
//       if (_currentIndex != page) {
//         setState(() => _currentIndex = page);
//         _scrollToSelectedLetter();
//       }
//     });
//   }

//   void _scrollToSelectedLetter() {
//     _scrollController.animateTo(
//       _currentIndex * _Constants.letterSpacing,
//       duration: _Constants.animationDuration,
//       curve: Curves.easeInOut,
//     );
//   }

//   Future<void> _playSound(String word) async {
//     try {
//       await AudioService.playAudio(
//         "learning_screen",
//         _alphabetItems[_currentIndex].audioPath,
//         0.8,
//         ReleaseMode.release,
//       );
//       await _controller.forward();
//       await _controller.reverse();
//     } catch (e) {
//       debugPrint('Error playing sound: $e');
//     }
//   }

//   @override
//   void dispose() {
//     AudioService.disposeAudio("learning_screen");
//     _controller.dispose();
//     _imagePageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Color.fromARGB(255, 233, 138, 183), Color.fromARGB(255, 164, 199, 239)],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _buildHeader(),
//               Flexible(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20.0),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       _buildImagePageView(),
//                       const SizedBox(height: 40),
//                       _buildWordDisplay(),
//                     ],
//                   ),
//                 ),
//               ),
//               _buildLettersList(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Text(
//         "Let's Learn ABC!",
//         style: TextStyle(
//           fontSize: 32,
//           fontWeight: FontWeight.bold,
//           color: Colors.purple[700],
//           shadows: [
//             Shadow(
//               offset: const Offset(2.0, 2.0),
//               blurRadius: 3.0,
//               color: Colors.purple.withOpacity(0.3),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildImagePageView() {
//     return SizedBox(
//       height: _Constants.cardContainerHeight, // Use increased height
//       child: PageView.builder(
//         controller: _imagePageController,
//         itemCount: _alphabetItems.length,
//         onPageChanged: (index) {
//           setState(() => _currentIndex = index);
//           _playSound(_alphabetItems[index].word);
//         },
//         itemBuilder: (context, index) => _ImageCard(
//           item: _alphabetItems[index],
//           scaleAnimation: _scaleAnimation,
//           onSoundPlay: _playSound,
//         ),
//       ),
//     );
//   }

//   Widget _buildWordDisplay() {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 200),
//       transitionBuilder: (Widget child, Animation<double> animation) {
//         return FadeTransition(
//           opacity: animation,
//           child: child,
//         );
//       },
//       child: Text(
//         _alphabetItems[_currentIndex].word,
//         key: ValueKey<String>(_alphabetItems[_currentIndex].word), // Add key for animation
//         style: TextStyle(
//           fontSize: 70,
//           fontWeight: FontWeight.bold,
//           color: Colors.blue[700],
//         ),
//       ),
//     );
//   }

//   Widget _buildLettersList() {
//     return Container(
//       height: 150,
//       padding: const EdgeInsets.symmetric(vertical: 15),
//       decoration: const BoxDecoration(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
//       ),
//       child: ListView.builder(
//         controller: _scrollController,
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 10),
//         itemCount: _alphabetItems.length,
//         itemBuilder: (context, index) => _LetterCard(
//           item: _alphabetItems[index],
//           isSelected: _currentIndex == index,
//           onTap: () => _onLetterTap(index),
//           colorIndex: index,
//         ),
//       ),
//     );
//   }

//   void _onLetterTap(int index) {
//     setState(() => _currentIndex = index);
//     _imagePageController.animateToPage(
//       index,
//       duration: _Constants.animationDuration,
//       curve: Curves.easeInOut,
//     );
//     _playSound(_alphabetItems[index].word);
//   }
// }

// // Separated widget for better reusability and performance
// class _ImageCard extends StatelessWidget {
//   final AlphabetItem item;
//   final Animation<double> scaleAnimation;
//   final ValueChanged<String> onSoundPlay;

//   const _ImageCard({
//     required this.item,
//     required this.scaleAnimation,
//     required this.onSoundPlay,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ScaleTransition(
//       scale: scaleAnimation,
//       child: Stack(
//         clipBehavior: Clip.none,
//         alignment: Alignment.center,
//         children: [
//           _buildStars(),
//           Positioned(
//             top: 0,
//             child: _buildImage(),
//           ),
//           Positioned(
//             bottom: 20, // Adjusted position to be fully visible
//             right: 20,
//             child: _buildSoundButton(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildImage() {
//     return Container(
//       height: _Constants.imageSize,
//       width: _Constants.imageWidth,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(40),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.purple.withOpacity(0.3),
//             blurRadius: 25,
//             spreadRadius: 5,
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(32),
//         child: Image.asset(
//           item.imagePath,
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }

//   Widget _buildSoundButton() {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.purple.withOpacity(0.3),
//             blurRadius: 10,
//             spreadRadius: 2,
//           ),
//         ],
//       ),
//       child: FloatingActionButton(
//         onPressed: () => onSoundPlay(item.word),
//         backgroundColor: Colors.purple,
//         child: const Icon(
//           Icons.music_note,
//           color: Colors.white,
//           size: 30,
//         ),
//       ),
//     );
//   }

//   Widget _buildStars() {
//     return Stack(
//       children: List.generate(8, (index) {
//         return Positioned(
//           left: cos(index * pi / 4) * 140,
//           top: sin(index * pi / 4) * 140,
//           child: Transform.rotate(
//             angle: index * pi / 4,
//             child: Icon(
//               Icons.star,
//               size: 30,
//               color: _Constants.pastelRainbowColors[index % 6],
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }

// // Separated widget for better reusability and performance
// class _LetterCard extends StatelessWidget {
//   final AlphabetItem item;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final int colorIndex;

//   const _LetterCard({
//     required this.item,
//     required this.isSelected,
//     required this.onTap,
//     required this.colorIndex,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: isSelected ? 15 : 5),
//       child: GestureDetector(
//         onTap: onTap,
//         child: TweenAnimationBuilder<double>(
//           duration: const Duration(milliseconds: 200),
//           tween: Tween(
//             begin: 0.8,
//             end: isSelected ? 1.3 : 1.0,
//           ),
//           builder: (context, value, child) => Transform.scale(
//             scale: value,
//             child: Container(
//               width: _Constants.letterSize,
//               height: _Constants.letterSize,
//               margin: const EdgeInsets.symmetric(vertical: 14),
//               decoration: BoxDecoration(
//                 color: _Constants.rainbowColors[colorIndex % _Constants.rainbowColors.length],
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _Constants.rainbowColors[colorIndex % _Constants.rainbowColors.length].withOpacity(0.3),
//                     blurRadius: 8,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Center(
//                 child: Text(
//                   item.letter,
//                   style: const TextStyle(
//                     fontSize: 32,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
