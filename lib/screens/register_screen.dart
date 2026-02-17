import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';
import '../main.dart';
import 'widgets/custom_loading_spinner.dart';
import '../core/animations/page_transitions.dart';
import '../core/animations/animation_constants.dart';
import 'mbti_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedGender = 'Female';
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4675B8),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final dob = _dobController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty ||
        dob.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to terms and conditions')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Replace with actual backend authentication
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navigate to MBTI assessment for new users
    Navigator.of(context).pushReplacement(
      SharedAxisPageRoute(page: const MbtiScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Illustration
                Center(
                  child: Image.asset(
                    'assets/images/icons/authcon.png',
                    height: 180,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person_add,
                        size: 180,
                        color: Color(0xFF4675B8),
                      );
                    },
                  ),
                )
                    .animate()
                    .fadeIn(
                      duration: const Duration(
                          milliseconds: AnimationConstants.medium),
                      curve: AnimationConstants.cubicEaseOut,
                    )
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      duration: const Duration(
                          milliseconds: AnimationConstants.medium),
                      curve: AnimationConstants.cubicEaseOut,
                    ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'Get Started',
                  style: GoogleFonts.mulish(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(
                          milliseconds: AnimationConstants.normal),
                      curve: AnimationConstants.cubicEaseOut,
                    )
                    .slideY(
                      begin: 0.1,
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(
                          milliseconds: AnimationConstants.normal),
                      curve: AnimationConstants.cubicEaseOut,
                    ),
                const SizedBox(height: 4),

                // Subtitle
                Text(
                  'by creating a free account.',
                  style: GoogleFonts.mulish(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(
                          milliseconds: AnimationConstants.normal),
                      curve: AnimationConstants.cubicEaseOut,
                    )
                    .slideY(
                      begin: 0.1,
                      delay: const Duration(milliseconds: 300),
                      duration: const Duration(
                          milliseconds: AnimationConstants.normal),
                      curve: AnimationConstants.cubicEaseOut,
                    ),
                const SizedBox(height: 40),

                // Form fields with staggered animation
                ..._buildFormFields(),

                const SizedBox(height: 20),

                // Gender selection
                _buildGenderToggle()
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 800),
                      duration: const Duration(
                          milliseconds: AnimationConstants.normal),
                    )
                    .slideX(begin: 0.1),

                const SizedBox(height: 16),

                // Terms and conditions
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: const Color(0xFF4675B8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.mulish(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          children: [
                            const TextSpan(
                                text: 'By checking the box you agree to our '),
                            TextSpan(
                              text: 'Terms',
                              style: TextStyle(
                                color: const Color(0xFF4675B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Conditions',
                              style: TextStyle(
                                color: const Color(0xFF4675B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(
                      delay: const Duration(milliseconds: 900),
                      duration: const Duration(
                          milliseconds: AnimationConstants.normal),
                    ),

                const SizedBox(height: 40),

                // Next button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4675B8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      disabledBackgroundColor:
                          const Color(0xFF4675B8).withOpacity(0.6),
                    ),
                    child: _isLoading
                        ? const CustomLoadingSpinner(
                            fontSize: 14,
                            dotSize: 8,
                            textColor: Colors.white,
                            dotColors: [
                              Colors.white,
                              Colors.white70,
                              Colors.white54
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Next',
                                style: GoogleFonts.mulish(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                  ),
                )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 1000),
                      duration: const Duration(
                          milliseconds: AnimationConstants.normal),
                    )
                    .slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Already a member
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a member? ',
                        style: GoogleFonts.mulish(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            FadePageRoute(page: const LoginScreen()),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Log In',
                          style: GoogleFonts.mulish(
                            fontSize: 14,
                            color: const Color(0xFF4675B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                      delay: const Duration(milliseconds: 1100),
                      duration: const Duration(
                          milliseconds: AnimationConstants.normal),
                    ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    final fields = [
      _buildTextField(
        controller: _nameController,
        hint: 'Full name',
        icon: Icons.person_outline,
        delay: 400,
      ),
      _buildTextField(
        controller: _dobController,
        hint: 'Date of Birth',
        icon: Icons.calendar_today_outlined,
        delay: 500,
        readOnly: true,
        onTap: _selectDate,
      ),
      _buildTextField(
        controller: _emailController,
        hint: 'Valid email',
        icon: Icons.email_outlined,
        delay: 600,
        keyboardType: TextInputType.emailAddress,
      ),
      _buildTextField(
        controller: _phoneController,
        hint: 'Phone number',
        icon: Icons.phone_outlined,
        delay: 700,
        keyboardType: TextInputType.phone,
      ),
      _buildTextField(
        controller: _passwordController,
        hint: 'Strong Password',
        icon: Icons.lock_outline,
        delay: 750,
        isPassword: true,
      ),
    ];

    return fields;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required int delay,
    bool isPassword = false,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        style: GoogleFonts.mulish(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.mulish(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.lock_open_outlined
                        : Icons.lock_outline,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : Icon(
                  icon,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: delay),
            duration: const Duration(milliseconds: AnimationConstants.normal),
            curve: AnimationConstants.cubicEaseOut,
          )
          .slideX(
            begin: 0.1,
            delay: Duration(milliseconds: delay),
            duration: const Duration(milliseconds: AnimationConstants.normal),
            curve: AnimationConstants.cubicEaseOut,
          ),
    );
  }

  Widget _buildGenderToggle() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGender = 'Female';
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedGender == 'Female'
                      ? const Color(0xFF4675B8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'Female',
                    style: GoogleFonts.mulish(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _selectedGender == 'Female'
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGender = 'Male';
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _selectedGender == 'Male'
                      ? const Color(0xFF4675B8)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'Male',
                    style: GoogleFonts.mulish(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _selectedGender == 'Male'
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
