import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/persian_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../../services/voice/voice_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(PersianStrings.settings)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: PersianStrings.appearance),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: PersianStrings.darkMode,
            trailing: Switch(
              value: isDark,
              activeThumbColor: AppTheme.gold,
              onChanged: (_) =>
                  ref.read(themeModeProvider.notifier).toggleTheme(),
            ),
          ),
          _SettingsTile(
            icon: Icons.language,
            title: PersianStrings.language,
            subtitle: settings.locale == 'fa_IR' ? 'فارسی' : 'English',
            onTap: () => ref
                .read(appSettingsProvider.notifier)
                .setLocale(settings.locale == 'fa_IR' ? 'en_US' : 'fa_IR'),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: PersianStrings.voice),
          _SettingsTile(
            icon: Icons.record_voice_over,
            title: 'دستیار صوتی',
            subtitle: 'فعال‌سازی پاسخ‌گویی و خواندن فارسی',
            trailing: Switch(
              value: settings.voiceAssistantEnabled,
              activeThumbColor: AppTheme.gold,
              onChanged: (value) => ref
                  .read(appSettingsProvider.notifier)
                  .setVoiceAssistantEnabled(value),
            ),
          ),
          _SettingsTile(
            icon: Icons.record_voice_over,
            title: PersianStrings.femaleVoice,
            trailing: settings.voiceGender == VoiceGender.female
                ? const Icon(Icons.check, color: AppTheme.gold)
                : null,
            onTap: () => ref
                .read(appSettingsProvider.notifier)
                .setVoiceGender(VoiceGender.female),
          ),
          _SettingsTile(
            icon: Icons.record_voice_over,
            title: PersianStrings.maleVoice,
            trailing: settings.voiceGender == VoiceGender.male
                ? const Icon(Icons.check, color: AppTheme.gold)
                : null,
            onTap: () => ref
                .read(appSettingsProvider.notifier)
                .setVoiceGender(VoiceGender.male),
          ),
          _SettingsTile(
            icon: Icons.speed,
            title: PersianStrings.voiceSpeed,
            subtitle: settings.voiceSpeed.toStringAsFixed(1),
            trailing: SizedBox(
              width: 120,
              child: Slider(
                value: settings.voiceSpeed.clamp(0.2, 1.0),
                min: 0.2,
                max: 1.0,
                divisions: 8,
                onChanged: (value) =>
                    ref.read(appSettingsProvider.notifier).setVoiceSpeed(value),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: PersianStrings.notifications),
          _SettingsTile(
            icon: Icons.wb_sunny_outlined,
            title: PersianStrings.morningBriefing,
            trailing: Switch(
              value: settings.morningBriefingEnabled,
              activeThumbColor: AppTheme.gold,
              onChanged: (value) => ref
                  .read(appSettingsProvider.notifier)
                  .setMorningBriefingEnabled(value),
            ),
          ),
          _SettingsTile(
            icon: Icons.nightlight_outlined,
            title: PersianStrings.eveningReview,
            trailing: Switch(
              value: settings.eveningReviewEnabled,
              activeThumbColor: AppTheme.gold,
              onChanged: (value) => ref
                  .read(appSettingsProvider.notifier)
                  .setEveningReviewEnabled(value),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: PersianStrings.security),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: PersianStrings.pinLock,
            onTap: () => context.push('/security'),
            trailing: Icon(Icons.chevron_left, color: AppTheme.textMuted),
          ),
          _SettingsTile(
            icon: Icons.fingerprint,
            title: PersianStrings.biometricLock,
            trailing: Switch(
              value: settings.biometricLockEnabled,
              activeThumbColor: AppTheme.gold,
              onChanged: (value) => ref
                  .read(appSettingsProvider.notifier)
                  .setBiometricLockEnabled(value),
            ),
          ),
          const SizedBox(height: 24),
          _SectionHeader(title: 'عمومی'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: PersianStrings.profile,
            onTap: () => context.push('/profile'),
            trailing: Icon(Icons.chevron_left, color: AppTheme.textMuted),
          ),
          _SettingsTile(
            icon: Icons.analytics_outlined,
            title: PersianStrings.analytics,
            onTap: () => context.push('/analytics'),
            trailing: Icon(Icons.chevron_left, color: AppTheme.textMuted),
          ),
          _SettingsTile(
            icon: Icons.info_outline,
            title: PersianStrings.about,
            subtitle: 'نسخه ۱.۰.۰',
            onTap: () {},
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text(PersianStrings.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.rose.withValues(alpha: 0.1),
                foregroundColor: AppTheme.rose,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.gold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.textSecondary),
        title: Text(title, style: const TextStyle(color: AppTheme.textPrimary)),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
