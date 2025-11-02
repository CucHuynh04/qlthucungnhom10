// lib/login_screen.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'sound_helper.dart';
import 'home_page.dart'; 
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Google Sign-In
  // Trên Android: Không cần clientId, sẽ tự động lấy từ google-services.json
  // Trên Web: Cần clientId (đã được cấu hình trong web/index.html)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Chỉ set clientId trên Web (sẽ được xử lý tự động thông qua web/index.html)
    scopes: ['email', 'profile'],
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailLogin() async {
    SoundHelper.playClickSound();
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'login_error'.tr();
          if (e.toString().contains('invalid-credential') || e.toString().contains('wrong-password') || e.toString().contains('user-not-found')) {
            errorMessage = 'Email hoặc mật khẩu không đúng. Nếu chưa có tài khoản, vui lòng đăng ký.';
          } else if (e.toString().contains('network')) {
            errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
          } else {
            errorMessage = '${'login_error'.tr()}: ${e.toString()}';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Đăng ký',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _handleAnonymousLogin() async {
    SoundHelper.playClickSound();
    setState(() => _isLoading = true);
    try {
      await _auth.signInAnonymously();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'login_error'.tr()}: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleGoogleLogin() async {
    SoundHelper.playClickSound();
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'login_error'.tr();
        if (e.toString().contains('ApiException: 10') || e.toString().contains('DEVELOPER_ERROR') || e.toString().contains('sign_in_failed')) {
          errorMessage = 'Lỗi cấu hình Google Sign-In. Vui lòng kiểm tra file HUONG_DAN_KHAC_PHUC_LOI_DANG_NHAP.md để cấu hình SHA-1 fingerprint trong Firebase Console.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối internet.';
        } else {
          errorMessage = '${'login_error'.tr()}: ${e.toString()}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 100),
              
              // --- 1. Logo/Tiêu đề ---
              const Icon(
                Icons.pets,
                size: 80,
                color: Colors.teal,
              )
                  .animate()
                  ,
              Text(
                'pet_manager'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              )
                  .animate()
                  .slideY(begin: -0.3, end: 0),
              Text(
                'welcome_back'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              )
                  .animate(), const SizedBox(height: 50),

              // --- 2. Input Email ---
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'email'.tr(),
                  prefixIcon: const Icon(Icons.person, color: Colors.teal),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'email_hint'.tr();
                  }
                  if (!value.contains('@')) {
                    return 'login_error'.tr();
                  }
                  return null;
                },
              )
                  .animate(), const SizedBox(height: 20),

              // --- 3. Input Mật khẩu ---
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'password'.tr(),
                  prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                  border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'password_hint'.tr();
                  }
                  return null;
                },
              )
                  .animate(), const SizedBox(height: 40),

              // --- 4. Nút Đăng nhập Email ---
              ElevatedButton(
                onPressed: _isLoading ? null : _handleEmailLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'login'.tr().toUpperCase(),
                        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              )
                  .animate()
                  ,
              const SizedBox(height: 10),
              const SizedBox(height: 20),

              // --- 5. Nút Đăng nhập Google ---
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleLogin,
                icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                label: Text(
                  'login_with_google'.tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
                  .animate()
                  ,
              const SizedBox(height: 10),

              // --- 6. Nút Đăng nhập Ẩn danh ---
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleAnonymousLogin,
                icon: const Icon(Icons.visibility_off, color: Colors.grey),
                label: Text(
                  'login_anonymously'.tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  side: const BorderSide(color: Colors.grey, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
                  .animate()
                  ,
              const SizedBox(height: 30),

              // --- 7. Chuyển sang Đăng ký ---
              TextButton(
                onPressed: () {
                  SoundHelper.playClickSound();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: Text(
                  'no_account'.tr(),
                  style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
                ),
              )
                  .animate(), const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}




