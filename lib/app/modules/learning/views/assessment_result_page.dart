import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:najahapp/app/core/theme/app_theme.dart';
import '../controllers/video_player_controller.dart';

class AssessmentResultPage extends GetView<VideoPlayerController> {
  const AssessmentResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isSubmittingAssessment.value) {
          return _buildLoadingView();
        } else {
          return _buildResultView();
        }
      }),
    );
  }

  Widget _buildLoadingView() {
    // Get screen dimensions for responsive design
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    // Responsive values
    final outerRingSize = isSmallScreen
        ? 120.0
        : (isMediumScreen ? 140.0 : 160.0);
    final innerRingSize = isSmallScreen
        ? 90.0
        : (isMediumScreen ? 105.0 : 120.0);
    final centerIconSize = isSmallScreen
        ? 60.0
        : (isMediumScreen ? 70.0 : 80.0);
    final titleFontSize = isSmallScreen ? 22.0 : (isMediumScreen ? 24.0 : 28.0);
    final subtitleFontSize = isSmallScreen
        ? 13.0
        : (isMediumScreen ? 14.0 : 16.0);
    final verticalSpacing = isSmallScreen
        ? 32.0
        : (isMediumScreen ? 40.0 : 48.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            AppTheme.secondaryColor.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated loading indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  SizedBox(
                    width: outerRingSize,
                    height: outerRingSize,
                    child: CircularProgressIndicator(
                      strokeWidth: isSmallScreen ? 6.0 : 8.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                  ),
                  // Inner ring
                  SizedBox(
                    width: innerRingSize,
                    height: innerRingSize,
                    child: CircularProgressIndicator(
                      strokeWidth: isSmallScreen ? 5.0 : 6.0,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.secondaryColor,
                      ),
                    ),
                  ),
                  // Center icon
                  Container(
                    width: centerIconSize,
                    height: centerIconSize,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.psychology,
                      size: centerIconSize * 0.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: verticalSpacing),
              // Loading text
              Text(
                'Evaluating Your Answers',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              SizedBox(height: isSmallScreen ? 12.0 : 16.0),
              Text(
                'Please wait while we calculate your score...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: verticalSpacing),
              // Animated dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => AnimatedLoadingDot(delay: index * 200),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final assessmentData = controller.assessmentData.value;
    if (assessmentData == null) {
      return const Center(child: Text('No assessment data'));
    }

    final score = assessmentData['score'] as int? ?? 0;
    final correctAnswers = assessmentData['correctAnswers'] as int? ?? 0;
    final totalQuestions = assessmentData['totalQuestions'] as int? ?? 0;
    final wrongAnswers = totalQuestions - correctAnswers;
    final isPassed = score >= 60;

    // Get screen dimensions for responsive design
    final screenWidth = Get.width;
    final isSmallScreen = screenWidth < 360;
    final isMediumScreen = screenWidth >= 360 && screenWidth < 400;

    // Responsive values
    final horizontalPadding = isSmallScreen
        ? 16.0
        : (isMediumScreen ? 20.0 : 24.0);
    final verticalSpacing1 = isSmallScreen
        ? 24.0
        : (isMediumScreen ? 32.0 : 40.0);
    final verticalSpacing2 = isSmallScreen
        ? 20.0
        : (isMediumScreen ? 24.0 : 32.0);
    final trophySize = isSmallScreen ? 100.0 : (isMediumScreen ? 120.0 : 140.0);
    final titleFontSize = isSmallScreen ? 24.0 : (isMediumScreen ? 28.0 : 32.0);
    final subtitleFontSize = isSmallScreen
        ? 13.0
        : (isMediumScreen ? 14.0 : 16.0);
    final scoreFontSize = isSmallScreen ? 42.0 : (isMediumScreen ? 48.0 : 56.0);
    final statFontSize = isSmallScreen ? 18.0 : (isMediumScreen ? 20.0 : 24.0);
    final buttonHeight = isSmallScreen ? 48.0 : (isMediumScreen ? 52.0 : 56.0);
    final cardPadding = isSmallScreen ? 16.0 : (isMediumScreen ? 20.0 : 24.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            isPassed
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(horizontalPadding),
          child: Column(
            children: [
              SizedBox(height: verticalSpacing1),
              // Trophy/Medal Icon
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: trophySize,
                      height: trophySize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPassed
                              ? [Colors.green, Colors.green.shade700]
                              : [Colors.orange, Colors.orange.shade700],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isPassed ? Colors.green : Colors.orange)
                                .withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Icon(
                        isPassed ? Icons.emoji_events : Icons.trending_up,
                        size: trophySize * 0.5,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: verticalSpacing2),
              // Title
              Text(
                isPassed ? 'Excellent Work!' : 'Good Effort!',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: isPassed ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isPassed
                    ? 'You passed the assessment!'
                    : 'Keep practicing to improve',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: verticalSpacing1),
              // Compact Score Display
              Container(
                padding: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Score Percentage - Left Side
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Text(
                            'Your Score',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12.0 : 14.0,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1500),
                            tween: Tween(begin: 0.0, end: score.toDouble()),
                            builder: (context, value, child) {
                              return Text(
                                '${value.toInt()}%',
                                style: TextStyle(
                                  fontSize: scoreFontSize,
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader =
                                        LinearGradient(
                                          colors: [
                                            AppTheme.primaryColor,
                                            AppTheme.secondaryColor,
                                          ],
                                        ).createShader(
                                          const Rect.fromLTWH(0, 0, 200, 100),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Divider
                    Container(
                      height: isSmallScreen ? 60.0 : 80.0,
                      width: 1,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    // Stats - Right Side
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          // Correct Answers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                                size: isSmallScreen ? 16.0 : 20.0,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                correctAnswers.toString(),
                                style: TextStyle(
                                  fontSize: statFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Correct',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10.0 : 12.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Wrong Answers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel_rounded,
                                color: Colors.red,
                                size: isSmallScreen ? 16.0 : 20.0,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                wrongAnswers.toString(),
                                style: TextStyle(
                                  fontSize: statFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Wrong',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 10.0 : 12.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing2),
              // Performance Breakdown
              Container(
                padding: EdgeInsets.all(cardPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.secondaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics_outlined,
                          color: AppTheme.primaryColor,
                          size: isSmallScreen
                              ? 22.0
                              : (isMediumScreen ? 24.0 : 28.0),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Performance Analysis',
                          style: TextStyle(
                            fontSize: isSmallScreen
                                ? 15.0
                                : (isMediumScreen ? 16.0 : 18.0),
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildPerformanceRow(
                      'Accuracy',
                      '$score%',
                      score / 100,
                      isPassed ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    _buildPerformanceRow(
                      'Completion',
                      '100%',
                      1.0,
                      AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),
              SizedBox(height: verticalSpacing2),
              // Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        // Go back to video player
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continue Learning',
                        style: TextStyle(
                          fontSize: isSmallScreen
                              ? 15.0
                              : (isMediumScreen ? 16.0 : 18.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Retake assessment
                        Get.back();
                        Get.back(); // Go back to assessment page
                        controller.startAssessment();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'Retake Assessment',
                        style: TextStyle(
                          fontSize: isSmallScreen
                              ? 14.0
                              : (isMediumScreen ? 15.0 : 16.0),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(
    String label,
    String value,
    double progress,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween(begin: 0.0, end: progress),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AnimatedLoadingDot extends StatefulWidget {
  final int delay;

  const AnimatedLoadingDot({super.key, required this.delay});

  @override
  State<AnimatedLoadingDot> createState() => _AnimatedLoadingDotState();
}

class _AnimatedLoadingDotState extends State<AnimatedLoadingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(
              0.3 + (_animation.value * 0.7),
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
