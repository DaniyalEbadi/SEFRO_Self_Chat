class DailyPlanEntity {
  final DateTime date;
  final String? greeting;
  final String? weatherSummary;
  final List<PlannedItem> morningItems;
  final List<PlannedItem> afternoonItems;
  final List<PlannedItem> eveningItems;
  final List<String> priorities;
  final List<String> suggestions;
  final double? productivityScore;

  DailyPlanEntity({
    required this.date,
    this.greeting,
    this.weatherSummary,
    this.morningItems = const [],
    this.afternoonItems = const [],
    this.eveningItems = const [],
    this.priorities = const [],
    this.suggestions = const [],
    this.productivityScore,
  });
}

class PlannedItem {
  final String title;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final String type;
  final String? entityId;

  PlannedItem({
    required this.title,
    this.description,
    this.startTime,
    this.endTime,
    required this.type,
    this.entityId,
  });
}
