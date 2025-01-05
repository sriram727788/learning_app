import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kids_learning/screen/reading_screen.dart';
import 'package:kids_learning/screen/writing_screen.dart';
import 'package:kids_learning/service/audio_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
    ),
  );

  AudioService.createPlayer("main_bg");
  // edge-to-edge display
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _playSound() async {
    // Start the player as soon as the app is displayed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AudioService.playAudio("main_bg", 'sounds/bg_music.mp3', 0.1, ReleaseMode.loop);
    });
  }

  @override
  void initState() {
    _playSound();
    super.initState();
  }

  @override
  void dispose() {
    AudioService.disposeAllPlayers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[200]!,
              Colors.purple[100]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              // App Title
              Text(
                'Learn & Play! 🎨',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 40),
              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.count(
                    crossAxisCount: 1,
                    childAspectRatio: 1.5,
                    mainAxisSpacing: 20,
                    children: [
                      _buildCard(
                        context,
                        'Reading Fun',
                        'assets/images/learning.jpeg',
                        Colors.orange[100]!,
                        Colors.deepOrange,
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LearningScreen(),
                          ),
                        ),
                      ),
                      _buildCard(
                        context,
                        'Writing Time',
                        'assets/images/writing.jpeg',
                        Colors.green[100]!,
                        Colors.green,
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WritingScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    String imagePath,
    Color backgroundColor,
    Color borderColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids Learning App',
      theme: ThemeData(
        fontFamily: 'ComicNeue',
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}



      /* 'A': [
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
   */