import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/constants/persian_strings.dart';
import '../../../core/theme/app_theme.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  final _pinController = TextEditingController();

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(PersianStrings.security)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: SwitchListTile(
              title: const Text(PersianStrings.pinLock, style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: const Text('با پین ۴ رقمی از برنامه محافظت کنید', style: TextStyle(color: AppTheme.textMuted)),
              value: _pinEnabled,
              onChanged: (v) => setState(() => _pinEnabled = v),
              activeThumbColor: AppTheme.gold,
            ),
          ),
          if (_pinEnabled)
            Padding(
              padding: const EdgeInsets.all(16),
              child: PinCodeTextField(
                appContext: context,
                controller: _pinController,
                length: 4,
                obscureText: true,
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
                onChanged: (_) {},
              ),
            ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: SwitchListTile(
              title: const Text(PersianStrings.biometricLock, style: TextStyle(color: AppTheme.textPrimary)),
              subtitle: const Text('از اثر انگشت یا تشخیص چهره استفاده کنید', style: TextStyle(color: AppTheme.textMuted)),
              value: _biometricEnabled,
              onChanged: (v) => setState(() => _biometricEnabled = v),
              activeThumbColor: AppTheme.gold,
              secondary: Icon(Icons.fingerprint, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
