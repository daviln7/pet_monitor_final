// lib/providers/pet_provider.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart'; // --- ALTERAÇÃO: Importado para usar o Timestamp
import '../models/pet_models.dart';
import '../services/firestore_service.dart';

class PetProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<Pet> _pets = [];
  List<Alert> _alerts =
      []; // --- ALTERAÇÃO: A lista de alertas agora virá do Firestore
  String? _currentUserId;

  // --- ALTERAÇÃO: Variáveis para ouvir os alertas em tempo real do Firestore
  StreamSubscription? _alertSubscription;
  final CollectionReference _alertsRef =
      FirebaseFirestore.instance.collection('alerts');

  // --- ALTERAÇÃO: Removido o timer de simulação daqui para evitar confusão.
  // Timer? _simulationTimer;

  PetProvider() {
    // A simulação não começa mais automaticamente.
  }

  // Getters
  List<Pet> get pets => [..._pets];
  List<Alert> get alerts {
    _alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return [..._alerts];
  }

  // Carrega os pets e começa a ouvir os alertas
  Future<void> loadUserPets(String userId) async {
    _currentUserId = userId;
    _pets = await _firestoreService.getPetsForUser(userId);

    // --- ALTERAÇÃO: Inicia o "ouvinte" de alertas do Firestore
    _listenToAlerts();

    notifyListeners();
  }

  // Limpa os dados e cancela os "ouvintes" ao fazer logout
  void clearData() {
    _pets.clear();
    _alerts.clear();
    _currentUserId = null;

    // --- ALTERAÇÃO: Para o "ouvinte" de alertas para não usar recursos desnecessariamente
    _alertSubscription?.cancel();

    notifyListeners();
  }

  // --- ALTERAÇÃO: Lógica de adicionar pet corrigida para garantir que a URL seja salva ---
  Future<void> addPet({
    required String name,
    required String breed,
    required Species species,
    required int age,
    File? avatarFile,
    required VitalThresholds thresholds,
  }) async {
    if (_currentUserId == null) {
      throw Exception('Usuário não autenticado.');
    }

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
      avatarFile: null, // O ficheiro local não é guardado no estado
      avatarUrl: avatarUrl, // Salva a URL da nuvem
      ownerId: _currentUserId!,
      healthStatus: HealthStatus.unknown,
      thresholds: thresholds,
    );

    await _firestoreService.setPet(newPet);
    _pets.add(newPet);
    notifyListeners();
  }

  // --- ALTERAÇÃO: Lógica de atualizar pet corrigida para não perder a URL da foto ---
  Future<void> updatePet(Pet updatedPet) async {
    Pet petToSave = updatedPet;

    // 1. Se uma NOVA imagem foi selecionada no formulário...
    if (updatedPet.avatarFile != null) {
      // ...faz o upload e obtém a nova URL.
      final newAvatarUrl = await _firestoreService.uploadAvatar(
        updatedPet.id,
        updatedPet.avatarFile!,
      );
      // Atualiza o objeto com a nova URL, mantendo o resto dos dados.
      petToSave = petToSave.copyWith(avatarUrl: newAvatarUrl, avatarFile: null);
    }
    // Se não foi selecionada uma nova imagem, a 'avatarUrl' original é mantida.

    // 2. Salva o objeto final no Firestore
    await _firestoreService.setPet(petToSave);

    // 3. Atualiza a lista local para refletir na UI
    final petIndex = _pets.indexWhere((pet) => pet.id == petToSave.id);
    if (petIndex != -1) {
      _pets[petIndex] = petToSave;
      notifyListeners();
    }
  }

  Future<void> deletePet(String petId) async {
    await _firestoreService.deletePet(petId);
    _pets.removeWhere((pet) => pet.id == petId);
    notifyListeners();
  }

  // --- ALTERAÇÃO: Nova função para ouvir os alertas do Firestore em tempo real ---
  void _listenToAlerts() {
    // Cancela qualquer "ouvinte" anterior para evitar duplicações
    _alertSubscription?.cancel();

    if (_currentUserId == null) return;

    // Cria um "ouvinte" que busca alertas onde o 'ownerId' é igual ao do usuário logado
    _alertSubscription = _alertsRef
        .where('ownerId', isEqualTo: _currentUserId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      // Converte os documentos do Firestore para a nossa classe Alert
      _alerts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Alert(
          id: doc.id, // Usa o ID do documento do Firestore
          petId: data['petId'],
          petName: data['petName'],
          ownerId: data['ownerId'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          message: data['message'],
          severity: data['severity'],
          acknowledged: data['acknowledged'],
        );
      }).toList();

      // Notifica a UI para se redesenhar com a nova lista de alertas
      notifyListeners();
    }, onError: (error) {
      debugPrint("Erro ao ouvir alertas: $error");
    });
  }

  void acknowledgeAlert(String alertId) {
    // Esta função ainda está a atualizar apenas localmente.
    // Para uma implementação completa, você adicionaria um método no FirestoreService
    // para atualizar o campo 'acknowledged' para 'true' no Firestore.
    final alertIndex = _alerts.indexWhere((alert) => alert.id == alertId);
    if (alertIndex != -1) {
      final oldAlert = _alerts[alertIndex];
      _alerts[alertIndex] = Alert(
        id: oldAlert.id,
        petId: oldAlert.petId,
        petName: oldAlert.petName,
        ownerId: oldAlert.ownerId, // Garante que o ownerId é mantido
        timestamp: oldAlert.timestamp,
        message: oldAlert.message,
        severity: oldAlert.severity,
        acknowledged: true,
      );
      notifyListeners();
    }
  }

  // As suas funções de simulação podem continuar aqui para testes, se desejar.
  // ...

  @override
  void dispose() {
    // --- ALTERAÇÃO: Garante que o "ouvinte" de alertas é cancelado ao fechar o app
    _alertSubscription?.cancel();
    super.dispose();
  }

  // As suas funções getLatestVitalForPet e getVitalHistory não são mais necessárias aqui,
  // pois a lógica foi movida para o FirestoreService e para a simulação na página de medições.
  // Pode mantê-las ou removê-las para limpar o código.
}
