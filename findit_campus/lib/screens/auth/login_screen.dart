import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _prnController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  bool _obscurePassword = true;

  // ── Design tokens ──
  static const Color primaryPurple = Color(0xFF6C4AB6);
  static const Color bgColor = Color(0xFFF4EFFB);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color fieldBg = Color(0xFFF8F5FF);
  static const Color fieldBorder = Color(0xFFE8E0F0);
  static const Color labelColor = Color(0xFF6B6B8D);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _prnController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _prnController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.error ?? 'Login failed',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // ═══════════════════════════════════
                  //  WHITE CARD
                  // ═══════════════════════════════════
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: primaryPurple.withAlpha(15),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // ── Lock icon in circle ──
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryPurple.withAlpha(20),
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              size: 36,
                              color: primaryPurple,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Title ──
                          Text(
                            'Campus Recover',
                            style: GoogleFonts.inter(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: primaryPurple,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'THE DIGITAL CONCIERGE',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFAAAAAA),
                              letterSpacing: 2.0,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ── PRN Field ──
                          _buildLabel('PRN'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _prnController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: textDark,
                            ),
                            decoration: _inputDecoration('Enter your PRN'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'PRN is required';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // ── Password Field ──
                          _buildLabel('PASSWORD'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _login(),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: textDark,
                            ),
                            decoration: _inputDecoration('••••••••').copyWith(
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFFAAAAAA),
                                  size: 20,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password is required';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 28),

                          // ── Authenticate Button ──
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return GestureDetector(
                                onTap: auth.isLoading ? null : _login,
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF9B59B6),
                                        Color(0xFF6C4AB6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryPurple.withAlpha(60),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: auth.isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            'Authenticate Access',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 18),

                          // ── Register link ──
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/register');
                            },
                            child: Text(
                              'Register Account',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryPurple,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ── Dots indicator ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (i) => Container(
                                width: 8,
                                height: 8,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i == 0
                                      ? primaryPurple
                                      : primaryPurple.withAlpha(50),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ═══════════════════════════════════
                  //  BOTTOM ILLUSTRATION ICONS
                  // ═══════════════════════════════════
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildBottomIcon(Icons.apartment_rounded, false),
                      const SizedBox(width: 16),
                      _buildBottomIcon(Icons.door_sliding_rounded, false),
                      const SizedBox(width: 16),
                      _buildBottomIcon(Icons.lightbulb_outline_rounded, true),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HELPER: Label
  // ─────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: labelColor,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HELPER: Input Decoration
  // ─────────────────────────────────────────────
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        color: const Color(0xFFBBBBBB),
      ),
      filled: true,
      fillColor: fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: fieldBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: fieldBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryPurple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HELPER: Bottom illustration icon
  // ─────────────────────────────────────────────
  Widget _buildBottomIcon(IconData icon, bool isHighlighted) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isHighlighted
            ? primaryPurple.withAlpha(25)
            : const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(14),
        border: isHighlighted
            ? Border.all(color: primaryPurple.withAlpha(50), width: 1.5)
            : null,
      ),
      child: Icon(
        icon,
        color: isHighlighted ? primaryPurple : const Color(0xFFBBBBBB),
        size: 28,
      ),
    );
  }
}
