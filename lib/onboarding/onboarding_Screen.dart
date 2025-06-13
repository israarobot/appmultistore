import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<Color?> _gradientColorAnimation;

  @override
  void initState() {
    super.initState();

    // Gradient color animation
    _gradientController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _gradientColorAnimation = ColorTween(
      begin: Color(0xFF93441A).withOpacity(0.3),
      end: Colors.deepOrange.withOpacity(0.5),
    ).animate(
      CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed('/login');
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Background image without animation
            Image.asset(
              'assets/images/onboard.jpg',
              fit: BoxFit.cover,
            ),
            // Animated gradient overlay
            AnimatedBuilder(
              animation: _gradientColorAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _gradientColorAnimation.value!,
                      ],
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Scrollable Row for "CARTHAGE" text
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedLetter('C', 0, Colors.white, ElasticIn, fontSize: 50),
                        const SizedBox(width: 10),
                        _buildAnimatedLetter('A', 100, Colors.white, BounceIn, fontSize: 50),
                        const SizedBox(width: 10),
                        _buildAnimatedLetter('R', 200, Colors.white, ElasticIn, fontSize: 50),
                        const SizedBox(width: 10),
                        _buildAnimatedLetter('T', 300, Colors.white, BounceIn, fontSize: 50),
                        const SizedBox(width: 10),
                        _buildAnimatedLetter('H', 400, Color(0xFF93441A), ElasticIn, fontSize: 50),
                        const SizedBox(width: 10),
                        _buildAnimatedLetter('A', 500, Colors.white, BounceIn, fontSize: 50),
                        const SizedBox(width: 10),
                        _buildAnimatedLetter('G', 600, Colors.white, ElasticIn, fontSize: 50),
                        const SizedBox(width: 10),
                        _buildAnimatedLetter('E', 700, Color(0xFF93441A), BounceIn, fontSize: 50),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Scrollable Row for "STORE" text
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnimatedLetter('S', 800, Colors.white, ElasticIn, fontSize: 50),
                        const SizedBox(width: 10),
                        _buildAnimatedLetter('T', 900, Colors.white, BounceIn, fontSize: 50),
                        const SizedBox(width: 10),
                        _buildAnimatedLetter('O', 1000, Color(0xFF93441A), ElasticIn, fontSize: 50),
                        const SizedBox(width: 10),
                        _buildAnimatedLetter('R', 1100, Colors.white, BounceIn, fontSize: 50),
                        const SizedBox(width: 10),
                        _buildAnimatedLetter('E', 1200, Colors.white, ElasticIn, fontSize: 50),
                      ],
                    ),
                  ),
                  const SizedBox(height: 120),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Animated letter builder with custom fontSize
  Widget _buildAnimatedLetter(
    String letter,
    int delay,
    Color color,
    Type animationType, {
    double fontSize = 90, // default size for large headers
  }) {
    final textWidget = Text(
      letter,
      style: GoogleFonts.playfairDisplay(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 8,
            color: color.withOpacity(0.6),
            offset: const Offset(2, 2),
          ),
        ],
      ),
    );

    if (animationType == ElasticIn) {
      return ElasticIn(
        duration: const Duration(milliseconds: 800),
        delay: Duration(milliseconds: delay),
        child: textWidget,
      );
    } else if (animationType == BounceIn) {
      return BounceIn(
        duration: const Duration(milliseconds: 800),
        delay: Duration(milliseconds: delay),
        child: textWidget,
      );
    } else {
      return textWidget;
    }
  }
}