import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxigo_core/taxigo_core.dart';

import '../../../../core/app_helpers.dart';
import '../../../../di/locator.dart';
import '../widgets/login_night_scene.dart';

const _pendingIntendedRoleKey = pendingIntendedRoleKey;

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  String _role = 'passenger';
  bool _obscure = true;

  bool get _showGoogle =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  bool get _showApple =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _rememberIntendedRole() async {
    await passengerGetIt<SharedPreferences>()
        .setString(_pendingIntendedRoleKey, _role);
  }

  void _signIn({
    required String phone,
    required String password,
    required String role,
  }) {
    final trimmedPhone = phone.trim();
    final trimmedPassword = password.trim();
    if (trimmedPhone.isEmpty || trimmedPassword.isEmpty) return;

    _rememberIntendedRole();
    context.read<AuthBloc>().add(
          AuthReviewLoginRequested(
            phoneNumber: trimmedPhone,
            password: trimmedPassword,
            name: role == 'driver' ? 'Driver' : 'Passenger',
            role: role,
          ),
        );
  }

  Future<void> _goAfterAuth(BuildContext context, AuthState state) async {
    final route = await resolvePostAuthRoute(state.user, intendedRole: _role);
    if (context.mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final size = MediaQuery.sizeOf(context);
    final heroH = (size.height * 0.42).clamp(260.0, 380.0);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          _goAfterAuth(context, state);
        } else if (state.status == AuthStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        final loading = state.status == AuthStatus.loading;
        return Scaffold(
          backgroundColor: const Color(0xFF0A101C),
          resizeToAvoidBottomInset: true,
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Column(
              children: [
                SizedBox(
                  height: heroH,
                  width: double.infinity,
                  child: const Stack(
                    fit: StackFit.expand,
                    children: [
                      LoginHeroScene(),
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(22, 6, 18, 0),
                          child: _BrandHeader(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 180),
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: _Sheet(
                      child: _LoginForm(
                        l10n: l10n,
                        loading: loading,
                        obscure: _obscure,
                        role: _role,
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        passwordFocus: _passwordFocus,
                        showApple: _showApple,
                        showGoogle: _showGoogle,
                        onToggleObscure: () =>
                            setState(() => _obscure = !_obscure),
                        onRole: loading
                            ? null
                            : (v) => setState(() => _role = v),
                        onSubmit: () => _signIn(
                          phone: _usernameController.text,
                          password: _passwordController.text,
                          role: _role,
                        ),
                        onApple: loading
                            ? null
                            : () {
                                _rememberIntendedRole();
                                context.read<AuthBloc>().add(
                                      AuthSocialLoginRequested(
                                        provider: SocialAuthProvider.apple,
                                        role: _role,
                                      ),
                                    );
                              },
                        onGoogle: loading
                            ? null
                            : () {
                                _rememberIntendedRole();
                                context.read<AuthBloc>().add(
                                      AuthSocialLoginRequested(
                                        provider: SocialAuthProvider.google,
                                        role: _role,
                                      ),
                                    );
                              },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(child: _Wordmark()),
        const SizedBox(width: 10),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'Her Yolculuk\nYeni Bir Hikaye',
            textAlign: TextAlign.right,
            style: GoogleFonts.pacifico(
              color: const Color(0xFFFFE7A0),
              fontSize: 18,
              height: 1.15,
              shadows: const [
                Shadow(
                  color: Color(0xEE070B12),
                  blurRadius: 10,
                  offset: Offset(0, 1),
                ),
                Shadow(
                  color: Color(0xAA070B12),
                  blurRadius: 2,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.45),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: List.generate(5, (i) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 1),
                  color: i.isEven
                      ? const Color(0xFF1A1404)
                      : Colors.transparent,
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: GoogleFonts.sora(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 0.92,
              letterSpacing: -1.2,
            ),
            children: const [
              TextSpan(text: 'Taxi', style: TextStyle(color: Colors.white)),
              TextSpan(text: 'GO', style: TextStyle(color: AppColors.accent)),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 1.5, color: AppColors.accent),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Text(
                'APP',
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.2,
                ),
              ),
            ),
            Container(width: 16, height: 1.5, color: AppColors.accent),
          ],
        ),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
            children: const [
              TextSpan(text: 'Şehirde hızlı, '),
              TextSpan(
                text: 'güvenli',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(text: ' yolculuk.'),
            ],
          ),
        ),
      ],
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161B24),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x88000000),
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 12),
          child: child,
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.l10n,
    required this.loading,
    required this.obscure,
    required this.role,
    required this.usernameController,
    required this.passwordController,
    required this.passwordFocus,
    required this.showApple,
    required this.showGoogle,
    required this.onToggleObscure,
    required this.onRole,
    required this.onSubmit,
    required this.onApple,
    required this.onGoogle,
  });

  final AppLocalizations l10n;
  final bool loading;
  final bool obscure;
  final String role;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final FocusNode passwordFocus;
  final bool showApple;
  final bool showGoogle;
  final VoidCallback onToggleObscure;
  final ValueChanged<String>? onRole;
  final VoidCallback onSubmit;
  final VoidCallback? onApple;
  final VoidCallback? onGoogle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.signIn,
          style: GoogleFonts.sora(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.loginSubtitle,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 22),
        _Field(
          controller: usernameController,
          hint: l10n.phoneNumber,
          icon: Icons.person_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => passwordFocus.requestFocus(),
        ),
        const SizedBox(height: 12),
        _Field(
          controller: passwordController,
          focusNode: passwordFocus,
          hint: l10n.password,
          icon: Icons.lock_outline_rounded,
          obscure: obscure,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!loading) onSubmit();
          },
          suffix: IconButton(
            onPressed: onToggleObscure,
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.white.withValues(alpha: 0.55),
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _RoleToggle(
          passenger: l10n.rolePassenger,
          driver: l10n.roleDriver,
          role: role,
          onChanged: onRole,
        ),
        const SizedBox(height: 18),
        _PrimaryCta(
          label: l10n.signIn,
          loading: loading,
          onPressed: loading ? null : onSubmit,
        ),
        if (showApple) ...[
          const SizedBox(height: 12),
          _OutlineCta(
            label: l10n.continueWithApple,
            onPressed: onApple,
            leading: const Icon(Icons.apple, color: Colors.white, size: 22),
          ),
        ],
        if (showGoogle) ...[
          const SizedBox(height: 12),
          _OutlineCta(
            label: l10n.continueWithGoogle,
            onPressed: onGoogle,
            leading: const _GoogleGlyph(),
          ),
        ],
        const SizedBox(height: 20),
        const _TrustStrip(),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.focusNode,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final FocusNode? focusNode;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final idle = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    );
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      cursorColor: AppColors.accent,
      style: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white.withValues(alpha: 0.38),
          fontSize: 15,
        ),
        prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.65)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF1C2433),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: idle,
        enabledBorder: idle,
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
        ),
      ),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  const _RoleToggle({
    required this.passenger,
    required this.driver,
    required this.role,
    required this.onChanged,
  });

  final String passenger;
  final String driver;
  final String role;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2433),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          _seg(
            selected: role == 'passenger',
            icon: Icons.person_rounded,
            label: passenger,
            onTap: onChanged == null ? null : () => onChanged!('passenger'),
          ),
          _seg(
            selected: role == 'driver',
            icon: Icons.local_taxi_rounded,
            label: driver,
            onTap: onChanged == null ? null : () => onChanged!('driver'),
          ),
        ],
      ),
    );
  }

  Widget _seg({
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded, size: 16, color: Color(0xFF1A1404)),
                const SizedBox(width: 4),
              ],
              Icon(
                icon,
                size: 17,
                color: selected
                    ? const Color(0xFF1A1404)
                    : Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: selected
                      ? const Color(0xFF1A1404)
                      : Colors.white.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Material(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Color(0xFF1A1404),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.login_rounded,
                        color: Color(0xFF1A1404),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF1A1404),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _OutlineCta extends StatelessWidget {
  const _OutlineCta({
    required this.label,
    required this.onPressed,
    required this.leading,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget leading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
          backgroundColor: const Color(0xFF1C2433),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    Widget divider() => Container(
          width: 1,
          height: 36,
          color: Colors.white.withValues(alpha: 0.12),
        );

    return Row(
      children: [
        const Expanded(
          child: _TrustCell(
            icon: Icons.verified_user_outlined,
            label: 'Güvenli\nYolculuk',
          ),
        ),
        divider(),
        const Expanded(
          child: _TrustCell(
            icon: Icons.schedule_rounded,
            label: 'Hızlı\nErişim',
          ),
        ),
        divider(),
        const Expanded(
          child: _TrustCell(
            icon: Icons.place_outlined,
            label: 'Her Zaman\nYanınızda',
          ),
        ),
      ],
    );
  }
}

class _TrustCell extends StatelessWidget {
  const _TrustCell({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withValues(alpha: 0.65),
            fontSize: 11,
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size(18, 18),
      painter: _GooglePainter(),
    );
  }
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.22;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    void arc(Color c, double a, double s) {
      canvas.drawArc(
        rect,
        a,
        s,
        false,
        Paint()
          ..color = c
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke,
      );
    }

    arc(const Color(0xFF4285F4), -0.45, 1.7);
    arc(const Color(0xFF34A853), 1.25, 1.05);
    arc(const Color(0xFFFBBC05), 2.3, 1.05);
    arc(const Color(0xFFEA4335), 3.35, 1.2);
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width - stroke / 2, size.height * 0.5),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
