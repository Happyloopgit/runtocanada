import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/milestone_model.dart';
import '../../domain/models/goal_model.dart';

/// Celebration screen shown when a user reaches a new milestone
class MilestoneReachedScreen extends StatefulWidget {
  final MilestoneModel milestone;
  final GoalModel goal;
  final VoidCallback? onContinue;
  final VoidCallback? onViewJourney;

  const MilestoneReachedScreen({
    super.key,
    required this.milestone,
    required this.goal,
    this.onContinue,
    this.onViewJourney,
  });

  @override
  State<MilestoneReachedScreen> createState() => _MilestoneReachedScreenState();
}

class _MilestoneReachedScreenState extends State<MilestoneReachedScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  final List<_Confetti> _confettiPieces = [];

  @override
  void initState() {
    super.initState();

    // Generate confetti pieces
    _generateConfetti();

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Scale animation for the main content
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Slide animation for stats
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start animations
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _slideController.forward();
    });
  }

  void _generateConfetti() {
    final random = math.Random();
    for (int i = 0; i < 50; i++) {
      _confettiPieces.add(_Confetti(
        x: random.nextDouble(),
        y: random.nextDouble() * 2 - 1,
        rotation: random.nextDouble() * 360,
        color: [
          AppColors.primary,
          AppColors.secondary,
          AppColors.warning,
          AppColors.info,
          AppColors.premium,
        ][random.nextInt(5)],
        size: random.nextDouble() * 8 + 4,
        speed: random.nextDouble() * 0.5 + 0.3,
      ));
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.9),
                  AppColors.primaryDark,
                ],
              ),
            ),
          ),

          // Confetti animation
          AnimatedBuilder(
            animation: _confettiController,
            builder: (context, child) {
              return CustomPaint(
                painter: _ConfettiPainter(
                  confetti: _confettiPieces,
                  progress: _confettiController.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Trophy icon with animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.premium,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.premium.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Celebration text
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: const Text(
                      'MILESTONE REACHED!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // City name
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text(
                      'You\'ve reached ${widget.milestone.cityName}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // City photo
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildCityPhoto(),
                  ),

                  const SizedBox(height: 24),

                  // City description
                  if (widget.milestone.description != null)
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.milestone.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Fun fact
                  if (widget.milestone.funFact != null) ...[
                    const SizedBox(height: 16),
                    SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.premium.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.premium.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.premium,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.milestone.funFact!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Progress stats
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildProgressStats(),
                  ),

                  const SizedBox(height: 32),

                  // Action buttons
                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // View Journey button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: widget.onViewJourney ?? () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.map),
                            label: const Text(
                              'View Journey Progress',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: widget.onContinue ?? () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityPhoto() {
    if (widget.milestone.photoUrl == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.location_city,
            size: 64,
            color: Colors.white54,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: widget.milestone.photoUrl!,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: Colors.white.withValues(alpha: 0.2),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: Colors.white.withValues(alpha: 0.2),
          child: const Center(
            child: Icon(Icons.image_not_supported, color: Colors.white54, size: 48),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStats() {
    final goal = widget.goal;
    final distanceCompleted = goal.currentProgress / 1000; // km
    final distanceRemaining = (goal.totalDistance - goal.currentProgress) / 1000; // km
    final milestonesReached = goal.milestonesReached;
    final totalMilestones = goal.totalMilestones;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Journey Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: goal.progressPercentage / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.premium),
              minHeight: 12,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${goal.progressPercentage.toStringAsFixed(1)}% Complete',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.premium,
            ),
          ),

          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.directions_run,
                  value: '${distanceCompleted.toStringAsFixed(1)} km',
                  label: 'Completed',
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.flag,
                  value: '$milestonesReached / $totalMilestones',
                  label: 'Milestones',
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.white24,
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  value: '${distanceRemaining.toStringAsFixed(1)} km',
                  label: 'Remaining',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

/// Confetti piece data
class _Confetti {
  final double x;
  double y;
  final double rotation;
  final Color color;
  final double size;
  final double speed;

  _Confetti({
    required this.x,
    required this.y,
    required this.rotation,
    required this.color,
    required this.size,
    required this.speed,
  });
}

/// Custom painter for confetti animation
class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> confetti;
  final double progress;

  _ConfettiPainter({
    required this.confetti,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in confetti) {
      final paint = Paint()..color = piece.color;

      // Calculate position
      final x = piece.x * size.width;
      final y = ((piece.y + progress * piece.speed * 2) % 2 - 0.5) * size.height;

      // Draw rotating rectangle
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((piece.rotation + progress * 360) * math.pi / 180);

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: piece.size,
          height: piece.size * 0.6,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
