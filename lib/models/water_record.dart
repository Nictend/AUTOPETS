/// Registro de uma porção de água liberada pela máquina.
class WaterRecord {
  const WaterRecord({
    required this.id,
    required this.petId,
    required this.servedAt,
    required this.volumeMilliliters,
  });

  final String id;
  final String petId;
  final DateTime servedAt;
  final int volumeMilliliters;
}
