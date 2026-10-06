import 'package:flutter/material.dart';

import '../models/feeding_record.dart';
import '../models/feeding_schedule.dart';
import '../models/pet.dart';
import '../models/water_record.dart';
import '../services/feeder_service.dart';
import '../widgets/food_level_card.dart';
import '../widgets/machine_status.dart';
import '../widgets/pet_card.dart';
import 'feed_screen.dart';
import 'history_screen.dart';
import 'schedules_screen.dart';
import 'settings_screen.dart';
import 'water_screen.dart';

/// Ponto de entrada da experiência do equipamento e seu dashboard.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.feederService,
    this.darkMode = false,
    this.onThemeChanged,
  });

  final FeederService? feederService;
  final bool darkMode;
  final ValueChanged<bool>? onThemeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FeederService _feederService;
  var _selectedIndex = 0;
  var _isDispensing = false;
  var _isWaterDispensing = false;
  var _foodLevel = 72;
  var _waterLevel = 80;
  var _notificationsEnabled = true;
  var _pet = const Pet(
    id: 'thor',
    name: 'Thor',
    species: 'Cão',
    breed: 'Golden Retriever',
    ageInYears: 3,
  );

  final List<FeedingSchedule> _schedules = [
    const FeedingSchedule(id: 'morning', hour: 8, minute: 0, portionGrams: 40),
    const FeedingSchedule(id: 'lunch', hour: 12, minute: 30, portionGrams: 50),
    const FeedingSchedule(id: 'evening', hour: 18, minute: 0, portionGrams: 50),
    const FeedingSchedule(id: 'night', hour: 22, minute: 0, portionGrams: 30),
  ];
  final List<FeedingRecord> _history = [];
  final List<WaterRecord> _waterHistory = [];

  @override
  void initState() {
    super.initState();
    _feederService = widget.feederService ?? FeederService();

    final now = DateTime.now();
    _history.addAll([
      FeedingRecord(
        id: 'scheduled-today',
        petId: _pet.id,
        servedAt: now.subtract(const Duration(hours: 4)),
        portionGrams: 40,
        source: FeedingSource.scheduled,
      ),
      FeedingRecord(
        id: 'manual-yesterday',
        petId: _pet.id,
        servedAt: now.subtract(const Duration(days: 1, hours: 3)),
        portionGrams: 50,
        source: FeedingSource.manual,
      ),
      FeedingRecord(
        id: 'scheduled-yesterday',
        petId: _pet.id,
        servedAt: now.subtract(const Duration(days: 1, hours: 8)),
        portionGrams: 50,
        source: FeedingSource.scheduled,
      ),
    ]);
    _waterHistory.add(
      WaterRecord(
        id: 'water-today',
        petId: _pet.id,
        servedAt: now.subtract(const Duration(hours: 2)),
        volumeMilliliters: 250,
      ),
    );
  }

  Future<void> _dispenseFood(int portionGrams) async {
    if (_isDispensing || _isWaterDispensing) return;

    setState(() => _isDispensing = true);

    try {
      final record = await _feederService.dispenseFood(
        petId: _pet.id,
        portionGrams: portionGrams,
      );
      if (!mounted) return;

      final foodReduction = (portionGrams / 15).round();
      setState(() {
        _foodLevel = (_foodLevel - foodReduction).clamp(0, 100);
        _history.insert(0, record);
      });
      _showMessage('$portionGrams g liberados para ${_pet.name}.');
    } on FeederUnavailableException {
      if (!mounted) return;
      _showMessage(
        'A máquina está offline. Tente novamente quando reconectar.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isDispensing = false);
    }
  }

  Future<void> _dispenseWater(int volumeMilliliters) async {
    if (_isDispensing || _isWaterDispensing) return;

    setState(() => _isWaterDispensing = true);

    try {
      final record = await _feederService.dispenseWater(
        petId: _pet.id,
        volumeMilliliters: volumeMilliliters,
      );
      if (!mounted) return;

      final waterReduction = (volumeMilliliters / 25).round();
      setState(() {
        _waterLevel = (_waterLevel - waterReduction).clamp(0, 100);
        _waterHistory.insert(0, record);
      });
      _showMessage(
        '$volumeMilliliters ml de água liberados para ${_pet.name}.',
      );
    } on FeederUnavailableException {
      if (!mounted) return;
      _showMessage(
        'A máquina está offline. Tente novamente quando reconectar.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isWaterDispensing = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: isError
                    ? colorScheme.errorContainer
                    : colorScheme.primaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  void _saveSchedule(FeedingSchedule schedule) {
    setState(() {
      final index = _schedules.indexWhere((item) => item.id == schedule.id);
      if (index == -1) {
        _schedules.add(schedule);
      } else {
        _schedules[index] = schedule;
      }
      _schedules.sort((first, second) {
        final firstMinutes = first.hour * 60 + first.minute;
        final secondMinutes = second.hour * 60 + second.minute;
        return firstMinutes.compareTo(secondMinutes);
      });
    });
  }

  void _removeSchedule(String scheduleId) {
    setState(() => _schedules.removeWhere((item) => item.id == scheduleId));
    _showMessage('Horário removido.');
  }

  void _setMachineOnline(bool isOnline) {
    setState(() => _feederService.isOnline = isOnline);
    _showMessage(
      isOnline ? 'Máquina conectada.' : 'Máquina definida como offline.',
    );
  }

  _NextMeal? _nextMeal() {
    final now = DateTime.now();
    final activeSchedules =
        _schedules.where((schedule) => schedule.enabled).toList()
          ..sort((first, second) {
            final firstMinutes = first.hour * 60 + first.minute;
            final secondMinutes = second.hour * 60 + second.minute;
            return firstMinutes.compareTo(secondMinutes);
          });

    for (var dayOffset = 0; dayOffset <= 7; dayOffset++) {
      final date = DateTime(now.year, now.month, now.day + dayOffset);
      for (final schedule in activeSchedules) {
        if (!schedule.weekdays.contains(date.weekday)) continue;
        final scheduledAt = DateTime(
          date.year,
          date.month,
          date.day,
          schedule.hour,
          schedule.minute,
        );
        if (scheduledAt.isAfter(now)) {
          return _NextMeal(schedule: schedule, scheduledAt: scheduledAt);
        }
      }
    }
    return null;
  }

  String _capacityLabel() {
    final kilograms = 2 * _foodLevel / 100;
    return '${kilograms.toStringAsFixed(1).replaceAll('.', ',')} kg disponível';
  }

  @override
  Widget build(BuildContext context) {
    final nextMeal = _nextMeal();
    final pages = <Widget>[
      _Dashboard(
        pet: _pet,
        isMachineOnline: _feederService.isOnline,
        foodLevel: _foodLevel,
        foodCapacityLabel: _capacityLabel(),
        waterLevel: _waterLevel,
        nextMeal: nextMeal,
        notificationsEnabled: _notificationsEnabled,
        isDispensing: _isDispensing || _isWaterDispensing,
        onFeedNow: _dispenseFood,
        onSeeWater: () => setState(() => _selectedIndex = 2),
        onSeeSchedules: () => setState(() => _selectedIndex = 3),
      ),
      FeedScreen(
        isMachineOnline: _feederService.isOnline,
        isDispensing: _isDispensing || _isWaterDispensing,
        onFeed: _dispenseFood,
      ),
      WaterScreen(
        waterLevel: _waterLevel,
        isMachineOnline: _feederService.isOnline,
        isDispensing: _isDispensing || _isWaterDispensing,
        records: _waterHistory,
        onDispense: _dispenseWater,
      ),
      SchedulesScreen(
        schedules: _schedules,
        onScheduleChanged: _saveSchedule,
        onScheduleCreated: _saveSchedule,
        onScheduleDeleted: _removeSchedule,
      ),
      HistoryScreen(records: _history),
      SettingsScreen(
        pet: _pet,
        isMachineOnline: _feederService.isOnline,
        notificationsEnabled: _notificationsEnabled,
        darkMode: widget.darkMode,
        onPetChanged: (pet) => setState(() => _pet = pet),
        onMachineConnectionChanged: _setMachineOnline,
        onNotificationsChanged: (enabled) =>
            setState(() => _notificationsEnabled = enabled),
        onThemeChanged: widget.onThemeChanged,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: KeyedSubtree(
            key: ValueKey(_selectedIndex),
            child: pages[_selectedIndex],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets_rounded),
            label: 'Ração',
          ),
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop_rounded),
            label: 'Água',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule_rounded),
            label: 'Horários',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}

class _NextMeal {
  const _NextMeal({required this.schedule, required this.scheduledAt});

  final FeedingSchedule schedule;
  final DateTime scheduledAt;

  String get relativeLabel {
    final difference = scheduledAt.difference(DateTime.now());
    if (difference.inDays >= 1) return 'amanhã';
    if (difference.inHours >= 1) {
      return 'em ${difference.inHours}h ${difference.inMinutes.remainder(60)}min';
    }
    return 'em ${difference.inMinutes.clamp(1, 59)} min';
  }

  String get dateLabel {
    final now = DateTime.now();
    final isToday =
        now.year == scheduledAt.year &&
        now.month == scheduledAt.month &&
        now.day == scheduledAt.day;
    return isToday ? 'Hoje' : 'Amanhã';
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({
    required this.pet,
    required this.isMachineOnline,
    required this.foodLevel,
    required this.foodCapacityLabel,
    required this.waterLevel,
    required this.nextMeal,
    required this.notificationsEnabled,
    required this.isDispensing,
    required this.onFeedNow,
    required this.onSeeWater,
    required this.onSeeSchedules,
  });

  final Pet pet;
  final bool isMachineOnline;
  final int foodLevel;
  final String foodCapacityLabel;
  final int waterLevel;
  final _NextMeal? nextMeal;
  final bool notificationsEnabled;
  final bool isDispensing;
  final ValueChanged<int> onFeedNow;
  final VoidCallback onSeeWater;
  final VoidCallback onSeeSchedules;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quickPortion = nextMeal?.schedule.portionGrams ?? 50;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, seja bem-vindo',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'PetFeeder',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Notificações',
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          notificationsEnabled
                              ? 'Você receberá alertas da máquina.'
                              : 'As notificações estão desativadas.',
                        ),
                      ),
                    ),
                    icon: Badge(
                      isLabelVisible: notificationsEnabled,
                      child: const Icon(Icons.notifications_none_rounded),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PetCard(
                pet: pet,
                statusMessage: isMachineOnline
                    ? 'A rotina do ${pet.name} está em dia.'
                    : 'A máquina precisa de atenção.',
              ),
              const SizedBox(height: 24),
              Text(
                'Visão geral',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 156,
                child: Row(
                  children: [
                    Expanded(child: MachineStatus(isOnline: isMachineOnline)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FoodLevelCard(
                        percentage: foodLevel,
                        capacityLabel: foodCapacityLabel,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1677B8).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.water_drop_rounded,
                      color: Color(0xFF1677B8),
                    ),
                  ),
                  title: const Text('Reservatório de água'),
                  subtitle: Text('$waterLevel% disponível'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: onSeeWater,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Próxima refeição',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onSeeSchedules,
                    child: const Text('Ver horários'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (nextMeal case final meal?)
                _NextMealCard(
                  meal: meal,
                  colorScheme: colorScheme,
                  theme: theme,
                )
              else
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: const Icon(Icons.event_busy_rounded),
                    title: const Text('Nenhuma refeição programada'),
                    subtitle: const Text(
                      'Adicione um horário para automatizar a rotina.',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: onSeeSchedules,
                  ),
                ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: isMachineOnline && !isDispensing
                    ? () => onFeedNow(quickPortion)
                    : null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: isDispensing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.restaurant_rounded),
                label: Text(
                  isDispensing ? 'Liberando ração...' : 'Alimentar agora',
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  'Porção rápida de $quickPortion g',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NextMealCard extends StatelessWidget {
  const _NextMealCard({
    required this.meal,
    required this.colorScheme,
    required this.theme,
  });

  final _NextMeal meal;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              height: 56,
              width: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.schedule_rounded,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.schedule.formattedTime,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('${meal.schedule.portionGrams} g · ${meal.dateLabel}'),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                meal.relativeLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
