// lib/providers/pet_provider.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/pet_models.dart';
import '../services/firestore_service.dart'; // Importa o novo serviço

class PetProvider with ChangeNotifier {
  final FirestoreService _firestoreService =
      FirestoreService(); // Instancia o serviço
  List<Pet> _pets = [];
  final List<Alert> _alerts = [];
  String? _currentUserId;
  Timer? _simulationTimer;

  PetProvider() {
    startSimulation();
  }

  // Getters
  List<Pet> get pets => [..._pets];
  List<Alert> get alerts {
    _alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return [..._alerts];
  }

  // Carrega os pets ao logar
  Future<void> loadUserPets(String userId) async {
    _currentUserId = userId;
    // Carrega os pets do Firestore
    _pets = await _firestoreService.getPetsForUser(userId);
    notifyListeners();
  }

  // Limpa os dados ao fazer logout
  void clearData() {
    _pets.clear();
    _alerts.clear();
    _currentUserId = null;
    notifyListeners();
  }

  // Adiciona um novo pet
  Future<void> addPet({
    required String name,
    required String breed,
    required Species species,
    required int age,
    File? avatarFile,
    required VitalThresholds thresholds,
  }) async {
    if (_currentUserId == null) return;

    String petId = DateTime.now().millisecondsSinceEpoch.toString();
    String? avatarUrl;

    // 1. Faz o upload da imagem (se houver) para o Firebase Storage
    if (avatarFile != null) {
      avatarUrl = await _firestoreService.uploadAvatar(petId, avatarFile);
    }

    final newPet = Pet(
      id: petId,
      name: name,
      breed: breed,
      species: species,
      age: age,
      avatarFile: avatarFile,
      avatarUrl: avatarUrl, // Salva a URL da imagem
      ownerId: _currentUserId!,
      healthStatus: HealthStatus.unknown,
      thresholds: thresholds,
    );

    // 2. Salva os dados do pet no Firestore
    await _firestoreService.setPet(newPet);

    _pets.add(newPet);
    notifyListeners();
  }

  // Atualiza um pet existente
  Future<void> updatePet(Pet updatedPet) async {
    String? newAvatarUrl;

    // 1. Verifica se uma nova imagem foi selecionada
    if (updatedPet.avatarFile != null) {
      newAvatarUrl = await _firestoreService.uploadAvatar(
        updatedPet.id,
        updatedPet.avatarFile!,
      );
    }

    // Cria uma cópia final para salvar, com a nova URL se houver
    final finalPet = updatedPet.copyWith(
      avatarUrl: newAvatarUrl, // usa a nova URL ou mantém a antiga se for nula
    );

    // 2. Salva as alterações no Firestore
    await _firestoreService.setPet(finalPet);

    final petIndex = _pets.indexWhere((pet) => pet.id == finalPet.id);
    if (petIndex >= 0) {
      _pets[petIndex] = finalPet;
      notifyListeners();
    }
  }

  // Deleta um pet
  Future<void> deletePet(String petId) async {
    await _firestoreService.deletePet(petId);
    _pets.removeWhere((pet) => pet.id == petId);
    notifyListeners();
  }

  // O restante da sua classe (simulação, acknowledgeAlert, etc.) pode continuar o mesmo.
  // ...

  // Reconhece um alerta
  void acknowledgeAlert(String alertId) {
    final alertIndex = _alerts.indexWhere((alert) => alert.id == alertId);
    if (alertIndex != -1) {
      final oldAlert = _alerts[alertIndex];
      _alerts[alertIndex] = Alert(
        id: oldAlert.id,
        petId: oldAlert.petId,
        petName: oldAlert.petName,
        timestamp: oldAlert.timestamp,
        message: oldAlert.message,
        severity: oldAlert.severity,
        acknowledged: true,
      );
      notifyListeners();
    }
  }

  void startSimulation() {
    if (_simulationTimer?.isActive ?? false) return;
    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pets.isEmpty) return;
      for (int i = 0; i < _pets.length; i++) {
        _simulateVitalsForPet(i);
      }
      notifyListeners();
    });
  }

  void _simulateVitalsForPet(int petIndex) {
    // ...Sua lógica de simulação...
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
  }

  VitalSign getLatestVitalForPet(String petId) {
    final random = Random();
    return VitalSign(
      timestamp: DateTime.now(),
      heartRate: 70 + random.nextDouble() * 20,
      temperature: 38.5 + random.nextDouble() * 1.0,
      spo2: 95 + random.nextDouble() * 4,
      activityLevel: 40 + random.nextDouble() * 50,
    );
  }

  Future<List<VitalSign>> getVitalHistory(String petId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final List<VitalSign> history = [];
    final random = Random();
    final now = DateTime.now();
    for (int i = 50; i > 0; i--) {
      history.add(
        VitalSign(
          timestamp: now.subtract(Duration(minutes: i * 5)),
          heartRate: 70 + random.nextDouble() * 20,
          temperature: 38.0 + random.nextDouble() * 1.5,
        ),
      );
    }
    return history;
  }

  @override
  void dispose() {
    stopSimulation();
    super.dispose();
  }
}
