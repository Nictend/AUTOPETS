import 'package:flutter/material.dart';

import '../models/feeding_record.dart';

/// Linha do tempo das porções confirmadas pela máquina.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.records});

  final List<FeedingRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderedRecords = [...records]
      ..sort((first, second) => second.servedAt.compareTo(first.servedAt));
    final now = DateTime.now();
    final todayTotal = orderedRecords
        .where((record) => _isSameDay(record.servedAt, now))
        .fold<int>(0, (total, record) => total + record.portionGrams);
    final weeklyTotal = orderedRecords
        .where(
          (record) =>
              record.servedAt.isAfter(now.subtract(const Duration(days: 7))),
        )
        .fold<int>(0, (total, record) => total + record.portionGrams);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          sliver: SliverList.list(
            children: [
              Text(
                'Histórico',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Acompanhe tudo o que foi servido.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _StatisticCard(
                      label: 'Hoje',
                      value: '$todayTotal g',
                      icon: Icons.today_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatisticCard(
                      label: 'Últimos 7 dias',
                      value: '$weeklyTotal g',
                      icon: Icons.insights_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Refeições recentes',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (orderedRecords.isEmpty)
                const _EmptyHistory()
              else
                ..._buildRecordSections(context, orderedRecords),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRecordSections(
    BuildContext context,
    List<FeedingRecord> records,
  ) {
    final widgets = <Widget>[];
    DateTime? previousDate;

    for (final record in records) {
      if (previousDate == null || !_isSameDay(previousDate, record.servedAt)) {
        if (previousDate != null) widgets.add(const SizedBox(height: 16));
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _dayLabel(record.servedAt),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        );
        previousDate = record.servedAt;
      }
      widgets.add(_HistoryRecordCard(record: record));
      widgets.add(const SizedBox(height: 8));
    }
    return widgets;
  }
}

class _StatisticCard extends StatelessWidget {
  const _StatisticCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 20),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _HistoryRecordCard extends StatelessWidget {
  const _HistoryRecordCard({required this.record});

  final FeedingRecord record;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isManual = record.source == FeedingSource.manual;
    final accent = isManual ? colorScheme.tertiary : colorScheme.primary;

    return Card(
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            isManual ? Icons.touch_app_rounded : Icons.schedule_rounded,
            color: accent,
          ),
        ),
        title: Text(
          '${record.portionGrams} g liberados',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(record.sourceLabel),
        trailing: Text(
          _formatTime(record.servedAt),
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48),
            const SizedBox(height: 14),
            Text(
              'Ainda não há registros',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text(
              'As porções liberadas aparecerão aqui.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime first, DateTime second) =>
    first.year == second.year &&
    first.month == second.month &&
    first.day == second.day;

String _dayLabel(DateTime date) {
  final today = DateTime.now();
  if (_isSameDay(date, today)) return 'Hoje';
  if (_isSameDay(date, today.subtract(const Duration(days: 1)))) return 'Ontem';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _formatTime(DateTime date) =>
    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
