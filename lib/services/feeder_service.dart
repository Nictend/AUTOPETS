import '../models/feeding_record.dart';
import '../models/water_record.dart';

/// Camada de acesso à máquina. A comunicação real (Bluetooth/Wi-Fi) pode ser
/// conectada aqui futuramente, sem acoplar as telas ao protocolo do dispositivo.
class FeederService {
  FeederService({this.isOnline = true});

  bool isOnline;

  Future<FeedingRecord> dispenseFood({
    required String petId,
    required int portionGrams,
  }) async {
    if (!isOnline) {
      throw const FeederUnavailableException();
    }

    // Simula a confirmação do equipamento até a integração física ser feita.
    await Future<void>.delayed(const Duration(milliseconds: 700));

    return FeedingRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      petId: petId,
      servedAt: DateTime.now(),
      portionGrams: portionGrams,
      source: FeedingSource.manual,
    );
  }

  Future<WaterRecord> dispenseWater({
    required String petId,
    required int volumeMilliliters,
  }) async {
    if (!isOnline) {
      throw const FeederUnavailableException();
    }

    await Future<void>.delayed(const Duration(milliseconds: 600));

    return WaterRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      petId: petId,
      servedAt: DateTime.now(),
      volumeMilliliters: volumeMilliliters,
    );
  }
}

class FeederUnavailableException implements Exception {
  const FeederUnavailableException();
}
