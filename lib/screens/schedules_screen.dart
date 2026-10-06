import 'package:flutter/material.dart';

import '../models/feeding_schedule.dart';

/// Gerenciamento da rotina automática de alimentação.
class SchedulesScreen extends StatelessWidget {
  const SchedulesScreen({
    super.key,
    required this.schedules,
    required this.onScheduleChanged,
    required this.onScheduleCreated,
    required this.onScheduleDeleted,
  });

  final List<FeedingSchedule> schedules;
  final ValueChanged<FeedingSchedule> onScheduleChanged;
  final ValueChanged<FeedingSchedule> onScheduleCreated;
  final ValueChanged<String> onScheduleDeleted;

  Future<void> _showNewScheduleSheet(BuildContext context) async {
    var selectedTime = TimeOfDay.now();
    var portionGrams = 50;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  8,
                  24,
                  24 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nova refeição',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('A refeição será repetida todos os dias.'),
                    const SizedBox(height: 24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.schedule_rounded),
                      title: const Text('Horário'),
                      trailing: TextButton(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setSheetState(() => selectedTime = time);
                          }
                        },
                        child: Text(
                          MaterialLocalizations.of(context)
                              .formatTimeOfDay(selectedTime),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined),
                        const SizedBox(width: 16),
                        const Text('Porção'),
                        const Spacer(),
                        Text(
                          '$portionGrams g',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: portionGrams.toDouble(),
                      min: 20,
                      max: 150,
                      divisions: 26,
                      label: '$portionGrams g',
                      onChanged: (value) =>
                          setSheetState(() => portionGrams = value.round()),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        onScheduleCreated(
                          FeedingSchedule(
                            id: DateTime.now().microsecondsSinceEpoch
                                .toString(),
                            hour: selectedTime.hour,
                            minute: selectedTime.minute,
                            portionGrams: portionGrams,
                          ),
                        );
                        Navigator.pop(sheetContext);
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Adicionar horário'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    FeedingSchedule schedule,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover horário?'),
        content: Text(
          'A refeição das ${schedule.formattedTime} será removida da rotina.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) onScheduleDeleted(schedule.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewScheduleSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo horário'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 108),
            sliver: SliverList.list(
              children: [
                Text(
                  'Horários',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Programe a rotina ideal para o seu pet.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                if (schedules.isEmpty)
                  _EmptySchedules(onAdd: () => _showNewScheduleSheet(context))
                else ...[
                  Text(
                    '${schedules.where((schedule) => schedule.enabled).length} refeições ativas',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: 10),
                  for (final schedule in schedules) ...[
                    _ScheduleCard(
                      schedule: schedule,
                      onChanged: onScheduleChanged,
                      onDelete: () => _confirmDelete(context, schedule),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.onChanged,
    required this.onDelete,
  });

  final FeedingSchedule schedule;
  final ValueChanged<FeedingSchedule> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: schedule.enabled
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                schedule.formattedTime,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: schedule.enabled
                      ? colorScheme.onPrimaryContainer
                      : null,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${schedule.portionGrams} g de ração',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    schedule.daysLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch.adaptive(
                  value: schedule.enabled,
                  onChanged: (value) =>
                      onChanged(schedule.copyWith(enabled: value)),
                ),
                IconButton(
                  tooltip: 'Remover horário',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySchedules extends StatelessWidget {
  const _EmptySchedules({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.event_available_rounded, size: 48),
            const SizedBox(height: 14),
            Text(
              'Sem horários programados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'Crie uma rotina para não perder nenhuma refeição.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Criar horário'),
            ),
          ],
        ),
      ),
    );
  }
}
