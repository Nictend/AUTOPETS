/// Dados essenciais do pet associado à máquina de ração.
class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.ageInYears,
    this.avatarEmoji = '🐶',
  });

  final String id;
  final String name;
  final String species;
  final String breed;
  final int ageInYears;
  final String avatarEmoji;

  String get details =>
      '$species · $breed · $ageInYears ${ageInYears == 1 ? 'ano' : 'anos'}';

  Pet copyWith({
    String? name,
    String? species,
    String? breed,
    int? ageInYears,
    String? avatarEmoji,
  }) {
    return Pet(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      ageInYears: ageInYears ?? this.ageInYears,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
    );
  }
}

/// Tipo de animal exibido na seleção de pets do aplicativo.
class PetKind {
  const PetKind({
    required this.species,
    required this.emoji,
    this.isOther = false,
  });

  final String species;
  final String emoji;
  final bool isOther;
}

const commonPetKinds = <PetKind>[
  PetKind(species: 'Cão', emoji: '🐶'),
  PetKind(species: 'Gato', emoji: '🐱'),
  PetKind(species: 'Pássaro', emoji: '🐦'),
  PetKind(species: 'Peixe', emoji: '🐟'),
  PetKind(species: 'Coelho', emoji: '🐰'),
  PetKind(species: 'Hamster', emoji: '🐹'),
  PetKind(species: 'Tartaruga', emoji: '🐢'),
  PetKind(species: 'Outro', emoji: '🐾', isOther: true),
];
