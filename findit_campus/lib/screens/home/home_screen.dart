import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../config/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      children: [
                        Icon(
                          Icons.menu_rounded,
                          color: AppColors.textPrimary.withOpacity(0.8),
                          size: 26,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Campus Recover',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/profile'),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.accentGreen,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: user?.avatar != null && user!.avatar.isNotEmpty
                                  ? Image.network(
                                      ApiConfig.imageUrl(user.avatar),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                                    )
                                  : _buildDefaultAvatar(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // GREETING
                    Text(
                      'Welcome back,\n${user?.fullName.split(' ').first ?? 'Student'}!',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ACTION GRID
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.95,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _ActionCard(
                          label: 'Report Lost\nItem',
                          icon: Icons.add_rounded,
                          watermarkIcon: Icons.search_rounded,
                          gradientColors: [AppColors.primary, AppColors.primaryDark],
                          onTap: () => Navigator.pushNamed(context, '/report'),
                        ),
                        _ActionCard(
                          label: 'View Lost\nItems',
                          icon: Icons.list_alt_rounded,
                          watermarkIcon: Icons.visibility_outlined,
                          gradientColors: [AppColors.accentGreen, const Color(0xFF00A35C)],
                          onTap: () => Navigator.pushNamed(context, '/search'),
                        ),
                        _ActionCard(
                          label: 'Mark Item\nFound',
                          icon: Icons.check_circle_outline_rounded,

                          watermarkIcon: Icons.cell_tower_rounded,
                          gradientColors: [AppColors.accentOrange, const Color(0xFFE65100)],
                          onTap: () => Navigator.pushNamed(context, '/my-items'),
                        ),
                        _ActionCard(
                          label: 'Leaderboard',
                          icon: Icons.emoji_events_rounded,
                          watermarkIcon: Icons.military_tech_rounded,
                          gradientColors: [AppColors.accentPink, const Color(0xFFD81B60)],
                          onTap: () => Navigator.pushNamed(context, '/leaderboard'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // CAMPUS MAP CARD
                    Container(
                      width: double.infinity,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            top: -20,
                            child: Icon(
                              Icons.map_rounded,
                              size: 150,
                              color: Colors.white.withOpacity(0.05),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'CAMPUS MAP',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accent,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Explore recovery zones',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          color: AppColors.textMuted,
          size: 20,
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData watermarkIcon;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.watermarkIcon,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                watermarkIcon,
                size: 90,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
