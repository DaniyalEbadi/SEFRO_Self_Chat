import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/constants/persian_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _showOtp = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text(PersianStrings.loginWithOtp)),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B0E17), Color(0xFF141926)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80,
                  height: 80,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    size: 40,
                    color: AppTheme.gold,
                  ),
                ),
                Text(
                  _showOtp
                      ? PersianStrings.enterOtp
                      : PersianStrings.enterPhone,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _showOtp
                      ? 'کد ارسال شده را وارد کنید'
                      : 'شماره موبایل خود را وارد کنید',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                if (!_showOtp)
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'شماره موبایل',
                      prefixIcon: Icon(Icons.phone, size: 20),
                      hintText: '09123456789',
                    ),
                    style: const TextStyle(color: AppTheme.textPrimary),
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                  ),
                if (_showOtp) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                      'کد آزمایشی: 123456',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.goldLight, fontSize: 12),
                    ),
                  ),
                ],
                if (_showOtp)
                  PinCodeTextField(
                    appContext: context,
                    controller: _otpController,
                    length: 6,
                    obscureText: false,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(12),
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeFillColor: AppTheme.gold.withValues(alpha: 0.1),
                      selectedFillColor: AppTheme.card,
                      inactiveFillColor: AppTheme.card,
                      activeColor: AppTheme.gold,
                      selectedColor: AppTheme.gold,
                      inactiveColor: AppTheme.cardBorder,
                    ),
                    onChanged: (v) {},
                  ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: authState.status == AuthStatus.loading
                      ? null
                      : () async {
                          if (!_showOtp) {
                            await ref
                                .read(authProvider.notifier)
                                .loginWithOtp(_phoneController.text.trim());
                            setState(() => _showOtp = true);
                          } else {
                            await ref
                                .read(authProvider.notifier)
                                .verifyOtp(
                                  _phoneController.text.trim(),
                                  _otpController.text.trim(),
                                );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: AppTheme.bg,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _showOtp
                        ? PersianStrings.verifyOtp
                        : PersianStrings.sendOtp,
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
