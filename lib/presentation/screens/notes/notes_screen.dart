import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/persian_strings.dart';
import '../../../core/theme/app_theme.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  final List<Map<String, dynamic>> _notes = [
    {'title': 'ایده‌های جدید', 'content': 'برنامه جدید برای پروژه...', 'pinned': true, 'color': AppTheme.gold},
    {'title': 'لیست خرید', 'content': 'شیر، نان، برنج، مرغ، سبزیجات...', 'pinned': false, 'color': AppTheme.emerald},
    {'title': 'یادداشت جلسه', 'content': 'نقاط قوت و ضعف پروژه مورد بحث قرار گرفت.', 'pinned': true, 'color': AppTheme.teal},
    {'title': 'اهداف ماه', 'content': '۱. اتمام پروژه ۲. ورزش روزانه ۳. مطالعه', 'pinned': false, 'color': AppTheme.rose},
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(PersianStrings.notes),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          if (_pinNotes.isNotEmpty)
            _NotesSection(title: 'یادداشت‌های مهم', notes: _pinNotes, isWide: isWide),
          Expanded(child: _NotesSection(title: 'همه یادداشت‌ها', notes: _unpinNotes, isWide: isWide)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Map<String, dynamic>> get _pinNotes => _notes.where((n) => n['pinned'] as bool).toList();
  List<Map<String, dynamic>> get _unpinNotes => _notes.where((n) => !(n['pinned'] as bool)).toList();
}

class _NotesSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> notes;
  final bool isWide;

  const _NotesSection({required this.title, required this.notes, required this.isWide});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary)),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 3 : 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (note['color'] as Color).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (note['color'] as Color).withValues(alpha: 0.15)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note['title'],
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (note['pinned'] as bool)
                          Icon(Icons.push_pin, size: 14, color: AppTheme.textMuted),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        note['content'],
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
