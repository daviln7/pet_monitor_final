// lib/services/firestore_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/pet_models.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  late final CollectionReference<Pet> _petsRef;
  late final CollectionReference _usersRef;
  late final CollectionReference _vitalsRef;
  // --- NOVO ---
  // Referência para a coleção de alertas.
  late final CollectionReference _alertsRef;

  FirestoreService() {
    _petsRef = _db.collection('pets').withConverter<Pet>(
          fromFirestore: (snapshots, _) => Pet.fromMap(snapshots.data()!),
          toFirestore: (pet, _) => pet.toMap(),
        );
    _usersRef = _db.collection('users');
    _vitalsRef = _db.collection('vitals');
    // --- NOVO ---
    // Inicializa a referência da coleção de alertas.
    _alertsRef = _db.collection('alerts');
  }

  // --- NOVO ---
  /// Cria um novo documento de alerta no Firestore.
  Future<void> createAlert(Alert alert) async {
    try {
      // Usamos 'add' para que o Firestore gere um ID automático para o alerta.
      await _alertsRef.add({
        'petId': alert.petId,
        'petName': alert.petName,
        'ownerId': alert.ownerId,
        'timestamp': alert.timestamp,
        'message': alert.message,
        'severity': alert.severity,
        'acknowledged': false,
      });
      debugPrint("Alerta criado com sucesso: ${alert.message}");
    } catch (e) {
      debugPrint("Erro ao criar alerta: $e");
    }
  }

  // --- NOVO ---
  /// Busca os últimos 20 registos de sinais vitais para um pet, para usar nos gráficos.
  Future<List<VitalSign>> getVitalHistory(String petId) async {
    try {
      final querySnapshot = await _vitalsRef
          .doc(petId)
          .collection(
              'history') // Assumindo que o histórico fica numa subcoleção
          .orderBy('timestamp', descending: true)
          .limit(20) // Pega os 20 mais recentes
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      // Converte os documentos do Firestore para a nossa classe VitalSign
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp).toDate();
        return VitalSign(
          timestamp: timestamp,
          heartRate: data['heartRate']?.toDouble(),
          temperature: data['temperature']?.toDouble(),
          spo2: data['spo2']?.toDouble(),
          batteryLevel: data['batteryLevel']?.toDouble(),
        );
      }).toList();
    } catch (e) {
      debugPrint("Erro ao buscar histórico de sinais vitais: $e");
      return [];
    }
  }

  Future<void> saveUserToken(String userId) async {
    try {
      await _fcm.requestPermission();
      String? token = await _fcm.getToken();

      if (token != null) {
        await _usersRef.doc(userId).set({
          'fcmToken': token,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        debugPrint("FCM Token salvo para o usuário: $userId");
      }
    } catch (e) {
      debugPrint("Erro ao salvar o token FCM: $e");
    }
  }

  Future<String?> uploadAvatar(String petId, File imageFile) async {
    try {
      final ref = _storage.ref().child('avatars').child('$petId.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Erro no upload do avatar: $e");
      return null;
    }
  }

  Future<List<Pet>> getPetsForUser(String userId) async {
    try {
      final querySnapshot =
          await _petsRef.where('ownerId', isEqualTo: userId).get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint("Erro ao buscar pets: $e");
      return [];
    }
  }

  Future<void> setPet(Pet pet) async {
    try {
      await _petsRef.doc(pet.id).set(pet, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Erro ao salvar o pet: $e");
      throw Exception('Não foi possível salvar os dados do pet.');
    }
  }

  Future<void> deletePet(String petId) async {
    try {
      await _petsRef.doc(petId).delete();
      await _storage.ref().child('avatars').child('$petId.jpg').delete();
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        debugPrint("Avatar para deletar não encontrado, continuando...");
      } else {
        debugPrint("Erro ao deletar o pet: $e");
      }
    }
  }

  Stream<DocumentSnapshot> getVitalsStream(String petId) {
    return _vitalsRef.doc(petId).snapshots();
  }
}
