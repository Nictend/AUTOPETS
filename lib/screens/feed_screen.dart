import 'package:flutter/material.dart';

/// Controle de uma porção manual para a máquina de ração.
class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
    required this.isMachineOnline,
    required this.isDispensing,
    required this.onFeed,
  });

  final bool isMachineOnline;
  final bool isDispensing;
  final ValueChanged<int> onFeed;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  var _portionGrams = 50;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          sliver: SliverList.list(
            children: [
              Text(
                'Alimentar',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Libere uma porção manual para o seu pet.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _MachineConnectionBanner(isOnline: widget.isMachineOnline),
              const SizedBox(height: 24),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  child: Column(
                    children: [
                      Text('PORÇÃO MANUAL', style: theme.textTheme.labelSmall),
                      const SizedBox(height: 8),
                      Text(
                        '$_portionGrams g',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('A quantidade ideal é definida pelo porte do pet.'),
                      const SizedBox(height: 12),
                      Slider(
                        value: _portionGrams.toDouble(),
                        min: 20,
                        max: 150,
                        divisions: 26,
                        label: '$_portionGrams g',
                        onChanged: widget.isDispensing
                            ? null
                            : (value) =>
                                  setState(() => _portionGrams = value.round()),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('20 g', style: theme.textTheme.bodySmall),
                          Text('150 g', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Porções rápidas',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final portion in [25, 50, 75, 100])
                    ChoiceChip(
                      label: Text('$portion g'),
                      selected: _portionGrams == portion,
                      onSelected: widget.isDispensing
                          ? null
                          : (_) => setState(() => _portionGrams = portion),
                    ),
                ],
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: widget.isMachineOnline && !widget.isDispensing
                    ? () => widget.onFeed(_portionGrams)
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
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
                    : const Icon(Icons.restaurant_rounded),
                label: Text(
                  widget.isDispensing
                      ? 'Liberando ração...'
                      : 'Liberar $_portionGrams g',
                ),
              ),
              if (!widget.isMachineOnline) ...[
                const SizedBox(height: 12),
                Text(
                  'Reconecte a máquina nos Ajustes para liberar a ração.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MachineConnectionBanner extends StatelessWidget {
  const _MachineConnectionBanner({required this.isOnline});

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
                  ? 'Máquina online e pronta para servir.'
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
