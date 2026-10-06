import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pet.dart';

/// Preferências do pet, da máquina e da experiência do aplicativo.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.pet,
    required this.isMachineOnline,
    required this.notificationsEnabled,
    required this.darkMode,
    required this.onPetChanged,
    required this.onMachineConnectionChanged,
    required this.onNotificationsChanged,
    required this.onThemeChanged,
  });

  final Pet pet;
  final bool isMachineOnline;
  final bool notificationsEnabled;
  final bool darkMode;
  final ValueChanged<Pet> onPetChanged;
  final ValueChanged<bool> onMachineConnectionChanged;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool>? onThemeChanged;

  Future<void> _editPet(BuildContext context) async {
    final details = await showDialog<_PetDetails>(
      context: context,
      builder: (_) => _EditPetDialog(pet: pet),
    );

    if (!context.mounted ||
        details == null ||
        details.name.isEmpty ||
        details.breed.isEmpty ||
        (details.name == pet.name &&
            details.breed == pet.breed &&
            details.ageInYears == pet.ageInYears &&
            details.species == pet.species)) {
      return;
    }

    onPetChanged(
      pet.copyWith(
        name: details.name,
        breed: details.breed,
        ageInYears: details.ageInYears,
        species: details.species,
        avatarEmoji: details.avatarEmoji,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados do pet atualizados.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
                'Ajustes',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Personalize a experiência do PetFeeder.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _SectionLabel(label: 'Seu pet'),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      pet.avatarEmoji,
                      style: const TextStyle(fontSize: 27),
                    ),
                  ),
                  title: Text(
                    pet.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(pet.details),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _editPet(context),
                ),
              ),
              const SizedBox(height: 24),
              _SectionLabel(label: 'Máquina'),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                child: Column(
                  children: [
                    _SettingsSwitchTile(
                      icon: isMachineOnline
                          ? Icons.wifi_rounded
                          : Icons.wifi_off_rounded,
                      title: 'Conexão da máquina',
                      subtitle: isMachineOnline
                          ? 'Online e pronta para servir'
                          : 'Offline',
                      value: isMachineOnline,
                      onChanged: onMachineConnectionChanged,
                    ),
                    const Divider(height: 1, indent: 68),
                    const ListTile(
                      leading: Icon(Icons.inventory_2_outlined),
                      title: Text('Capacidade do reservatório'),
                      subtitle: Text('2,0 kg'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _SectionLabel(label: 'Preferências'),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                child: Column(
                  children: [
                    _SettingsSwitchTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notificações',
                      subtitle: 'Alertas de refeição e nível de ração',
                      value: notificationsEnabled,
                      onChanged: onNotificationsChanged,
                    ),
                    const Divider(height: 1, indent: 68),
                    _SettingsSwitchTile(
                      icon: darkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      title: 'Tema escuro',
                      subtitle: 'Usar uma aparência mais confortável à noite',
                      value: darkMode,
                      onChanged: onThemeChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'PetFeeder · versão 1.0.0',
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

class _EditPetDialog extends StatefulWidget {
  const _EditPetDialog({required this.pet});

  final Pet pet;

  @override
  State<_EditPetDialog> createState() => _EditPetDialogState();
}

class _EditPetDialogState extends State<_EditPetDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _breedController;
  late final TextEditingController _ageController;
  late final TextEditingController _otherSpeciesController;
  late PetKind _selectedKind;
  String? _validationMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _breedController = TextEditingController(text: widget.pet.breed);
    _ageController = TextEditingController(
      text: widget.pet.ageInYears.toString(),
    );

    final matchingKind = commonPetKinds.where(
      (kind) => kind.species == widget.pet.species,
    );
    _selectedKind = matchingKind.isEmpty
        ? commonPetKinds.last
        : matchingKind.first;
    _otherSpeciesController = TextEditingController(
      text: _selectedKind.isOther ? widget.pet.species : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _otherSpeciesController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final breed = _breedController.text.trim();
    final age = int.tryParse(_ageController.text);
    final species = _selectedKind.isOther
        ? _otherSpeciesController.text.trim()
        : _selectedKind.species;

    if (name.isEmpty ||
        breed.isEmpty ||
        species.isEmpty ||
        age == null ||
        age < 0 ||
        age > 99) {
      setState(() {
        _validationMessage =
            'Preencha nome, raça, espécie e uma idade entre 0 e 99 anos.';
      });
      return;
    }

    Navigator.of(context).pop(
      _PetDetails(
        name: name,
        breed: breed,
        ageInYears: age,
        species: species,
        avatarEmoji: _selectedKind.emoji,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      scrollable: true,
      title: const Text('Dados do pet'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _breedController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Raça'),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'Idade (anos)'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 24),
            Text(
              'Tipo de animal',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final kind in commonPetKinds)
                  ChoiceChip(
                    avatar: Text(kind.emoji),
                    label: Text(kind.species),
                    selected: _selectedKind.species == kind.species,
                    onSelected: (_) => setState(() {
                      _selectedKind = kind;
                      _validationMessage = null;
                    }),
                  ),
              ],
            ),
            if (_selectedKind.isOther) ...[
              const SizedBox(height: 14),
              TextField(
                controller: _otherSpeciesController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Qual é o animal?',
                ),
                onSubmitted: (_) => _save(),
              ),
            ],
            if (_validationMessage != null) ...[
              const SizedBox(height: 14),
              Text(
                _validationMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}

class _PetDetails {
  const _PetDetails({
    required this.name,
    required this.breed,
    required this.ageInYears,
    required this.species,
    required this.avatarEmoji,
  });

  final String name;
  final String breed;
  final int ageInYears;
  final String species;
  final String avatarEmoji;
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
