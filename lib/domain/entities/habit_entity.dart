enum HabitFrequency { daily, weekly, monthly }

class HabitEntity {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final HabitFrequency frequency;
  final List<int>? targetDays;
  final int targetCount;
  final String? iconName;
  final String? colorHex;
  final int currentStreak;
  final int bestStreak;
  final int totalCompletions;
  final DateTime? lastCompletedAt;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.frequency = HabitFrequency.daily,
    this.targetDays,
    this.targetCount = 1,
    this.iconName,
    this.colorHex,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompletions = 0,
    this.lastCompletedAt,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get isCompletedToday {
    if (lastCompletedAt == null) return false;
    final now = DateTime.now();
    return lastCompletedAt!.year == now.year &&
        lastCompletedAt!.month == now.month &&
        lastCompletedAt!.day == now.day;
  }

  HabitEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    HabitFrequency? frequency,
    List<int>? targetDays,
    int? targetCount,
    String? iconName,
    String? colorHex,
    int? currentStreak,
    int? bestStreak,
    int? totalCompletions,
    DateTime? lastCompletedAt,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      targetCount: targetCount ?? this.targetCount,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalCompletions: totalCompletions ?? this.totalCompletions,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
