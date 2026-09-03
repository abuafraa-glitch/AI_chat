import 'dart:math' as math;

import 'package:ai_chat/core/di/injection.dart';
import 'package:ai_chat/core/errors/exceptions.dart';
import 'package:ai_chat/core/extensions/build_context_extension.dart';
import 'package:ai_chat/core/routes/route_names.dart';
import 'package:ai_chat/core/theme/app_colors.dart';
import 'package:ai_chat/core/utils/validators.dart';
import 'package:ai_chat/core/widgets/app_scaffold.dart';
import 'package:ai_chat/presentation/blocs/auth_controller.dart';
import 'package:ai_chat/presentation/widgets/localized_text.dart';
import 'package:flutter/material.dart';

/// Login screen styled to match the Hajeen AI mobile reference layout.
class LoginScreen extends StatefulWidget {
  /// Creates a login screen.
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _socialLoading;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || _socialLoading != null) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await sl<AuthController>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on Object catch (error, stackTrace) {
      debugPrint('Credential sign-in failed: $error\n$stackTrace');
      if (mounted) {
        context.showErrorSnackBar(_errorMessage(context, error));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitSocial(String provider) async {
    if (_isLoading || _socialLoading != null) {
      return;
    }
    setState(() => _socialLoading = provider);
    try {
      final controller = sl<AuthController>();
      if (provider == 'google') {
        await controller.signInWithGoogle();
      } else {
        await controller.signInWithFacebook();
      }
    } on Object catch (error, stackTrace) {
      debugPrint('$provider sign-in failed: $error\n$stackTrace');
      if (mounted) {
        context.showErrorSnackBar(_errorMessage(context, error));
      }
    } finally {
      if (mounted) {
        setState(() => _socialLoading = null);
      }
    }
  }

  String _errorMessage(BuildContext context, Object error) {
    if (error is NetworkException && error.metadata?['offline'] == true) {
      return localizedTextRead(
        context,
        'No internet connection. Turn on Wi-Fi or mobile data and try again.',
        'لا يوجد اتصال بالإنترنت. فعّل Wi-Fi أو بيانات الهاتف ثم حاول مرة أخرى.',
      );
    }
    if (error is ServerException && error.metadata?['statusCode'] == 502) {
      return localizedTextRead(
        context,
        'The Hajeen server gateway is temporarily unavailable. Check your connection and try again.',
        'بوابة خادم هجين غير متاحة مؤقتاً. تحقق من الاتصال ثم حاول مرة أخرى.',
      );
    }
    if (error is AppException && error.message.isNotEmpty) {
      return error.message;
    }
    return localizedTextRead(
      context,
      'Sign in failed. Please try again.',
      'فشل تسجيل الدخول. حاول مرة أخرى.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = isArabicLocale(context);
    final borderColor = const Color(0xFF284773).withValues(alpha: 0.9);
    final panelColor = const Color(0xFF091C3D).withValues(alpha: 0.92);

    return AppScaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.heroGradientDark),
        child: Directionality(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sidePadding = constraints.maxWidth >= 560 ? 24.0 : 16.0;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(sidePadding, 12, sidePadding, 22),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const SizedBox(height: 4),
                          const _BrandHeader(),
                          const SizedBox(height: 30),
                          _WelcomePanel(
                            borderColor: borderColor,
                            panelColor: panelColor,
                          ),
                          const SizedBox(height: 16),
                          _LoginPanel(
                            borderColor: borderColor,
                            panelColor: panelColor,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            isLoading: _isLoading,
                            socialLoading: _socialLoading,
                            onSubmit: _submit,
                            onSocialSubmit: _submitSocial,
                            onForgotPassword: () {
                              if (!_isLoading && _socialLoading == null) {
                                context.pushTo(RouteNames.forgotPassword);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _SignupPanel(
                            borderColor: borderColor,
                            panelColor: panelColor,
                            onRegister: context.goToRegister,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: <Color>[Color(0xFF8E46FF), Color(0xFF08C8FF)],
            ).createShader(bounds),
            child: const Text(
              'AI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'هاجين',
            textDirection: TextDirection.rtl,
            style: TextStyle(
              color: Color(0xFFF5F7FF),
              fontSize: 30,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(width: 16),
          const _HajeenMark(size: 48),
        ],
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.borderColor, required this.panelColor});

  final Color borderColor;
  final Color panelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 164),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: <Widget>[
            const SizedBox(
              width: 128,
              height: 128,
              child: _NeonCube(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: <Color>[Color(0xFF8C46FF), Color(0xFF00C9FF)],
                    ).createShader(bounds),
                    child: Text(
                      localizedText(context, 'Welcome back', 'مرحباً بعودتك'),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizedText(context, 'Sign in to your account', 'سجّل الدخول إلى حسابك'),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Color(0xFFA6B5D0),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginPanel extends StatelessWidget {
  const _LoginPanel({
    required this.borderColor,
    required this.panelColor,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.socialLoading,
    required this.onSubmit,
    required this.onSocialSubmit,
    required this.onForgotPassword,
  });

  final Color borderColor;
  final Color panelColor;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? socialLoading;
  final VoidCallback onSubmit;
  final ValueChanged<String> onSocialSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    final fieldBorder = const Color(0xFF2B4772).withValues(alpha: 0.9);
    final disabled = isLoading || socialLoading != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
      decoration: BoxDecoration(
        color: panelColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _LoginField(
            controller: emailController,
            hintText: localizedText(context, 'Email', 'البريد الإلكتروني'),
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            borderColor: fieldBorder,
            validator: (value) => Validators.email(value)
                ? null
                : localizedTextRead(
                    context,
                    'Enter a valid email',
                    'أدخل بريداً إلكترونياً صحيحاً',
                  ),
          ),
          const SizedBox(height: 14),
          _LoginField(
            controller: passwordController,
            hintText: localizedText(context, 'Password', 'كلمة المرور'),
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            borderColor: fieldBorder,
            validator: (value) => Validators.required(value)
                ? null
                : localizedTextRead(
                    context,
                    'Enter your password',
                    'أدخل كلمة المرور',
                  ),
          ),
          const SizedBox(height: 16),
          _GradientButton(
            text: localizedText(context, 'Sign In', 'تسجيل الدخول'),
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(child: Divider(color: fieldBorder, thickness: 1.2)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  localizedText(context, 'or continue with', 'أو المتابعة عبر'),
                  style: const TextStyle(
                    color: Color(0xFF9EAFCD),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider(color: fieldBorder, thickness: 1.2)),
            ],
          ),
          const SizedBox(height: 14),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _SocialButton(
                    label: 'Google',
                    icon: const _GoogleMark(),
                    loading: socialLoading == 'google',
                    onPressed: disabled ? null : () => onSocialSubmit('google'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SocialButton(
                    label: 'Facebook',
                    icon: const _FacebookMark(),
                    loading: socialLoading == 'facebook',
                    onPressed: disabled ? null : () => onSocialSubmit('facebook'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: disabled ? null : onForgotPassword,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF08BDF5),
              padding: const EdgeInsets.symmetric(vertical: 4),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(
              localizedText(context, 'Forgot password?', 'نسيت كلمة المرور؟'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginField extends StatefulWidget {
  const _LoginField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.borderColor,
    required this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Color borderColor;
  final FormFieldValidator<String> validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_LoginField> createState() => _LoginFieldState();
}

class _LoginFieldState extends State<_LoginField> {
  late bool _obscureText = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        style: const TextStyle(
          color: Color(0xFFF5F7FF),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFA1B0CA),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: const Color(0xFF11284D).withValues(alpha: 0.72),
          prefixIcon: Icon(
            widget.prefixIcon,
            color: const Color(0xFFAABAD4),
            size: 25,
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  tooltip: _obscureText ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFFAABAD4),
                    size: 24,
                  ),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(color: widget.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(color: widget.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFF08BDF5), width: 1.4),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFFFF8A8A), width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(color: Color(0xFFFF8A8A), width: 1.4),
          ),
          errorStyle: const TextStyle(fontSize: 0, height: 0),
        ),
      ),
    );
  }
}

class _SignupPanel extends StatelessWidget {
  const _SignupPanel({
    required this.borderColor,
    required this.panelColor,
    required this.onRegister,
  });

  final Color borderColor;
  final Color panelColor;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 17, 12, 16),
      decoration: BoxDecoration(
        color: panelColor.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: localizedText(context, 'No account yet? ', 'ليس لديك حساب؟ '),
                  style: const TextStyle(
                    color: Color(0xFFB7C2D7),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: onRegister,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: <Color>[Color(0xFF8B47FF), Color(0xFF15C9FF)],
                      ).createShader(bounds),
                      child: Text(
                        localizedText(context, 'Create one', 'إنشاء حساب'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 15),
          const _DashedDivider(),
          const SizedBox(height: 15),

        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.text, required this.onPressed, this.isLoading = false});

  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(17),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF5964FF).withValues(alpha: 0.26),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 21,
                  height: 21,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Colors.white,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }
}

class _GradientOutlineButton extends StatelessWidget {
  const _GradientOutlineButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      constraints: const BoxConstraints(maxWidth: 148),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF138CFF), Color(0xFF9B43FF)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(1.2),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0B2045),
          disabledBackgroundColor: const Color(0xFF0B2045),
          foregroundColor: const Color(0xFF12BDF5),
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF12BDF5),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.loading,
  });

  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF5F7FF),
          backgroundColor: const Color(0xFF11284D).withValues(alpha: 0.55),
          side: const BorderSide(color: Color(0xFF2B4772)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
        child: loading
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF08BDF5),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  icon,
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFFF5F7FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(
        painter: _DashedDividerPainter(),
        size: const Size(double.infinity, 1),
      ),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D4976).withValues(alpha: 0.82)
      ..strokeWidth = 1.2;
    const dashWidth = 5.0;
    const gap = 6.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(math.min(x + dashWidth, size.width), 0), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter oldDelegate) => false;
}

