import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pi_dimafood_new/screens/home_page.dart';
import 'package:pi_dimafood_new/services/auth_service.dart';
import 'package:another_flushbar/flushbar.dart'; // Tambahkan import ini

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isObscurePassword = true;
  bool _isObscureConfirm = true;

  final AuthService _authService = AuthService();

  void _registerUser() async {
    final email = _emailController.text.trim();
    final fullName = _fullNameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty ||
        fullName.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('Semua Field wajib diisi!');
      return;
    }
    if (password != confirmPassword) {
      _showSnackBar('Password dan Konfirmasi Password tidak cocok!');
      return;
    }

    setState(() => _isLoading = true);

    final user = await _authService.registerUser(
      email: email,
      fullName: fullName,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else {
      _showSnackBar('Registrasi Gagal!');
    }
  }

  void _showSnackBar(String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(15),
      borderRadius: BorderRadius.circular(10),
      backgroundColor: Colors.red[700]!,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: SvgPicture.asset(
                            'lib/assets/icons/arrow-circle-left.svg',
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Sign Up",
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF007FFE),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    buildInputField(
                      controller: _emailController,
                      hint: "Masukkan Email Anda",
                      iconPath: 'lib/assets/icons/sms.svg',
                    ),
                    const SizedBox(height: 16),

                    buildInputField(
                      controller: _fullNameController,
                      hint: "Masukkan Nama Lengkap",
                      iconPath: 'lib/assets/icons/user.svg',
                    ),
                    const SizedBox(height: 16),

                    buildInputField(
                      controller: _passwordController,
                      hint: "Masukkan Password",
                      iconPath: 'lib/assets/icons/Vector.svg',
                      obscureText: _isObscurePassword,
                      toggleObscure:
                          () => setState(
                            () => _isObscurePassword = !_isObscurePassword,
                          ),
                    ),
                    const SizedBox(height: 16),

                    buildInputField(
                      controller: _confirmPasswordController,
                      hint: "Konfirmasi Password",
                      iconPath: 'lib/assets/icons/Vector.svg',
                      obscureText: _isObscureConfirm,
                      toggleObscure:
                          () => setState(
                            () => _isObscureConfirm = !_isObscureConfirm,
                          ),
                    ),
                    const SizedBox(height: 60),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
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
                                  'SIGN UP',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
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
