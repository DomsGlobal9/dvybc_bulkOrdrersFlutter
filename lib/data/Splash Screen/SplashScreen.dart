import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0; // 0 = first content, 1 = second content

  // Animation controllers
  late AnimationController _logoAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _contentAnimationController;
  late AnimationController _progressAnimationController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _contentFadeAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller (for the initial logo sequence)
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Fade controller for transitioning from the logo screen to the onboarding screen
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Content change animation controller (for switching between step 0 and 1)
    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // --- CORRECTED --- Progress bar animation controller (faster 0.5-second duration)
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));

    // Logo fade animation
    _logoFadeAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30.0,
      ),
    ]).animate(_logoAnimationController);

    // General fade animation for the onboarding screen
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    ));

    // Content fade animation for smooth transitions
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeInOut,
    ));

    // Progress bar fill animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSplashSequence() async {
    // Start initial logo animation
    _logoAnimationController.forward();

    // Wait for logo to finish before showing onboarding
    await Future.delayed(const Duration(milliseconds: 3200));

    // Fade in the onboarding content
    _fadeAnimationController.forward();
    _contentAnimationController.forward();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      setState(() {
        _currentStep = 1;
      });

      // Animate the content change
      _contentAnimationController.forward(from: 0.0);

      // Animate the progress bar to fill
      _progressAnimationController.forward(from: 0.0);
    } else {
      // This case is handled by the "Start" button, but as a fallback
      _startApp();
    }
  }

  void _startApp() async {
    // In a real app, you would check the actual login state.
    // For now, we'll always navigate to the login page as per your original code.
    Get.offAllNamed('/login');
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _fadeAnimationController.dispose();
    _contentAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _fadeAnimationController,
        builder: (context, child) {
          // If the fade controller hasn't started, show the logo. Otherwise, show onboarding.
          return _fadeAnimationController.isAnimating || _fadeAnimationController.value > 0
              ? _buildOnboardingContent()
              : _buildLogoScreen();
        },
      ),
    );
  }

  Widget _buildLogoScreen() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6)],
            ),
          ),
          child: Center(
            child: FadeTransition(
              opacity: _logoFadeAnimation,
              child: ScaleTransition(
                scale: _logoScaleAnimation,
                child: Image.asset(
                  'assets/images/DVYBL.png',
                  width: 200,
                  height: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOnboardingContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const SizedBox(height: 80),
            Image.asset(
              'assets/images/DVYBL.png',
              width: 120,
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 30),
            _buildAnimatedProgressIndicator(),
            Expanded(
              child: AnimatedBuilder(
                animation: _contentAnimationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _contentFadeAnimation.value)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _currentStep == 0
                                ? 'assets/images/splash1.png'
                                : 'assets/images/splash2.png',
                            width: 300,
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 40),
                          Text(
                            _currentStep == 0
                                ? 'Buy Every Fashion At Bulk'
                                : 'Get Huge Discount On Your\nBulk Orders',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2C2C2C),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: _currentStep == 0 ? _buildNextButton() : _buildStartButton(),
            ),
          ],
        ),
      ),
    );
  }

  // --- CORRECTED WIDGET ---
  Widget _buildAnimatedProgressIndicator() {
    // Define styles to match your requirements
    const double barWidth = 177.5; // (358 total width - 3 gap) / 2
    const double barHeight = 6.0;
    const double barGap = 3.0;
    const Color activeColor = Color(0xFF4F9EBB);
    const Color inactiveColor = Color(0xFFE0E0E6);

    return AnimatedBuilder(
      animation: _progressAnimationController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First progress bar (always active)
            Container(
              height: barHeight,
              width: barWidth,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(barHeight / 2),
              ),
            ),
            const SizedBox(width: barGap),
            // Second progress bar (background)
            Container(
              height: barHeight,
              width: barWidth,
              decoration: BoxDecoration(
                color: inactiveColor,
                borderRadius: BorderRadius.circular(barHeight / 2),
              ),
              // The animated fill is now a simple, efficient Container
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: barHeight,
                  width: barWidth * _progressAnimation.value,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(barHeight / 2),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNextButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _nextStep,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF3F7),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF294F5E),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: Color(0xFF294F5E),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _startApp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF094D77),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Start',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}