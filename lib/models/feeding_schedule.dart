/// Uma refeição recorrente configurada para a máquina.
class FeedingSchedule {
  const FeedingSchedule({
    required this.id,
    required this.hour,
    required this.minute,
    required this.portionGrams,
    this.enabled = true,
    this.weekdays = const [1, 2, 3, 4, 5, 6, 7],
  });

  final String id;
  final int hour;
  final int minute;
  final int portionGrams;
  final bool enabled;
  final List<int> weekdays;

  String get formattedTime =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  String get daysLabel {
    if (weekdays.length == 7) return 'Todos os dias';

    const labels = {
      1: 'Seg',
      2: 'Ter',
      3: 'Qua',
      4: 'Qui',
      5: 'Sex',
      6: 'Sáb',
      7: 'Dom',
    };
    return weekdays.map((day) => labels[day]).join(', ');
  }

  FeedingSchedule copyWith({
    int? hour,
    int? minute,
    int? portionGrams,
    bool? enabled,
    List<int>? weekdays,
  }) {
    return FeedingSchedule(
      id: id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      portionGrams: portionGrams ?? this.portionGrams,
      enabled: enabled ?? this.enabled,
      weekdays: weekdays ?? this.weekdays,
    );
  }
}
