import 'package:flutter/material.dart';

import '../models/water_record.dart';

/// Controle das liberações manuais de água da máquina híbrida.
class WaterScreen extends StatefulWidget {
  const WaterScreen({
    super.key,
    required this.waterLevel,
    required this.isMachineOnline,
    required this.isDispensing,
    required this.records,
    required this.onDispense,
  });

  final int waterLevel;
  final bool isMachineOnline;
  final bool isDispensing;
  final List<WaterRecord> records;
  final ValueChanged<int> onDispense;

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  var _volumeMilliliters = 250;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          sliver: SliverList.list(
            children: [
              Text(
                'Água',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mantenha a hidratação do seu pet em dia.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _WaterReservoirCard(level: widget.waterLevel),
              const SizedBox(height: 24),
              _ConnectionBanner(isOnline: widget.isMachineOnline),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  child: Column(
                    children: [
                      Text('VOLUME MANUAL', style: theme.textTheme.labelSmall),
                      const SizedBox(height: 8),
                      Text(
                        '$_volumeMilliliters ml',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: const Color(0xFF1677B8),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Escolha a quantidade de água para liberar agora.',
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: _volumeMilliliters.toDouble(),
                        min: 100,
                        max: 600,
                        divisions: 10,
                        label: '$_volumeMilliliters ml',
                        onChanged: widget.isDispensing
                            ? null
                            : (value) => setState(
                                () => _volumeMilliliters = value.round(),
                              ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('100 ml', style: theme.textTheme.bodySmall),
                          Text('600 ml', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Volumes rápidos',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final volume in [150, 250, 350, 500])
                    ChoiceChip(
                      label: Text('$volume ml'),
                      selected: _volumeMilliliters == volume,
                      onSelected: widget.isDispensing
                          ? null
                          : (_) => setState(() => _volumeMilliliters = volume),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: widget.isMachineOnline && !widget.isDispensing
                    ? () => widget.onDispense(_volumeMilliliters)
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  backgroundColor: const Color(0xFF1677B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: widget.isDispensing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.water_drop_rounded),
                label: Text(
                  widget.isDispensing
                      ? 'Liberando água...'
                      : 'Liberar $_volumeMilliliters ml',
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Últimas liberações',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              if (widget.records.isEmpty)
                const _EmptyWaterHistory()
              else
                ...widget.records
                    .take(3)
                    .map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _WaterRecordCard(record: record),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WaterReservoirCard extends StatelessWidget {
  const _WaterReservoirCard({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLow = level <= 20;
    final accent = isLow
        ? Theme.of(context).colorScheme.error
        : const Color(0xFF1677B8);
    final liters = (2 * level / 100).toStringAsFixed(1).replaceAll('.', ',');

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(Icons.water_drop_rounded, color: accent, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESERVATÓRIO DE ÁGUA',
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$level% · $liters L disponível',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: level / 100,
                      minHeight: 7,
                      color: accent,
                      backgroundColor: accent.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner({required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isOnline ? const Color(0xFF167565) : colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isOnline
                  ? 'Máquina online e pronta para liberar água.'
                  : 'Máquina offline — confira a conexão.',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterRecordCard extends StatelessWidget {
  const _WaterRecordCard({required this.record});

  final WaterRecord record;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF1677B8).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.water_drop_rounded, color: Color(0xFF1677B8)),
        ),
        title: Text('${record.volumeMilliliters} ml liberados'),
        subtitle: const Text('Liberação manual'),
        trailing: Text(
          '${record.servedAt.hour.toString().padLeft(2, '0')}:${record.servedAt.minute.toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _EmptyWaterHistory extends StatelessWidget {
  const _EmptyWaterHistory();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: const Padding(
        padding: EdgeInsets.all(22),
        child: Text(
          'Nenhuma porção de água foi liberada ainda.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
