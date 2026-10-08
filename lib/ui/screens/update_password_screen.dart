import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../errors.dart';
import '../theme.dart';
import '../widgets.dart';

/// Set-new-password screen, shown after opening a password-reset link.
class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  var _loading = false;
  var _done = false;
  var _show = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _password.addListener(() => setState(() {}));
    _confirm.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    setState(() => _error = null);
    if (_password.text.length < 6) return setState(() => _error = t.passwordErrMinLength);
    if (_password.text != _confirm.text) return setState(() => _error = t.passwordErrMismatch);
    setState(() => _loading = true);
    // On success the controller clears recoveryMode and the gate shows the app.
    final err = await ref.read(appProvider.notifier).updatePassword(_password.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (err != null) {
        _error = appErrorText(t, err);
      } else {
        _done = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.nf;
    final t = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  const BrandMark(size: 56, radius: 16),
                  const SizedBox(height: 12),
                  const BrandWordmark(size: 24),
                  const SizedBox(height: 4),
                  Text(t.passwordSubtitle, style: ts(12, color: c.textSecondary)),
                  const SizedBox(height: 32),
                  NfCard(
                    child: _done
                        ? Column(
                            children: [
                              IconTile(
                                icon: LucideIcons.check,
                                color: c.emeraldText,
                                size: 48,
                                radius: 16,
                                bordered: true,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                t.passwordUpdated,
                                style: ts(14, weight: w600, color: c.text),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                t.passwordUpdatedNote,
                                style: ts(12, color: c.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FieldLabel(t.passwordNewPassword),
                              NfTextField(
                                controller: _password,
                                hint: t.passwordNewPlaceholder,
                                prefixIcon: LucideIcons.lock,
                                obscure: !_show,
                                autofillHints: const [AutofillHints.newPassword],
                                suffix: IconButton(
                                  tooltip: _show ? t.passwordHidePassword : t.passwordShowPassword,
                                  onPressed: () => setState(() => _show = !_show),
                                  icon: Icon(
                                    _show ? LucideIcons.eyeOff : LucideIcons.eye,
                                    size: 16,
                                    color: c.textMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              FieldLabel(t.passwordConfirmLabel),
                              NfTextField(
                                controller: _confirm,
                                hint: t.passwordConfirmPlaceholder,
                                prefixIcon: LucideIcons.lock,
                                obscure: !_show,
                                onSubmitted: (_) => _submit(),
                              ),
                              if (_error != null) ...[const SizedBox(height: 16), MessageBox(_error!)],
                              const SizedBox(height: 16),
                              NfButton(
                                expand: true,
                                loading: _loading,
                                label: _loading ? t.passwordUpdating : t.passwordUpdateBtn,
                                onPressed: _password.text.isEmpty || _confirm.text.isEmpty || _loading ? null : _submit,
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => ref.read(appProvider.notifier).signOut(),
                                child: Text(t.commonCancel, style: ts(12, color: c.textSecondary)),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
