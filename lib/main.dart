import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'package:image_picker/image_picker.dart';

const String apiBaseUrl = 'http://192.168.100.9:5000';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FakeNewsApp());
}

/*APP ROOT*/
class FakeNewsApp extends StatelessWidget {
  const FakeNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}

/*AUTH WRAPP*/
void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFFEF4444),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

String _friendlyAuthError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Incorrect password or email not found.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password login is not enabled for this app.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  return 'Something went wrong. Please try again.';
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF080C18),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF3B6EE8)),
            ),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const WelcomePage();
      },
    );
  }
}

/*WELCOME PAGE*/
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E1A),
                  Color(0xFF0D1B3E),
                  Color(0xFF0A0E1A),
                ],
              ),
            ),
          ),

          Positioned(
            top: -80, right: -60,
            child: _GlowOrb(color: const Color(0xFF3B6EE8), size: 280),
          ),
          Positioned(
            bottom: 60, left: -80,
            child: _GlowOrb(color: const Color(0xFF1A4DC4), size: 220),
          ),
          Positioned(
            top: 200, left: 40,
            child: _GlowOrb(color: const Color(0xFF06B6D4), size: 100),
          ),
          ...List.generate(
            6,
            (i) => _FloatingParticle(controller: _floatController, index: i),
          ),

          // Main content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22D3EE),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "AI-Powered Detection",
                            style: TextStyle(
                              color: Color(0xFF22D3EE),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      "News\nDetector",
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: -2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      "Detect fake news instantly\nusing advanced AI analysis.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.55),
                        height: 1.6,
                      ),
                    ),

                    const Spacer(),

                    _PrimaryButton(
                      label: "Get Started",
                      onTap: () => Navigator.push(
                        context,
                        _slideRoute(const SignUpPage()),
                      ),
                    ),

                    const SizedBox(height: 14),

                    _GhostButton(
                      label: "I already have an account",
                      onTap: () => Navigator.push(
                        context,
                        _slideRoute(const LoginPage()),
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*LOGIN PAGE*/
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          _slideRoute(const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, _friendlyAuthError(e));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          _AuthBackground(accentColor: const Color(0xFF3B6EE8)),
          SafeArea(
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _BackButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(height: 40),

                    _IconCircle(
                      icon: Icons.lock_open_rounded,
                      color: const Color(0xFF3B6EE8),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Welcome\nback",
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: -1.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Sign in to continue detecting fake news",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),

                    const SizedBox(height: 40),

                    _GlassCard(
                      child: Column(
                        children: [
                          _AuthField(
                            controller: _emailCtrl,
                            label: "Email address",
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _AuthField(
                            controller: _passCtrl,
                            label: "Password",
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white38,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                  
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          _slideRoute(ForgotPasswordPage(
                            prefillEmail: _emailCtrl.text.trim(),
                          )),
                        ),
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFF3B6EE8).withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    _PrimaryButton(
                      label: "Sign In",
                      loading: _loading,
                      accentColor: const Color(0xFF3B6EE8),
                      onTap: _login,
                    ),

                    const SizedBox(height: 28),
                    _OrDivider(),
                    const SizedBox(height: 28),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context, _slideRoute(const SignUpPage())),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 14,
                            ),
                            children: const [
                              TextSpan(
                                text: "Sign Up",
                                style: TextStyle(
                                  color: Color(0xFF3B6EE8),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*FORGOT PASSWORD PAGE*/
class ForgotPasswordPage extends StatefulWidget {
  final String prefillEmail;
  const ForgotPasswordPage({super.key, this.prefillEmail = ''});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _emailCtrl;
  bool _loading = false;
  bool _emailSent = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.prefillEmail);
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar(context, "Please enter your email address");
      return;
    }

    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        setState(() {
          _loading = false;
          _emailSent = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showErrorSnackBar(context, _friendlyAuthError(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _AuthBackground(accentColor: const Color(0xFF3B6EE8)),
          SafeArea(
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _BackButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(height: 40),

                    _IconCircle(
                      icon: _emailSent
                          ? Icons.mark_email_read_outlined
                          : Icons.lock_reset_rounded,
                      color: const Color(0xFF3B6EE8),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      _emailSent ? "Check your\nemail" : "Reset\npassword",
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: -1.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _emailSent
                          ? "We've sent a password reset link to\n${_emailCtrl.text.trim()}"
                          : "Enter your email and we'll send you\na link to reset your password",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 40),

                    if (!_emailSent) ...[
                      _GlassCard(
                        child: _AuthField(
                          controller: _emailCtrl,
                          label: "Email address",
                          icon: Icons.mail_outline_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _PrimaryButton(
                        label: "Send Reset Link",
                        loading: _loading,
                        accentColor: const Color(0xFF3B6EE8),
                        onTap: _sendResetEmail,
                      ),
                    ] else ...[
                      
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B6EE8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF3B6EE8).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF3B6EE8).withOpacity(0.2),
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Color(0xFF3B6EE8),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Email sent successfully",
                                    style: TextStyle(
                                      color: Color(0xFF3B6EE8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Check your inbox and spam folder",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      _PrimaryButton(
                        label: "Back to Sign In",
                        accentColor: const Color(0xFF3B6EE8),
                        onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          _slideRoute(const LoginPage()),
                          (route) => false,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Resend option
                      Center(
                        child: GestureDetector(
                          onTap: () => setState(() => _emailSent = false),
                          child: Text(
                            "Didn't receive it? Try again",
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF3B6EE8).withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*SIGN UP PAGE*/
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      _showErrorSnackBar(context, "Passwords don't match");
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          _slideRoute(const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(context, _friendlyAuthError(e));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          _AuthBackground(accentColor: const Color(0xFF3B6EE8)),
          SafeArea(
            child: SlideTransition(
              position: _slideAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _BackButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(height: 40),

                    
                    _IconCircle(
                      icon: Icons.person_add_alt_1_rounded,
                      color: const Color(0xFF3B6EE8),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Create\naccount",
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.05,
                        letterSpacing: -1.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Join thousands fighting misinformation",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),

                    const SizedBox(height: 40),

                    _GlassCard(
                      child: Column(
                        children: [
                          _AuthField(
                            controller: _emailCtrl,
                            label: "Email address",
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _AuthField(
                            controller: _passCtrl,
                            label: "Password",
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white38,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _AuthField(
                            controller: _confirmCtrl,
                            label: "Confirm password",
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscureConfirm,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white38,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 13,
                            color: Colors.white.withOpacity(0.3)),
                        const SizedBox(width: 6),
                        Text(
                          "Minimum 6 characters",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    _PrimaryButton(
                      label: "Create Account",
                      loading: _loading,
                      accentColor: const Color(0xFF3B6EE8),
                      onTap: _signup,
                    ),

                    const SizedBox(height: 28),
                    _OrDivider(),
                    const SizedBox(height: 28),

                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context, _slideRoute(const LoginPage())),
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 14,
                            ),
                            children: const [
                              
                              TextSpan(
                                text: "Sign In",
                                style: TextStyle(
                                  color: Color(0xFF3B6EE8),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*HOME SCREEN*/
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> messages = [];
  File? selectedImage;
  bool _analyzing = false;

  bool _isUrlInput(String text) {
    final value = text.trim().toLowerCase();
    final uri = Uri.tryParse(value);

    return value.startsWith("www.") ||
        ((uri?.hasScheme ?? false) &&
            (uri!.scheme == "http" || uri.scheme == "https") &&
            (uri.hasAuthority || value.startsWith("www.")));
  }

  String _normalizeResult(dynamic rawResult, {required bool isUrl}) {
    final value = rawResult?.toString().toLowerCase().trim() ?? "";

    if (isUrl) {
      if (value.contains("fake") ||
          value.contains("suspicious") ||
          value.contains("phishing") ||
          value.contains("malicious") ||
          value.contains("unsafe") ||
          value == "1") {
        return "fake url";
      }
      if (value.contains("legitimate") ||
          value.contains("legit") ||
          value.contains("real") ||
          value.contains("safe") ||
          value == "0") {
        return "legitimate url";
      }
    } else {
      if (value.contains("fake") || value == "1") return "fake";
      if (value.contains("real") || value.contains("true") || value == "0") {
        return "real";
      }
    }

    return value.isEmpty ? "unknown" : value;
  }

  String _formatConfidence(dynamic rawConfidence) {
    final numericConfidence = rawConfidence is num
        ? rawConfidence.toDouble()
        : double.tryParse(rawConfidence?.toString() ?? "");

    if (numericConfidence == null) return "";

    final percentage =
        numericConfidence <= 1 ? numericConfidence * 100 : numericConfidence;
    return percentage.clamp(0, 100).toStringAsFixed(1);
  }

  String _cleanErrorMessage(Object error) {
    var message = error.toString();
    if (message.startsWith("Exception: ")) {
      message = message.substring("Exception: ".length);
    }
    return message.replaceAll("|", " ").trim();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> analyzeText(String text) async {
  setState(() => _analyzing = true);

  try {
    final bool isUrl = _isUrlInput(text);

    http.Response response;

    if (isUrl) {
      // URL â†’ Logistic Regression
      response = await http.post(
        Uri.parse("$apiBaseUrl/predict_link"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"url": text}),
      ).timeout(const Duration(seconds: 30));
    } else {
      // News Text â†’ BERT
      response = await http.post(
        Uri.parse("$apiBaseUrl/predict_text"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": text}),
      ).timeout(const Duration(seconds: 30));
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String apiMessage = "API returned status ${response.statusCode}";
      try {
        final errorData = jsonDecode(response.body);
        if (errorData is Map && errorData["message"] != null) {
          apiMessage = errorData["message"].toString();
        }
      } catch (_) {}
      throw Exception(apiMessage);
    }

    final data = jsonDecode(response.body);

    setState(() {
      messages.removeLast();

      final rawResult = data["result"] ?? data["prediction"] ?? data["label"];
      final rawConfidence =
          data["confidence"] ?? data["probability"] ?? data["score"];
      final result = _normalizeResult(rawResult, isUrl: isUrl);
      final displayResult = result == "unsupported category"
          ? (data["message"]?.toString() ?? result)
          : result;
      final confidence = _formatConfidence(rawConfidence);
      final type = isUrl ? "url" : "text";

messages.add({
  "role": "ai",
  "text": "$type|$displayResult|$confidence",
});
    });
  } catch (e) {
    setState(() {
      messages.removeLast();
      messages.add({
        "role": "ai",
        "text": "error|${_cleanErrorMessage(e)}|0"
      });
    });

  }

  setState(() => _analyzing = false);
  _scrollToBottom();
}

  Future<void> analyzeImage(File imageFile) async {
    setState(() => _analyzing = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$apiBaseUrl/predict_image"),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send().timeout(const Duration(seconds: 60));
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(data["message"] ?? "Image analysis failed");
      }

      final rawResult = data["result"] ?? data["prediction"] ?? data["label"];
      final rawConfidence =
          data["confidence"] ?? data["probability"] ?? data["score"];
      final result = _normalizeResult(rawResult, isUrl: false);
      final displayResult = result == "unsupported category"
          ? (data["message"]?.toString() ?? result)
          : result;
      final confidence = _formatConfidence(rawConfidence);

      setState(() {
        messages.removeLast();
        messages.add({
          "role": "ai",
          "text": "image|$displayResult|$confidence",
        });
      });
    } catch (e) {
      setState(() {
        messages.removeLast();
        messages.add({"role": "ai", "text": "error|${_cleanErrorMessage(e)}|0"});
      });
    }

    if (mounted) setState(() => _analyzing = false);
    _scrollToBottom();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    selectedImage = File(image.path);
    setState(() {
      messages.add({"role": "user", "text": "image|${image.path}"});
      messages.add({"role": "ai", "text": "analyzing|"});
    });
    _scrollToBottom();
    analyzeImage(selectedImage!);
  }

  void _sendText() {
    if (controller.text.trim().isEmpty) return;
    final text = controller.text.trim();
    controller.clear();
    setState(() {
      messages.add({"role": "user", "text": "text|$text"});
      messages.add({"role": "ai", "text": "analyzing|"});
    });
    _scrollToBottom();
    analyzeText(text);
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? "User";
    final initial = email[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFF080C18),
      body: Column(
        children: [
        
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D1230),
              border: Border(
                bottom: BorderSide(
                    color: Colors.white.withOpacity(0.08), width: 1),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22D3EE),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "News Detector",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    // Avatar (display only)
                    Container(
                      width: 34, height: 34,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B6EE8), Color(0xFF1A4DC4)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: const Color(0xFF0D1230),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            title: const Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            content: Text(
                              "Are you sure you want to logout?",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 14,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, false),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.45),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, true),
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Color(0xFFEF4444),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true && context.mounted) {
                          await FirebaseAuth.instance.signOut();
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              _slideRoute(const WelcomePage()),
                              (route) => false,
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.4)),
                          color: const Color(0xFFEF4444).withOpacity(0.08),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.logout_rounded,
                                color: const Color(0xFFEF4444).withOpacity(0.85),
                                size: 15),
                            const SizedBox(width: 5),
                            Text(
                              "Logout",
                              style: TextStyle(
                                color:
                                    const Color(0xFFEF4444).withOpacity(0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

    
          Expanded(
            child: messages.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: messages.length,
                    itemBuilder: (_, index) {
                      final msg = messages[index];
                      final isUser = msg["role"] == "user";
                      final content = msg["text"] ?? "";
                      final parts = content.split("|");
                      final type = parts[0];
                      final value =
                          parts.length > 1 ? parts[1] : "";

                      if (isUser) {
                        if (type == "image") {
                          return _UserImageBubble(path: value);
                        }
                        return _UserTextBubble(text: value);
                      } else {
                        if (type == "analyzing") {
                          return _AnalyzingBubble();
                        }
                    return _ResultBubble(
                  kind: type,
                 result: value,
                 confidence: parts.length > 2 ? parts[2] : "0",
                );
                      }
                    },
                  ),
          ),

          //  Input bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D1230),
              border: Border( 
                top: BorderSide(
                    color: Colors.white.withOpacity(0.08), width: 1),
              ),
            ),
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _analyzing ? null : pickImage,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: _analyzing
                          ? Colors.white24
                          : const Color(0xFF3B6EE8),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.12)),
                    ),
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendText(),
                      decoration: InputDecoration(
                        hintText: "Paste news text to analyze...",
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.25),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _analyzing ? null : _sendText,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: _analyzing
                          ? null
                          : const LinearGradient(colors: [
                              Color(0xFF3B6EE8),
                              Color(0xFF1A4DC4),
                            ]),
                      color: _analyzing
                          ? Colors.white.withOpacity(0.06)
                          : null,
                    ),
                    child: Icon(
                      Icons.arrow_upward_rounded,
                      color: _analyzing
                          ? Colors.white24
                          : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3B6EE8).withOpacity(0.1),
              border: Border.all(
                  color: const Color(0xFF3B6EE8).withOpacity(0.3)),
            ),
            child: const Icon(Icons.shield_outlined,
                color: Color(0xFF3B6EE8), size: 32),
          ),
          const SizedBox(height: 20),
          const Text(
            "Ready to detect",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Paste news text or upload an image\nto check if it's real or fake.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// User text bubble
class _UserTextBubble extends StatelessWidget {
  final String text;
  const _UserTextBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B6EE8), Color(0xFF5B8FFF)],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, height: 1.4),
        ),
      ),
    );
  }
}

// User image bubble
class _UserImageBubble extends StatelessWidget {
  final String path;
  const _UserImageBubble({required this.path});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 80),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
          border: Border.all(
              color: const Color(0xFF3B6EE8).withOpacity(0.4)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(17),
            topRight: Radius.circular(17),
            bottomLeft: Radius.circular(17),
            bottomRight: Radius.circular(3),
          ),
          child: Image.file(
            File(path),
            width: 180,
            height: 180,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// Analyzing bubble
class _AnalyzingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                color: const Color(0xFF3B6EE8),
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Analyzing...",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Result bubble
class _ResultBubble extends StatelessWidget {
  final String kind;
  final String result;
  final String confidence;

  const _ResultBubble({
    required this.kind,
    required this.result,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedKind = kind.toLowerCase();
    final normalizedResult = result.toLowerCase();
    final isUrl = normalizedKind == "url";
    final isFake = normalizedResult.contains("fake") ||
        normalizedResult.contains("suspicious") ||
        normalizedResult.contains("phishing") ||
        normalizedResult.contains("malicious") ||
        normalizedResult.contains("unsafe");
    final isError = result == "error";
    final isUnsupported = normalizedResult.contains("does not belong") ||
        normalizedResult.contains("not related to our categories") ||
        normalizedResult.contains("unsupported category") ||
        normalizedResult.contains("currently supports only");
    final hasConfidence = confidence.trim().isNotEmpty;

    final Color color;
    final IconData icon;
    final String label;

    if (isError) {
      color = const Color(0xFF888780);
      icon = Icons.error_outline_rounded;
      label = "Analysis failed";
    } else if (isUnsupported) {
      color = const Color(0xFF60A5FA);
      icon = Icons.info_outline_rounded;
      label = "Unsupported Category";
    } else if (isFake) {
      color = const Color(0xFFEF4444);
      icon = Icons.cancel_outlined;
      label = isUrl ? "Suspicious URL" : "Fake News";
    } else {
      color = const Color(0xFF22C55E);
      icon = Icons.check_circle_outline_rounded;
      label = isUrl ? "Legitimate URL" : "Real News";
    }

    return Align(
       alignment: Alignment.centerLeft, 
       child: Container(
         margin: const EdgeInsets.only(bottom: 12, right: 48),
          padding: const EdgeInsets.all(16), 
          decoration: BoxDecoration(
             color: color.withOpacity(0.08), 
             borderRadius: const BorderRadius.only( 
            topLeft: Radius.circular(18),
             topRight: Radius.circular(18), 
             bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(18),
               ), 
               border: Border.all(color: color.withOpacity(0.3)), 
               ), 
               child: Column( 
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                   Row(
                     mainAxisSize: MainAxisSize.min, 
                     children: [
                       Icon(icon, color: color, size: 20), 
                       const SizedBox(width: 8), 
                       Text(
                         label,
                          style: TextStyle( 
                            color: color,
                             fontSize: 15, 
                             fontWeight: FontWeight.w700,
                              ),
                               ),
                                ], 
                                ),
                                 if (isError || isUnsupported) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    result,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.55),
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                 ] else if (hasConfidence) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    "Confidence: $confidence%",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 13,
                                       ),
                                        ),
                                        const SizedBox(height: 8),
                                         ClipRRect(
                                           borderRadius: BorderRadius.circular(4),
                                           child: LinearProgressIndicator(
                                            value: double.tryParse(confidence) != null
                                            ? double.parse(confidence) / 100
                                            : 0,
                                             backgroundColor:
                                              Colors.white.withOpacity(0.1),
                                              valueColor: AlwaysStoppedAnimation<Color>
                                              (color),
                                               minHeight: 4,
                                                ),
                                                 ),
                                                 ],
                                                 ],
                                                  ), 
                                                  ),
                                                   ); 
                                                   }
                                                    }

/* SHARED WIDGETS*/

class _AuthBackground extends StatelessWidget {
  final Color accentColor;
  const _AuthBackground({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF080C18),
                Color(0xFF0D1230),
                Color(0xFF080C18),
              ],
            ),
          ),
        ),
        Positioned(
          top: -100, right: -100,
          child: _GlowOrb(color: accentColor, size: 320),
        ),
        Positioned(
          bottom: -60, left: -60,
    
          child: _GlowOrb(color: const Color(0xFF1A4DC4), size: 200),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.25), color.withOpacity(0)],
        ),
      ),
    );
  }
}

class _FloatingParticle extends StatelessWidget {
  final AnimationController controller;
  final int index;
  const _FloatingParticle(
      {required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    final positions = [
      [80.0, 140.0],
      [260.0, 220.0],
      [340.0, 80.0],
      [60.0, 380.0],
      [300.0, 460.0],
      [180.0, 560.0],
    ];
    final pos = positions[index % positions.length];

    return Positioned(
      left: pos[0],
      top: pos[1],
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final offset =
              math.sin(controller.value * math.pi * 2 + index) * 10;
          return Transform.translate(
            offset: Offset(0, offset),
            child: Container(
              width: 4, height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: child,
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const _AuthField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.4), fontSize: 14),
        prefixIcon: Icon(icon,
            color: Colors.white.withOpacity(0.35), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF3B6EE8), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool loading;
  final Color accentColor;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.loading = false,
    this.accentColor = const Color(0xFF3B6EE8),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
      
          gradient: LinearGradient(
            colors: [accentColor, const Color(0xFF1A4DC4)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white.withOpacity(0.7),
          size: 18,
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconCircle({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
              height: 1, color: Colors.white.withOpacity(0.08)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "or",
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Container(
              height: 1, color: Colors.white.withOpacity(0.08)),
        ),
      ],
    );
  }
}

// Slide page route helper
Route _slideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

