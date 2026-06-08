// ============================================================
//  login_screen.dart
//  Pantalla de Login segura — Flutter / Dart
//  Requiere: flutter_windowmanager (Android) y configuración
//  nativa descrita en los otros archivos de este paquete.
// ============================================================


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'secure_mixin.dart';

// ──────────────────────────────────────────────────────────
//  PUNTO DE ENTRADA
// ──────────────────────────────────────────────────────────

// SecureApp se ha movido a main.dart como SecureAppWrapper para manejar el detector de inactividad global.

// ──────────────────────────────────────────────────────────
//  PANTALLA DE LOGIN
// ──────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── Controladores y estado del formulario ──
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // ── Animación de entrada ──
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ── Paleta ──
  static const Color _bg = Color(0xFF050D1A);
  static const Color _surface = Color(0xFF0D1F35);
  static const Color _accent = Color(0xFF00C8FF);
  static const Color _accentGlow = Color(0x3300C8FF);
  static const Color _textPrimary = Color(0xFFE8F4FF);
  static const Color _textMuted = Color(0xFF6B8CAE);
  static const Color _error = Color(0xFFFF4C6A);

  @override
  void initState() {
    super.initState();

    // Animación de entrada
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));

    _animCtrl.forward();
  }

  // ── Dispose ──
  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validaciones ──
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo no puede estar vacío';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña no puede estar vacía';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  // ── Acción de login ──
  Future<void> _handleLogin() async {
    // Ocultar teclado
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simular llamada de red (reemplazar con tu lógica de autenticación)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Navegar a la pantalla principal
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  // ──────────────────────────────────────────────────────
  //  BUILD
  // ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // ── Fondo con gradiente y elementos decorativos ──
            _buildBackground(size),

            // ── Contenido principal ──
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 40,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: _buildCard(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Fondo decorativo ──
  Widget _buildBackground(Size size) {
    return SizedBox.expand(
      child: CustomPaint(painter: _BackgroundPainter()),
    );
  }

  // ── Tarjeta de login ──
  Widget _buildCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _accent.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.08),
            blurRadius: 60,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo / ícono
              Center(child: _buildLogo()),
              const SizedBox(height: 32),

              // Título
              Center(
                child: Text(
                  'Bienvenido',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Inicia sesión para continuar',
                  style: TextStyle(color: _textMuted, fontSize: 14),
                ),
              ),
              const SizedBox(height: 36),

              // Campo Email
              _buildLabel('Correo electrónico'),
              const SizedBox(height: 8),
              _buildEmailField(),
              const SizedBox(height: 20),

              // Campo Contraseña
              _buildLabel('Contraseña'),
              const SizedBox(height: 8),
              _buildPasswordField(),
              const SizedBox(height: 12),

              // Olvidé contraseña
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: _accent,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón de login
              _buildLoginButton(),
              const SizedBox(height: 24),

              // Separador
              _buildDivider(),
              const SizedBox(height: 24),

              // Registro
              Center(
                child: RichText(
                  text: TextSpan(
                    text: '¿No tienes cuenta? ',
                    style: TextStyle(color: _textMuted, fontSize: 14),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            'Regístrate',
                            style: TextStyle(
                              color: _accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
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
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [_accent, const Color(0xFF0066FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: _accentGlow, blurRadius: 20, spreadRadius: 4),
        ],
      ),
      child: const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 30),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: _textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      validator: _validateEmail,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      enableSuggestions: false,
      // Deshabilitar autocompletado para mayor seguridad
      autofillHints: null,
      style: TextStyle(color: _textPrimary, fontSize: 15),
      decoration: _inputDecoration(
        hint: 'correo@ejemplo.com',
        icon: Icons.alternate_email_rounded,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      validator: _validatePassword,
      obscureText: _obscurePassword,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: null,
      style: TextStyle(color: _textPrimary, fontSize: 15),
      decoration: _inputDecoration(
        hint: '••••••••',
        icon: Icons.key_rounded,
        suffix: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _textMuted,
            size: 20,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          tooltip: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _textMuted.withOpacity(0.5), fontSize: 14),
      prefixIcon: Icon(icon, color: _textMuted, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF0A1628),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _error, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: _error, width: 1.5),
      ),
      errorStyle: TextStyle(color: _error, fontSize: 12),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _isLoading
              ? null
              : const LinearGradient(
                  colors: [Color(0xFF00C8FF), Color(0xFF0066FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: _isLoading ? _accent.withOpacity(0.3) : null,
          boxShadow: _isLoading
              ? null
              : [
                  BoxShadow(
                    color: _accent.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: _textPrimary.withOpacity(0.8),
                  ),
                )
              : Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('o continúa con', style: TextStyle(color: _textMuted, fontSize: 12)),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.08))),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────
//  PAINTER — Fondo con efecto "deep space"
// ──────────────────────────────────────────────────────────
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gradiente de fondo
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF050D1A), Color(0xFF0A1A30)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Glow superior
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00C8FF).withOpacity(0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.5, -size.height * 0.1),
        radius: size.width * 0.8,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.5, -size.height * 0.1),
      size.width * 0.8,
      glowPaint,
    );

    // Glow inferior sutil
    final glowPaint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0066FF).withOpacity(0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * 0.8, size.height * 1.1),
        radius: size.width * 0.6,
      ));
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 1.1),
      size.width * 0.6,
      glowPaint2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}