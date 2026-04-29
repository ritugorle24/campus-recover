import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _rollNumberController = TextEditingController();
  final _prnController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ── Design tokens ──
  static const Color primaryPurple = Color(0xFF6C4AB6);
  static const Color bgColor = Color(0xFFF4EFFB);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color fieldBg = Color(0xFFF8F5FF);
  static const Color fieldBorder = Color(0xFFE8E0F0);
  static const Color labelColor = Color(0xFF6B6B8D);

  @override
  void dispose() {
    _fullNameController.dispose();
    _rollNumberController.dispose();
    _prnController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      fullName: _fullNameController.text.trim(),
      rollNumber: _rollNumberController.text.trim(),
      prn: _prnController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.error ?? 'Registration failed',
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
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ═══════════════════════════════════
                //  WHITE CARD
                // ═══════════════════════════════════
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
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
                        // ── Person icon in circle ──
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryPurple.withAlpha(20),
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            size: 34,
                            color: primaryPurple,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── Title ──
                        Text(
                          'Campus Recover',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: primaryPurple,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'CREATE YOUR ACCOUNT',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFAAAAAA),
                            letterSpacing: 2.0,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── Full Name ──
                        _buildLabel('FULL NAME'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _fullNameController,
                          hint: 'Enter your full name',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Full name is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ── Roll Number ──
                        _buildLabel('ROLL NUMBER'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _rollNumberController,
                          hint: 'Enter your roll number',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Roll number is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ── PRN ──
                        _buildLabel('PRN'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _prnController,
                          hint: 'Enter your PRN',
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'PRN is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ── Password ──
                        _buildLabel('PASSWORD'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: textDark,
                          ),
                          decoration:
                              _inputDecoration('Create a strong password')
                                  .copyWith(
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
                            if (value.length < 6) return 'At least 6 characters';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ── Confirm Password ──
                        _buildLabel('CONFIRM PASSWORD'),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: textDark,
                          ),
                          decoration: _inputDecoration('••••••••').copyWith(
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword),
                              child: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFFAAAAAA),
                                size: 20,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        // ── Register Button ──
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return GestureDetector(
                              onTap: auth.isLoading ? null : _register,
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
                                          'Create Account',
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

                        // ── Login link ──
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF999999),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              },
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: primaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

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
                                color: i == 1
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

                const SizedBox(height: 28),

                // ═══════════════════════════════════
                //  BOTTOM ILLUSTRATION ICONS
                // ═══════════════════════════════════
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBottomIcon(Icons.apartment_rounded, false),
                    const SizedBox(width: 16),
                    _buildBottomIcon(Icons.school_rounded, true),
                    const SizedBox(width: 16),
                    _buildBottomIcon(Icons.groups_rounded, false),
                  ],
                ),

                const SizedBox(height: 24),
              ],
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
  //  HELPER: Text Field
  // ─────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: textDark,
      ),
      decoration: _inputDecoration(hint),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
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