class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const SweepGradient(
        colors: <Color>[
          Color(0xFF4285F4),
          Color(0xFF34A853),
          Color(0xFFFBBC05),
          Color(0xFFEA4335),
          Color(0xFF4285F4),
        ],
      ).createShader(bounds),
      child: const Text(
        'G',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Arial',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}

class _FacebookMark extends StatelessWidget {
  const _FacebookMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1877F2),
      ),
      child: const Text(
        'f',
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.07,
        ),
      ),
    );
  }
}

class _HajeenMark extends StatelessWidget {
  const _HajeenMark({this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _HajeenMarkPainter(),
    );
  }
}

class _HajeenMarkPainter extends CustomPainter {
  const _HajeenMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.43;
    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.045
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFF06C9FF), Color(0xFF8946FF)],
      ).createShader(Offset.zero & size);
    final hex = Path();
    for (var i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        hex.moveTo(point.dx, point.dy);
      } else {
        hex.lineTo(point.dx, point.dy);
      }
    }
    hex.close();
    canvas.drawPath(hex, outline);

    final brain = Paint()
      ..color = const Color(0xFF0BC7FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.042
      ..strokeCap = StrokeCap.round;
    final brainRadius = size.width * 0.18;
    canvas.drawCircle(center, brainRadius, brain);
    canvas.drawLine(
      Offset(center.dx, center.dy - brainRadius),
      Offset(center.dx, center.dy + brainRadius),
      brain,
    );
    final nodes = <Offset>[
      Offset(center.dx - size.width * 0.18, center.dy - size.width * 0.07),
      Offset(center.dx - size.width * 0.2, center.dy + size.width * 0.1),
      Offset(center.dx + size.width * 0.18, center.dy - size.width * 0.07),
      Offset(center.dx + size.width * 0.2, center.dy + size.width * 0.1),
      Offset(center.dx - size.width * 0.07, center.dy - size.width * 0.2),
      Offset(center.dx + size.width * 0.07, center.dy + size.width * 0.2),
    ];
    for (final node in nodes) {
      canvas.drawLine(center, node, brain);
      canvas.drawCircle(node, size.width * 0.045, brain);
    }
  }

  @override
  bool shouldRepaint(covariant _HajeenMarkPainter oldDelegate) => false;
}

