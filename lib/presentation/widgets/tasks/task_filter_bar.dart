import 'package:flutter/material.dart';
import '../../../core/constants/persian_strings.dart';

class TaskFilterBar extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedStatus;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onStatusChanged;

  const TaskFilterBar({
    super.key,
    this.selectedCategory,
    this.selectedStatus,
    required this.onCategoryChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'همه',
                  selected: selectedCategory == null,
                  onTap: () => onCategoryChanged(null),
                ),
                _FilterChip(
                  label: PersianStrings.work,
                  selected: selectedCategory == 'work',
                  onTap: () => onCategoryChanged('work'),
                ),
                _FilterChip(
                  label: PersianStrings.personal,
                  selected: selectedCategory == 'personal',
                  onTap: () => onCategoryChanged('personal'),
                ),
                _FilterChip(
                  label: PersianStrings.health,
                  selected: selectedCategory == 'health',
                  onTap: () => onCategoryChanged('health'),
                ),
                _FilterChip(
                  label: PersianStrings.education,
                  selected: selectedCategory == 'education',
                  onTap: () => onCategoryChanged('education'),
                ),
                _FilterChip(
                  label: PersianStrings.finance,
                  selected: selectedCategory == 'finance',
                  onTap: () => onCategoryChanged('finance'),
                ),
                _FilterChip(
                  label: PersianStrings.family,
                  selected: selectedCategory == 'family',
                  onTap: () => onCategoryChanged('family'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'همه',
                  selected: selectedStatus == null,
                  onTap: () => onStatusChanged(null),
                ),
                _FilterChip(
                  label: PersianStrings.pending,
                  selected: selectedStatus == 'pending',
                  onTap: () => onStatusChanged('pending'),
                ),
                _FilterChip(
                  label: PersianStrings.completed,
                  selected: selectedStatus == 'completed',
                  onTap: () => onStatusChanged('completed'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : null,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
