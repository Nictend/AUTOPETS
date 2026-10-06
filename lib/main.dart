import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const PetFeederApp());
}

class PetFeederApp extends StatefulWidget {
  const PetFeederApp({super.key});

  @override
  State<PetFeederApp> createState() => _PetFeederAppState();
}

class _PetFeederAppState extends State<PetFeederApp> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PetFeeder',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B5F),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8F6),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B5F),
          brightness: Brightness.dark,
        ),
      ),

      home: HomeScreen(
        darkMode: darkMode,
        onThemeChanged: (value) => setState(() => darkMode = value),
      ),
    );
  }
}

// ============================================================
// MODELOS
// ============================================================

class FeedingSchedule {
  String time;
  int grams;
  bool enabled;

  FeedingSchedule({
    required this.time,
    required this.grams,
    this.enabled = true,
  });
}

class FeedingRecord {
  final DateTime date;
  final int grams;
  final String type;

  FeedingRecord({
    required this.date,
    required this.grams,
    required this.type,
  });
}

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const MainScreen({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  String petName = 'Thor';

  double foodLevel = 72;

  bool machineOnline = true;

  double manualAmount = 50;

  bool feeding = false;

  bool notifications = true;

  final List<FeedingSchedule> schedules = [
    FeedingSchedule(
      time: '08:00',
      grams: 40,
    ),
    FeedingSchedule(
      time: '12:30',
      grams: 50,
    ),
    FeedingSchedule(
      time: '18:00',
      grams: 50,
    ),
    FeedingSchedule(
      time: '22:00',
      grams: 30,
    ),
  ];

  final List<FeedingRecord> history = [
    FeedingRecord(
      date: DateTime(2026, 9, 8, 8, 0),
      grams: 40,
      type: 'Programada',
    ),
    FeedingRecord(
      date: DateTime(2026, 9, 7, 18, 0),
      grams: 50,
      type: 'Programada',
    ),
    FeedingRecord(
      date: DateTime(2026, 9, 7, 12, 30),
      grams: 50,
      type: 'Programada',
    ),
  ];

  // ==========================================================
  // ALIMENTAR
  // ==========================================================

  Future<void> feedPet() async {
    if (feeding) return;

    if (!machineOnline) {
      showMessage(
        'A máquina está desconectada.',
        error: true,
      );
      return;
    }

    setState(() {
      feeding = true;
    });

    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) return;

    setState(() {
      feeding = false;

      foodLevel -= manualAmount / 10;

      if (foodLevel < 0) {
        foodLevel = 0;
      }

      history.insert(
        0,
        FeedingRecord(
          date: DateTime.now(),
          grams: manualAmount.round(),
          type: 'Manual',
        ),
      );
    });

    showMessage(
      '${manualAmount.round()} g liberados para $petName',
    );
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void showMessage(
    String message, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHome(),
      buildFeed(),
      buildSchedules(),
      buildHistory(),
      buildSettings(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: pages[currentIndex],
      ),

      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Alimentar',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Horários',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HOME
  // ==========================================================

  Widget buildHome() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bom dia 👋',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'PetFeeder',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 25,
                    child: Text(
                      '🐶',
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // PET CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF8A3D),
                    Color(0xFFFF6B35),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                    color: Colors.orange
                        .withOpacity(.20),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 75,
                    width: 75,
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withOpacity(.18),
                      borderRadius:
                          BorderRadius.circular(22),
                    ),
                    child: const Center(
                      child: Text(
                        '🐶',
                        style: TextStyle(
                          fontSize: 45,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seu pet',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          petName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Tudo certo por aqui ❤️',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // STATUS
            Row(
              children: [
                Expanded(
                  child: buildInfoCard(
                    icon: machineOnline
                        ? Icons.wifi
                        : Icons.wifi_off,
                    title: 'Máquina',
                    value: machineOnline
                        ? 'Online'
                        : 'Offline',
                    positive: machineOnline,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: buildInfoCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Ração',
                    value:
                        '${foodLevel.round()}%',
                    positive: foodLevel > 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // PRÓXIMA REFEIÇÃO
            buildSectionTitle(
              'Próxima refeição',
              'Ver horários',
              () {
                setState(() {
                  currentIndex = 2;
                });
              },
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface,
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context)
                      .dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(.12),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedules.isNotEmpty
                            ? schedules.first.time
                            : '--:--',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      Text(
                        schedules.isNotEmpty
                            ? '${schedules.first.grams} g de ração'
                            : 'Sem horários',
                      ),
                    ],
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.chevron_right,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // NÍVEL
            buildSectionTitle(
              'Nível de ração',
              '${foodLevel.round()}%',
              null,
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface,
                borderRadius:
                    BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(context)
                      .dividerColor,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Reservatório',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        foodLevel > 20
                            ? 'Bom nível'
                            : 'Ração baixa',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                          color: foodLevel > 20
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: foodLevel / 100,
                      minHeight: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ALIMENTAR
            SizedBox(
              width: double.infinity,
              height: 62,
              child: FilledButton.icon(
                onPressed: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
                icon: const Icon(
                  Icons.restaurant_rounded,
                ),
                label: const Text(
                  'ALIMENTAR AGORA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // INFO CARD
  // ==========================================================

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required bool positive,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: positive
                ? Colors.green
                : Colors.red,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget buildSectionTitle(
    String title,
    String action,
    VoidCallback? onTap,
  ) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacer(),

        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: Text(action),
          )
        else
          Text(
            action,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .primary,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }

  // ==========================================================
  // ALIMENTAR
  // ==========================================================

  Widget buildFeed() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const SizedBox(height: 12),

            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alimentar',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Escolha quanto liberar para $petName',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(.12),
              ),
              child: const Center(
                child: Text(
                  '🍖',
                  style: TextStyle(
                    fontSize: 75,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              '${manualAmount.round()} g',
              style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w900,
                letterSpacing: -2,
              ),
            ),

            Text(
              'Quantidade de ração',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            Slider(
              value: manualAmount,
              min: 10,
              max: 200,
              divisions: 19,
              label:
                  '${manualAmount.round()} g',
              onChanged: feeding
                  ? null
                  : (value) {
                      setState(() {
                        manualAmount = value;
                      });
                    },
            ),

            const Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text('10 g'),
                Text('200 g'),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              children: [
                buildQuickAmount(25),
                const SizedBox(width: 10),
                buildQuickAmount(50),
                const SizedBox(width: 10),
                buildQuickAmount(100),
              ],
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surface,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context)
                      .dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    machineOnline
                        ? Icons.check_circle
                        : Icons.error,
                    color: machineOnline
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      machineOnline
                          ? 'Máquina pronta para alimentar'
                          : 'Máquina desconectada',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 65,
              child: FilledButton.icon(
                onPressed:
                    feeding ? null : feedPet,
                icon: feeding
                    ? const SizedBox(
                        height: 23,
                        width: 23,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.restaurant,
                      ),
                label: Text(
                  feeding
                      ? 'LIBERANDO RAÇÃO...'
                      : 'LIBERAR RAÇÃO',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuickAmount(int amount) {
    final selected =
        manualAmount.round() == amount;

    return Expanded(
      child: OutlinedButton(
        onPressed: feeding
            ? null
            : () {
                setState(() {
                  manualAmount =
                      amount.toDouble();
                });
              },
        style: OutlinedButton.styleFrom(
          padding:
              const EdgeInsets.symmetric(
            vertical: 15,
          ),
          backgroundColor: selected
              ? Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(.10)
              : null,
        ),
        child: Text('$amount g'),
      ),
    );
  }

  // ==========================================================
  // HORÁRIOS
  // ==========================================================

  Widget buildSchedules() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              'Horários',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Sua rotina de alimentação',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: schedules.length,
                itemBuilder: (context, index) {
                  final schedule =
                      schedules[index];

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface,
                      borderRadius:
                          BorderRadius.circular(22),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor,
                      ),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      leading: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(.12),
                          borderRadius:
                              BorderRadius.circular(
                                  16),
                        ),
                        child: Icon(
                          Icons
                              .restaurant_rounded,
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                        ),
                      ),
                      title: Text(
                        schedule.time,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${schedule.grams} g de ração',
                      ),
                      trailing: Switch(
                        value:
                            schedule.enabled,
                        onChanged: (value) {
                          setState(() {
                            schedule.enabled =
                                value;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              height: 58,
              child: FilledButton.icon(
                onPressed: addSchedule,
                icon: const Icon(Icons.add),
                label: const Text(
                  'NOVO HORÁRIO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ADICIONAR HORÁRIO
  // ==========================================================

  Future<void> addSchedule() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    int grams = 50;

    final result =
        await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title:
                  const Text('Nova refeição'),
              content: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Text(
                    time.format(context),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '$grams g',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  Slider(
                    value:
                        grams.toDouble(),
                    min: 10,
                    max: 200,
                    divisions: 19,
                    onChanged: (value) {
                      setStateDialog(() {
                        grams =
                            value.round();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(
                          context),
                  child:
                      const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.pop(
                    context,
                    grams,
                  ),
                  child:
                      const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) return;

    final hour = time.hour
        .toString()
        .padLeft(2, '0');

    final minute = time.minute
        .toString()
        .padLeft(2, '0');

    setState(() {
      schedules.add(
        FeedingSchedule(
          time: '$hour:$minute',
          grams: result,
        ),
      );

      schedules.sort(
        (a, b) =>
            a.time.compareTo(b.time),
      );
    });

    showMessage(
      'Novo horário adicionado',
    );
  }

  // ==========================================================
  // HISTÓRICO
  // ==========================================================

  Widget buildHistory() {
    final total = history.fold<int>(
      0,
      (sum, item) => sum + item.grams,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            const Text(
              'Histórico',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Acompanhe a alimentação do seu pet',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: buildStatistic(
                    'Refeições',
                    '${history.length}',
                    Icons.restaurant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: buildStatistic(
                    'Ração',
                    '${total} g',
                    Icons.scale,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Últimas alimentações',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final record =
                      history[index];

                  final date =
                      '${record.date.day.toString().padLeft(2, '0')}/'
                      '${record.date.month.toString().padLeft(2, '0')}/'
                      '${record.date.year}';

                  final time =
                      '${record.date.hour.toString().padLeft(2, '0')}:'
                      '${record.date.minute.toString().padLeft(2, '0')}';

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surface,
                      borderRadius:
                          BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor,
                      ),
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading:
                          const CircleAvatar(
                        child: Icon(
                          Icons.restaurant,
                        ),
                      ),
                      title: Text(
                        '${record.grams} g',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      subtitle:
                          Text('$date • $time'),
                      trailing: Text(
                        record.type,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatistic(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CONFIGURAÇÕES
  // ==========================================================

  Widget buildSettings() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),

          const Text(
            'Configurações',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Personalize seu PetFeeder',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 25),

          buildSettingsTile(
            icon: Icons.pets,
            title: 'Meu pet',
            subtitle: petName,
            onTap: changePetName,
          ),

          buildSettingsTile(
            icon: Icons.wifi,
            title: 'Máquina',
            subtitle: machineOnline
                ? 'Conectada'
                : 'Desconectada',
            trailing: Switch(
              value: machineOnline,
              onChanged: (value) {
                setState(() {
                  machineOnline = value;
                });
              },
            ),
          ),

          buildSettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notificações',
            subtitle:
                'Alertas e lembretes',
            trailing: Switch(
              value: notifications,
              onChanged: (value) {
                setState(() {
                  notifications = value;
                });
              },
            ),
          ),

          buildSettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Modo escuro',
            subtitle: widget.darkMode
                ? 'Ativado'
                : 'Desativado',
            trailing: Switch(
              value: widget.darkMode,
              onChanged:
                  widget.onThemeChanged,
            ),
          ),

          buildSettingsTile(
            icon: Icons.inventory_2_outlined,
            title: 'Reservatório',
            subtitle:
                '${foodLevel.round()}% de ração',
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(.08),
              borderRadius:
                  BorderRadius.circular(22),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.pets,
                  size: 35,
                ),
                SizedBox(height: 10),
                Text(
                  'PetFeeder',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Versão 1.0.0',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surface,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context)
              .dividerColor,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 5,
        ),
        leading: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(.10),
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ??
            const Icon(
              Icons.chevron_right,
            ),
        onTap: onTap,
      ),
    );
  }

  // ==========================================================
  // NOME DO PET
  // ==========================================================

  Future<void> changePetName() async {
    final controller =
        TextEditingController(
      text: petName,
    );

    final result =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Nome do pet'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration:
                const InputDecoration(
              labelText: 'Nome',
              hintText: 'Ex: Thor',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child:
                  const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                controller.text,
              ),
              child:
                  const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (result == null ||
        result.trim().isEmpty) {
      return;
    }

    setState(() {
      petName = result.trim();
    });
  }
}