class _NeonCube extends StatelessWidget {
  const _NeonCube();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _NeonCubePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _NeonCubePainter extends CustomPainter {
  const _NeonCubePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.52);
    final glow = Paint()
      ..color = const Color(0xFF188DFF).withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center, size.width * 0.34, glow);

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFF168DFF).withValues(alpha: 0.72);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.84),
        width: size.width * 0.9,
        height: size.height * 0.18,
      ),
      ring,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.84),
        width: size.width * 0.64,
        height: size.height * 0.12,
      ),
      ring..color = const Color(0xFF8B45FF).withValues(alpha: 0.7),
    );

    final top = Path()
      ..moveTo(center.dx, center.dy - 35)
      ..lineTo(center.dx + 39, center.dy - 13)
      ..lineTo(center.dx, center.dy + 10)
      ..lineTo(center.dx - 39, center.dy - 13)
      ..close();
    final left = Path()
      ..moveTo(center.dx - 39, center.dy - 13)
      ..lineTo(center.dx, center.dy + 10)
      ..lineTo(center.dx, center.dy + 55)
      ..lineTo(center.dx - 39, center.dy + 32)
      ..close();
    final right = Path()
      ..moveTo(center.dx + 39, center.dy - 13)
      ..lineTo(center.dx, center.dy + 10)
      ..lineTo(center.dx, center.dy + 55)
      ..lineTo(center.dx + 39, center.dy + 32)
      ..close();

    canvas.drawPath(
      top,
      Paint()
        ..shader = const LinearGradient(
          colors: <Color>[Color(0xFF1475EA), Color(0xFF5B4CF2)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      left,
      Paint()..color = const Color(0xFF2146B6).withValues(alpha: 0.88),
    );
    canvas.drawPath(
      right,
      Paint()..color = const Color(0xFF1C75D9).withValues(alpha: 0.76),
    );

    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFF00D5FF), Color(0xFFB04BFF)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(top, edge);
    canvas.drawPath(left, edge);
    canvas.drawPath(right, edge);

    for (var i = 0; i < 12; i++) {
      final point = Offset(
        6 + (i * 23) % (size.width - 12),
        9 + (i * 31) % (size.height * 0.78),
      );
      canvas.drawCircle(
        point,
        1.3,
        Paint()..color = const Color(0xFF19BFFF).withValues(alpha: 0.8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _NeonCubePainter oldDelegate) => false;
}
