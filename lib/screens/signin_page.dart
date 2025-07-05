import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pi_dimafood_new/screens/signup_page.dart';
import 'package:pi_dimafood_new/services/auth_service.dart';
import 'package:pi_dimafood_new/screens/admin_home_page.dart';
import 'package:pi_dimafood_new/screens/home_page.dart';
import 'package:another_flushbar/flushbar.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  void _resetFields() {
    _emailController.clear();
    _passwordController.clear();
  }

  void _loginUser() async {
    setState(() => _isLoading = true);

    final user = await _authService.loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      final role = await _authService.getUserRole(user.uid);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => role == "admin" ? const AdminHomePage() : const HomePage(),
        ),
      );
    } else {
      if (!mounted) return;
      Flushbar(
        message: "Email atau password salah",
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(15),
        borderRadius: BorderRadius.circular(10),
        backgroundColor: Colors.red[700]!,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      _resetFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: screenWidth * 0.45,
                      height: screenWidth * 0.45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF007FFE)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ClipOval(
                        child: Image.asset(
                          'lib/assets/images/logo_dimafood.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),

                    buildInputField(
                      controller: _emailController,
                      hint: "Masukkan Email Anda",
                      iconPath: 'lib/assets/icons/sms.svg',
                    ),
                    const SizedBox(height: 16),

                    buildInputField(
                      controller: _passwordController,
                      hint: "Masukkan Password",
                      iconPath: 'lib/assets/icons/Vector.svg',
                      obscureText: _isObscure,
                      toggleObscure:
                          () => setState(() => _isObscure = !_isObscure),
                    ),
                    const SizedBox(height: 60),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _loginUser,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF007FFE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(
                                  'LOG IN',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.inter(),
                        ),
                        GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpPage(),
                                ),
                              ),
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF007FFE),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildInputField({
    required TextEditingController controller,
    required String hint,
    required String iconPath,
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: Colors.black,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: SvgPicture.asset(
            iconPath,
            width: 24,
            height: 24,
            fit: BoxFit.scaleDown,
          ),
        ),
        suffixIcon:
            toggleObscure != null
                ? IconButton(
                  onPressed: toggleObscure,
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF7F909F),
                  ),
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF007FFE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: Color(0xFF007FFE)),
        ),
      ),
    );
  }
}
