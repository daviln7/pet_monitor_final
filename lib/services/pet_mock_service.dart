import 'dart:async';
import '../models/pet_models.dart';

class PetMockService {
  // Simula um banco de dados local
  final List<Pet> _pets = [
    Pet(
      id: '1',
      name: 'Rex',
      breed: 'Labrador',
      species: Species.dog,
      age: 5,
      ownerId: 'user1',
      healthStatus:
          HealthStatus.healthy, // Corrigido de 'stable' para 'healthy'
      thresholds: VitalThresholds(
        minHeartRate: 60, // Corrigido nomes
        maxHeartRate: 140,
        minTemp: 37.5,
        maxTemp: 39.5,
        minSpo2: 95,
      ),
    ),
    Pet(
      id: '2',
      name: 'Mia',
      breed: 'Siamês',
      species: Species.cat,
      age: 3,
      ownerId: 'user1',
      healthStatus:
          HealthStatus.warning, // Corrigido de 'attention' para 'warning'
      thresholds: VitalThresholds(
        minHeartRate: 100,
        maxHeartRate: 200,
        minTemp: 38.0,
        maxTemp: 39.2,
        minSpo2: 95,
      ),
    ),
  ];

  Stream<List<Pet>> getPetsStream() {
    // Retorna a lista atual como um stream
    return Stream.value(_pets);
  }

  void addPet(Pet pet) {
    _pets.add(pet);
  }

  void updatePet(Pet updatedPet) {
    final index = _pets.indexWhere((p) => p.id == updatedPet.id);
    if (index != -1) {
      _pets[index] = updatedPet;
    }
  }

  void deletePet(String id) {
    _pets.removeWhere((p) => p.id == id);
  }
}
