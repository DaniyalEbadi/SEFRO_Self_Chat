import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/voice_provider.dart';

class VoiceInputButton extends ConsumerWidget {
  final Function(String) onResult;

  const VoiceInputButton({super.key, required this.onResult});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceProvider);
    final voiceNotifier = ref.read(voiceProvider.notifier);

    return Container(
      decoration: BoxDecoration(
        color: voiceState.isListening ? AppTheme.gold : AppTheme.card,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: voiceState.isListening
            ? [
                BoxShadow(
                  color: AppTheme.gold.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: IconButton(
        icon: Icon(
          voiceState.isListening ? Icons.mic : Icons.mic_none,
          color: voiceState.isListening ? AppTheme.bg : AppTheme.textSecondary,
        ),
        onPressed: () async {
          if (voiceState.isListening) {
            await voiceNotifier.stopListening();
            if (voiceState.recognizedText != null) {
              onResult(voiceState.recognizedText!);
              voiceNotifier.clearRecognizedText();
            }
          } else {
            await voiceNotifier.startListening();
          }
        },
      ),
    );
  }
}
