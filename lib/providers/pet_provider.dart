import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/pet_models.dart';
import '../services/firestore_service.dart';

class PetProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Pet> _pets = [];
  final List<Alert> _alerts = [];
  String? _currentUserId;
  StreamSubscription<List<Pet>>? _petsSubscription;

  List<Pet> get pets => _pets;
  List<Alert> get alerts => _alerts;

  // --- FUNÇÕES DE SETUP ---

  void setUserId(String userId) {
    _currentUserId = userId;
    _fetchPets();
  }

  // Recupera a função antiga para compatibilidade com main.dart
  Future<void> loadUserPets(String userId) async {
    setUserId(userId);
    // Como agora é um Stream, não precisamos esperar nada,
    // mas mantemos o Future para não quebrar quem chama com 'await'.
  }

  void _fetchPets() {
    if (_currentUserId == null) return;

    _petsSubscription?.cancel();
    _petsSubscription =
        _firestoreService.getPetsStream(_currentUserId!).listen((petsData) {
      _pets = petsData;
      notifyListeners();
    });
  }

  // Recupera a função para limpar dados (settings_page.dart)
  void clearData() {
    _pets = [];
    _alerts.clear();
    _currentUserId = null;
    _petsSubscription?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _petsSubscription?.cancel();
    super.dispose();
  }

  // --- CRUD DE PETS ---

  Future<void> addPet({
    required String name,
    required String breed,
    required Species species,
    required int age,
    File? avatarFile,
    required VitalThresholds thresholds,
  }) async {
    if (_currentUserId == null) throw Exception('Usuário não autenticado.');

    String petId = DateTime.now().millisecondsSinceEpoch.toString();
    String? avatarUrl;

    if (avatarFile != null) {
      avatarUrl = await _firestoreService.uploadAvatar(petId, avatarFile);
    }

    final newPet = Pet(
      id: petId,
      name: name,
      breed: breed,
      species: species,
      age: age,
      avatarFile: null,
      avatarUrl: avatarUrl,
      ownerId: _currentUserId!,
      healthStatus: HealthStatus.unknown,
      thresholds: thresholds,
    );

    await _firestoreService.setPet(newPet);
  }

  Future<void> updatePet(Pet updatedPet) async {
    Pet petToSave = updatedPet;

    if (updatedPet.avatarFile != null) {
      final newAvatarUrl = await _firestoreService.uploadAvatar(
        updatedPet.id,
        updatedPet.avatarFile!,
      );
      petToSave = petToSave.copyWith(avatarUrl: newAvatarUrl, avatarFile: null);
    }

    await _firestoreService.setPet(petToSave);
  }

  Future<void> deletePet(String petId) async {
    await _firestoreService.deletePet(petId);
  }

  // --- SISTEMA DE ALERTAS ---

  void addAlert(String petId, String title, String message,
      {String severity = 'medium'}) {
    final pet = _pets.firstWhere((p) => p.id == petId,
        orElse: () => Pet(
            id: 'unknown',
            name: 'Desconhecido',
            breed: '',
            species: Species.dog,
            age: 0,
            ownerId: '',
            thresholds: VitalThresholds()));

    final newAlert = Alert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: petId,
      ownerId: pet.ownerId,
      petName: pet.name,
      title: title,
      message: message,
      severity: severity,
      timestamp: DateTime.now(),
    );

    _alerts.insert(0, newAlert);
    notifyListeners();
  }

  // Recupera a função para reconhecer alertas (alerts_page.dart)
  void acknowledgeAlert(String alertId) {
    final index = _alerts.indexWhere((a) => a.id == alertId);
    if (index != -1) {
      // Cria uma cópia do alerta marcando como lido
      // Precisamos copiar manualmente pois Alert é imutável
      final oldAlert = _alerts[index];
      _alerts[index] = Alert(
        id: oldAlert.id,
        petId: oldAlert.petId,
        ownerId: oldAlert.ownerId,
        petName: oldAlert.petName,
        title: oldAlert.title,
        message: oldAlert.message,
        severity: oldAlert.severity,
        timestamp: oldAlert.timestamp,
        acknowledged: true, // AQUI ESTÁ A MUDANÇA
      );
      notifyListeners();
    }
  }

  void clearAlerts() {
    _alerts.clear();
    notifyListeners();
  }
}
