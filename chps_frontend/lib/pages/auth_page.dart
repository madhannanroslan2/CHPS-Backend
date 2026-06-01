import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../api_client.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, required this.api});
  final ApiClient api;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _usernameCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await widget.api.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      } else {
        if (_passwordCtrl.text != _confirmPasswordCtrl.text) {
          throw Exception('Passwords do not match');
        }
        await widget.api.register(_usernameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
        await widget.api.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      }
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(api: widget.api)));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final google = GoogleSignIn();
      final account = await google.signIn();
      if (account == null) {
        setState(() => _loading = false);
        return;
      }
      final auth = await account.authentication;
      await widget.api.googleAuth(auth.idToken ?? '');
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage(api: widget.api)));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _gradientController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Color.lerp(const Color(0xFF14B8A6), const Color(0xFF0F766E), _gradientController.value)!,
                      Color.lerp(const Color(0xFF0F766E), const Color(0xFF064E3B), _gradientController.value)!,
                      const Color(0xFF022c22),
                    ],
                    radius: 1.2,
                    focal: const Alignment(0.0, -0.3),
                    focalRadius: 0.3,
                  ),
                ),
              );
            },
          ),
          _buildBackgroundDecorations(size),
          _buildBody(size, isSmall),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations(Size size) {
    return CustomPaint(
      size: size,
      painter: _MedicalBackgroundPainter(),
    );
  }

  Widget _buildBody(Size size, bool isSmall) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isSmall ? 24 : 40, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBranding(isSmall),
              SizedBox(height: isSmall ? 32 : 60),
              _buildAuthCard(isSmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranding(bool isSmall) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(isSmall ? 14 : 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(isSmall ? 20 : 24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isSmall ? 20 : 24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Icon(
                Icons.local_hospital_rounded,
                color: Colors.white,
                size: isSmall ? 36 : 48,
              ),
            ),
          ),
        ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
        const SizedBox(height: 24),
        Text(
          'CHPS Management System',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmall ? 32 : 68,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -1.5,
            shadows: [
              Shadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 4)),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms, delay: 150.ms).slideY(begin: 0.3, curve: Curves.easeOutCubic),
        const SizedBox(height: 10),
        Text(
          'Community Health Profiling System',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmall ? 14 : 20,
            fontWeight: FontWeight.w400,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 0.5,
            shadows: [
              Shadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 2)),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms, delay: 300.ms).slideY(begin: 0.3, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildAuthCard(bool isSmall) {
    final cardWidth = isSmall ? double.infinity : 560.0;
    return Container(
      constraints: BoxConstraints(maxWidth: cardWidth),
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 20 : 28, vertical: isSmall ? 16 : 18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 50,
                  offset: const Offset(0, 16),
                ),
                BoxShadow(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _buildCardContent(isSmall),
          ).animate().fadeIn(duration: 800.ms, delay: 450.ms).slideY(begin: 0.2, curve: Curves.easeOutCubic),
        ),
      ),
    );
  }

  Widget _buildCardContent(bool isSmall) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTabBar(),
        const SizedBox(height: 10),
        if (!_isLogin) ...[
          _buildTextField(controller: _usernameCtrl, label: 'Username', icon: Icons.person_rounded),
          const SizedBox(height: 8),
        ],
        _buildTextField(controller: _emailCtrl, label: 'Email', icon: Icons.mail_rounded, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 8),
        _buildPasswordField(),
        if (!_isLogin) ...[
          const SizedBox(height: 8),
          _buildTextField(controller: _confirmPasswordCtrl, label: 'Confirm', icon: Icons.lock_rounded, obscure: true),
        ],
        if (_isLogin)
          Align(
            alignment: Alignment.centerRight,
            child: Text('Forgot password?', style: TextStyle(color: const Color(0xFF0F766E), fontSize: 10, fontWeight: FontWeight.w500)),
          ),
        if (_error != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 11, height: 1.3)),
                ),
              ],
            ),
          ),
        ],
        if (_error != null) const SizedBox(height: 4),
        const SizedBox(height: 8),
        _buildLoginButton(),
        const SizedBox(height: 8),
        _buildDivider(),
        const SizedBox(height: 8),
        _buildGoogleButton(),
        const SizedBox(height: 8),
        _buildToggleText(),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        children: [
          _buildTab('Login', true),
          _buildTab('Register', false),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() {
        _isLogin = label == 'Login';
        _error = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(bottom: 8),
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF0F766E) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? const Color(0xFF0F766E) : Colors.grey.shade500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          prefixIcon: Icon(icon, size: 16, color: const Color(0xFF0F766E)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordCtrl,
        obscureText: _obscurePassword,
        style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          prefixIcon: const Icon(Icons.lock_rounded, size: 16, color: Color(0xFF0F766E)),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              size: 18,
              color: Colors.grey.shade400,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF10B981)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F766E).withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: _loading ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text(
                  _isLogin ? 'Login' : 'Create Account',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('OR', style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
        ),
        const Expanded(child: Divider(color: Color(0xFFE5E7EB), thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: OutlinedButton.icon(
        onPressed: _loading ? null : _googleSignIn,
        icon: Image.network(
          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
          height: 16,
          width: 16,
          errorBuilder: (_, __, ___) => const Icon(Icons.login, size: 16),
        ),
        label: const Text('Continue with Google', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A1A2E),
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildToggleText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? "Don't have an account?" : 'Already have an account?',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: _loading ? null : () => setState(() {
            _isLogin = !_isLogin;
            _error = null;
          }),
          child: Text(
            _isLogin ? 'Sign up' : 'Login',
            style: const TextStyle(
              color: Color(0xFF0F766E),
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _MedicalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawGradientCircles(canvas, size);
    _drawCrossIcons(canvas, size);
    _drawECGLine(canvas, size);
    _drawDots(canvas, size);
  }

  void _drawGradientCircles(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);

    paint.color = const Color(0xFF14B8A6).withValues(alpha: 0.12);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.2), 120, paint);

    paint.color = const Color(0xFF0F766E).withValues(alpha: 0.1);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.15), 100, paint);

    paint.color = const Color(0xFF10B981).withValues(alpha: 0.08);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 140, paint);

    paint.color = const Color(0xFF0F766E).withValues(alpha: 0.07);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.85), 90, paint);
  }

  void _drawCrossIcons(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    _drawCross(canvas, Offset(size.width * 0.08, size.height * 0.12), 18, paint);
    _drawCross(canvas, Offset(size.width * 0.92, size.height * 0.25), 14, paint);
    _drawCross(canvas, Offset(size.width * 0.05, size.height * 0.7), 12, paint);
    _drawCross(canvas, Offset(size.width * 0.95, size.height * 0.78), 16, paint);
    _drawCross(canvas, Offset(size.width * 0.5, size.height * 0.06), 10, paint);
    _drawCross(canvas, Offset(size.width * 0.5, size.height * 0.94), 10, paint);
  }

  void _drawCross(Canvas canvas, Offset center, double size, Paint paint) {
    final half = size / 2;
    canvas.drawLine(Offset(center.dx - half, center.dy), Offset(center.dx + half, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - half), Offset(center.dx, center.dy + half), paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: size * 0.3, height: size), const Radius.circular(1)),
      paint..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: size, height: size * 0.3), const Radius.circular(1)),
      paint,
    );
    paint.style = PaintingStyle.stroke;
  }

  void _drawECGLine(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final y = size.height * 0.5;
    final w = size.width;

    path.moveTo(0, y);
    for (double x = 0; x <= w; x += 1) {
      double yy = y;
      final phase = x / w;
      yy += sin(phase * 8 * pi) * 4;
      yy += sin(phase * 40 * pi) * 3;
      if (phase > 0.3 && phase < 0.35) yy -= 20;
      if (phase > 0.32 && phase < 0.34) yy += 15;
      if (phase > 0.7 && phase < 0.75) yy -= 20;
      if (phase > 0.72 && phase < 0.74) yy += 15;
      path.lineTo(x, yy);
    }
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path2 = Path();
    final y2 = size.height * 0.35;
    path2.moveTo(0, y2);
    for (double x = 0; x <= w; x += 1) {
      double yy = y2;
      final phase = x / w;
      yy += sin(phase * 6 * pi + 1) * 3;
      yy += sin(phase * 36 * pi) * 2;
      if (phase > 0.5 && phase < 0.55) yy -= 16;
      if (phase > 0.52 && phase < 0.54) yy += 12;
      path2.lineTo(x, yy);
    }
    canvas.drawPath(path2, paint2);
  }

  void _drawDots(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04);

    final spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_MedicalBackgroundPainter oldDelegate) => false;
}
