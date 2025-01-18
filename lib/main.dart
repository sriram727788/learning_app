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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  void _playSound() async {
    // Start the player as soon as the app is displayed.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AudioService.playAudio("main_bg", 'sounds/bg_music.mp3', 0.005, ReleaseMode.loop, (onComplete) {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AudioService.pauseAudio("main_bg");
    } else if (state == AppLifecycleState.resumed) {
      AudioService.resumeAudio("main_bg");
    }
  }

  @override
  void initState() {
    _playSound();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
