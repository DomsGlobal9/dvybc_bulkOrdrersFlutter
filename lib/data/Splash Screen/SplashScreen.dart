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
    // Logo animation controller (longer for complete sequence)
    _logoAnimationController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    // Fade animation controller
    _fadeAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    // Content change animation controller
    _contentAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    // Progress bar animation controller
    _progressAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo scale animation - starts small, grows big, then vanishes
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Interval(0.0, 0.7, curve: Curves.elasticOut),
    ));

    // Logo fade animation - fades in, stays visible, then fades out
    _logoFadeAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30.0,
      ),
    ]).animate(_logoAnimationController);

    // General fade animation
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
    // Start logo animation (small to big to vanish)
    _logoAnimationController.forward();

    // Wait for logo animation to complete
    await Future.delayed(Duration(milliseconds: 3200));

    // Move to onboarding content
    _fadeAnimationController.forward();
    _contentAnimationController.forward();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      setState(() {
        _currentStep = 1;
      });

      // Reset and start content animation
      _contentAnimationController.reset();
      _contentAnimationController.forward();

      // Animate progress bar to fill completely
      _progressAnimationController.forward();

    } else {
      // Start the app
      _startApp();
    }
  }

  void _startApp() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      if (isLoggedIn) {
        // Clear the login state for testing - remove this in production
        await prefs.setBool('isLoggedIn', false);
        Get.offAllNamed('/login');
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      print('Error checking login status: $e');
      Get.offAllNamed('/login');
    }
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
          if (_fadeAnimationController.value == 0) {
            // Show initial logo screen
            return _buildLogoScreen();
          } else {
            // Show onboarding content
            return _buildOnboardingContent();
          }
        },
      ),
    );
  }

  Widget _buildLogoScreen() {
    return AnimatedBuilder(
      animation: _logoAnimationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF87CEEB), // Sky blue
                Color(0xFFB0E0E6), // Powder blue
              ],
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
            SizedBox(height: 80),

            // Logo at top
            Image.asset(
              'assets/images/DVYBL.png',
              width: 120,
              height: 60,
              fit: BoxFit.contain,
            ),

            // Animated Progress indicator
            SizedBox(height: 30),
            _buildAnimatedProgressIndicator(),

            // Main content with animations
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
                          // Animated illustration
                          Container(
                            padding: EdgeInsets.all(40),
                            child: Image.asset(
                              _currentStep == 0
                                  ? 'assets/images/splash1.png'
                                  : 'assets/images/splash2.png',
                              width: 300,
                              height: 250,
                              fit: BoxFit.contain,
                            ),
                          ),

                          SizedBox(height: 40),

                          // Animated title
                          Text(
                            _currentStep == 0
                                ? 'Buy Every Fashion At Bulk'
                                : 'Get Huge Discount On Your\nBulk Orders',
                            style: TextStyle(
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

            // Action button
            Padding(
              padding: EdgeInsets.all(30),
              child: _currentStep == 0
                  ? _buildNextButton()
                  : _buildStartButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedProgressIndicator() {
    return AnimatedBuilder(
      animation: _progressAnimationController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // First progress bar (always active)
            Container(
              height: 4,
              width: 80,
              decoration: BoxDecoration(
                color: Color(0xFF094D77),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 12),
            // Second progress bar (animated fill)
            Container(
              height: 4,
              width: 80,
              decoration: BoxDecoration(
                color: Color(0xFFE0E0E6),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 4,
                  width: 80 * _progressAnimation.value,
                  decoration: BoxDecoration(
                    color: Color(0xFF094D77),
                    borderRadius: BorderRadius.circular(2),
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: Color(0xFF666666),
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
          backgroundColor: Color(0xFF094D77),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
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