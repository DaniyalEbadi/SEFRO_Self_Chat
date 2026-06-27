import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/persian_strings.dart';
import '../../../domain/entities/habit_entity.dart';

class AddHabitScreen extends ConsumerStatefulWidget {
  const AddHabitScreen({super.key});

  @override
  ConsumerState<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends ConsumerState<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  HabitFrequency _frequency = HabitFrequency.daily;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(PersianStrings.addHabit)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: PersianStrings.habitName,
                  prefixIcon: Icon(Icons.check_circle_outline),
                ),
                validator: (v) => v == null || v.isEmpty ? 'نام عادت را وارد کنید' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: PersianStrings.taskDescription,
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              const Text('تکرار', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SegmentedButton<HabitFrequency>(
                segments: const [
                  ButtonSegment(value: HabitFrequency.daily, label: Text(PersianStrings.daily)),
                  ButtonSegment(value: HabitFrequency.weekly, label: Text(PersianStrings.weekly)),
                  ButtonSegment(value: HabitFrequency.monthly, label: Text(PersianStrings.monthly)),
                ],
                selected: {_frequency},
                onSelectionChanged: (v) => setState(() => _frequency = v.first),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveHabit,
                child: const Text(PersianStrings.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;
    if (mounted) context.pop();
  }
}
