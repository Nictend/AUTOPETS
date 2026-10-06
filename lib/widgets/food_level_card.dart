import 'package:flutter/material.dart';

class FoodLevelCard extends StatelessWidget {
  const FoodLevelCard({
    super.key,
    required this.percentage,
    this.capacityLabel = '1,4 kg disponível',
  });

  final int percentage;
  final String capacityLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLow = percentage <= 20;
    final accent = isLow ? colorScheme.error : const Color(0xFFE28A24);

    return Semantics(
      label: 'Nível de ração: $percentage por cento',
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: accent,
                      size: 20,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(color: accent, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const Spacer(),
              Text('RAÇÃO', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 7,
                  backgroundColor: accent.withValues(alpha: 0.13),
                  color: accent,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                capacityLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
