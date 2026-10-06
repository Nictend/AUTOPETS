import 'package:flutter/material.dart';

class MachineStatus extends StatelessWidget {
  const MachineStatus({super.key, required this.isOnline});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = isOnline ? const Color(0xFF167565) : colorScheme.error;

    return Semantics(
      label: 'Máquina ${isOnline ? 'online' : 'offline'}',
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  color: accent,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text('MÁQUINA', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 3),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: accent, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                isOnline ? 'Tudo conectado' : 'Verifique a conexão',
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
