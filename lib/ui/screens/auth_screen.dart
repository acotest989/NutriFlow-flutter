import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/pending_onboarding.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../../state/providers.dart';
import '../errors.dart';
import '../theme.dart';
import '../widgets.dart';
import 'onboarding_screen.dart';

enum _Mode { signin, signup, reset }

/// Sign-in / sign-up / forgot-password screen.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  var _mode = _Mode.signin;
  var _loading = false;
  var _googleLoading = false;
  var _showPassword = false;
  String? _error;
  String? _info;

  @override
  void initState() {
    super.initState();
    _email.addListener(_rebuild);
    _password.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  AppController get _app => ref.read(appProvider.notifier);

  Future<void> _google() async {
    setState(() {
      _error = null;
      _info = null;
      _googleLoading = true;
    });
    final err = await _app.signInWithGoogle();
    if (!mounted) return;
    setState(() {
      _googleLoading = false;
      if (err != null) _error = appErrorText(AppLocalizations.of(context), err);
    });
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    final email = _email.text.trim();
    if (email.isEmpty || (_mode != _Mode.reset && _password.text.isEmpty)) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _info = null;
      _loading = true;
    });

    AppError? err;
    switch (_mode) {
      case _Mode.signin:
        err = await _app.signIn(email, _password.text);
      // On success the auth listener swaps this screen for the app.
      case _Mode.signup:
        final (e, needsConfirmation) = await _app.signUp(email, _password.text);
        err = e;
        if (e == null && needsConfirmation && mounted) {
          _info = t.authInfoConfirm;
          _mode = _Mode.signin;
        }
      case _Mode.reset:
        err = await _app.resetPassword(email);
        if (err == null) _info = t.authInfoReset;
    }
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (err != null) _error = appErrorText(t, err);
    });
  }

  void _goTo(_Mode m) => setState(() {
    _mode = m;
    _error = null;
    _info = null;
  });

  Future<void> _openPromoQuiz() async {
    final t = AppLocalizations.of(context);
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(
          title: t.onboardingPromoTitle,
          submitLabel: t.onboardingPromoSubmit,
          secondaryLabel: t.onboardingPromoSecondary,
          onSubmit: (data) async {
            await stashPendingOnboarding(ref.read(sharedPrefsProvider), data);
            return null;
          },
        ),
      ),
    );
    if (saved == true && mounted) {
      setState(() {
        _mode = _Mode.signup;
        _error = null;
        _info = t.authPromoSaved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    final subtitle = switch (_mode) {
      _Mode.signin => t.authSubtitleSignin,
      _Mode.signup => t.authSubtitleSignup,
      _Mode.reset => t.authSubtitleReset,
    };
    final canSubmit = !_loading && _email.text.trim().isNotEmpty && (_mode == _Mode.reset || _password.text.isNotEmpty);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AutofillGroup(
                child: Column(
                  children: [
                    const BrandMark(size: 56, radius: 16),
                    const SizedBox(height: 12),
                    const BrandWordmark(size: 24),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: ts(12, color: c.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    NfCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_mode != _Mode.reset) ...[
                            NfButton(
                              label: t.authContinueGoogle,
                              variant: NfButtonVariant.white,
                              leading: const _GoogleLogo(),
                              loading: _googleLoading,
                              expand: true,
                              onPressed: _loading ? null : _google,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Expanded(child: Divider(color: c.borderStrong, height: 1)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      t.authOr.toUpperCase(),
                                      style: ts(10, color: c.textMuted, letterSpacing: 1),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: c.borderStrong, height: 1)),
                                ],
                              ),
                            ),
                          ],
                          FieldLabel(t.authEmail),
                          NfTextField(
                            controller: _email,
                            hint: t.authEmailPlaceholder,
                            prefixIcon: LucideIcons.mail,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            textInputAction: _mode == _Mode.reset ? TextInputAction.done : TextInputAction.next,
                            onSubmitted: (_) => _mode == _Mode.reset ? _submit() : null,
                          ),
                          if (_mode != _Mode.reset) ...[
                            const SizedBox(height: 16),
                            FieldLabel(
                              t.authPassword,
                              trailing: _mode == _Mode.signin
                                  ? GestureDetector(
                                      onTap: () => _goTo(_Mode.reset),
                                      child: Text(
                                        t.authForgot,
                                        style: ts(11, color: c.accent, weight: w600),
                                      ),
                                    )
                                  : null,
                            ),
                            NfTextField(
                              controller: _password,
                              hint: _mode == _Mode.signup ? t.authPasswordPlaceholderSignup : t.authPasswordPlaceholder,
                              prefixIcon: LucideIcons.lock,
                              obscure: !_showPassword,
                              autofillHints: [
                                _mode == _Mode.signin ? AutofillHints.password : AutofillHints.newPassword,
                              ],
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              suffix: IconButton(
                                tooltip: _showPassword ? t.authHidePassword : t.authShowPassword,
                                onPressed: () => setState(() => _showPassword = !_showPassword),
                                icon: Icon(
                                  _showPassword ? LucideIcons.eyeOff : LucideIcons.eye,
                                  size: 16,
                                  color: c.textMuted,
                                ),
                              ),
                            ),
                          ],
                          if (_error != null) ...[const SizedBox(height: 16), MessageBox(_error!)],
                          if (_info != null) ...[
                            const SizedBox(height: 16),
                            MessageBox(_info!, kind: MessageKind.success),
                          ],
                          const SizedBox(height: 16),
                          NfButton(
                            expand: true,
                            loading: _loading,
                            label: _loading
                                ? t.authPleaseWait
                                : switch (_mode) {
                                    _Mode.signin => t.authSignIn,
                                    _Mode.signup => t.authCreateAccount,
                                    _Mode.reset => t.authSendReset,
                                  },
                            icon: switch (_mode) {
                              _Mode.signin => LucideIcons.logIn,
                              _Mode.signup => LucideIcons.userPlus,
                              _Mode.reset => LucideIcons.keyRound,
                            },
                            onPressed: canSubmit ? _submit : null,
                          ),
                          const SizedBox(height: 20),
                          Divider(color: c.border, height: 1),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: () => _goTo(switch (_mode) {
                                _Mode.signin => _Mode.signup,
                                _ => _Mode.signin,
                              }),
                              child: Text.rich(
                                TextSpan(
                                  style: ts(12, color: c.textSecondary),
                                  children: switch (_mode) {
                                    _Mode.reset => [
                                      TextSpan(
                                        text: t.authBackToSignin,
                                        style: ts(12, color: c.accent, weight: w600),
                                      ),
                                    ],
                                    _Mode.signin => [
                                      TextSpan(text: '${t.authNoAccount} '),
                                      TextSpan(
                                        text: t.authSignUp,
                                        style: ts(12, color: c.accent, weight: w600),
                                      ),
                                    ],
                                    _Mode.signup => [
                                      TextSpan(text: '${t.authHaveAccount} '),
                                      TextSpan(
                                        text: t.authSignInLink,
                                        style: ts(12, color: c.accent, weight: w600),
                                      ),
                                    ],
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _openPromoQuiz,
                      icon: Icon(LucideIcons.sparkles, size: 14, color: c.accent),
                      label: Text(
                        t.authBuildPlan,
                        style: ts(12, color: c.accent, weight: w600),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.authPrivacyNote,
                      style: ts(10, color: c.textMuted, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Multicolor Google "G" (drawn, so no image asset is needed).
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) =>
      const SizedBox.square(dimension: 16, child: CustomPaint(painter: _GooglePainter()));
}

class _GooglePainter extends CustomPainter {
  const _GooglePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final stroke = s * 0.2;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, s - stroke, s - stroke);
    Paint p(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    const deg = 3.14159265 / 180;
    canvas.drawArc(rect, -40 * deg, -100 * deg, false, p(const Color(0xFFEA4335))); // red (top)
    canvas.drawArc(rect, -140 * deg, -95 * deg, false, p(const Color(0xFFFBBC05))); // yellow (left)
    canvas.drawArc(rect, 125 * deg, -90 * deg, false, p(const Color(0xFF34A853))); // green (bottom)
    canvas.drawArc(rect, 35 * deg, -35 * deg, false, p(const Color(0xFF4285F4))); // blue (right)
    canvas.drawRect(Rect.fromLTWH(s / 2, s / 2 - stroke / 2, s / 2, stroke), Paint()..color = const Color(0xFF4285F4));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
