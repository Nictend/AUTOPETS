/// Registro de uma porção efetivamente liberada pela máquina.
class FeedingRecord {
  const FeedingRecord({
    required this.id,
    required this.petId,
    required this.servedAt,
    required this.portionGrams,
    required this.source,
  });

  final String id;
  final String petId;
  final DateTime servedAt;
  final int portionGrams;
  final FeedingSource source;

  String get sourceLabel =>
      source == FeedingSource.manual ? 'Manual' : 'Programada';
}

enum FeedingSource { manual, scheduled }
