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

  // Coleção de pets
  late final CollectionReference<Pet> _petsRef;
  late final CollectionReference _usersRef;
  late final CollectionReference
  _vitalsRef; // Variável de referência para os sinais vitais

  FirestoreService() {
    _petsRef = _db
        .collection('pets')
        .withConverter<Pet>(
          fromFirestore: (snapshots, _) => Pet.fromMap(snapshots.data()!),
          toFirestore: (pet, _) => pet.toMap(),
        );
    _usersRef = _db.collection('users');
    _vitalsRef = _db.collection(
      'vitals',
    ); // Aponta a variável para a coleção 'vitals' no Firestore.
  }

  // NOVO: Método para salvar o token FCM do usuário
  Future<void> saveUserToken(String userId) async {
    try {
      // Solicita permissão para notificações (essencial no iOS)
      await _fcm.requestPermission();

      // Obtém o token do dispositivo
      String? token = await _fcm.getToken();

      if (token != null) {
        // Salva o token no Firestore, associado ao ID do usuário
        // Usamos SetOptions(merge: true) para não sobrescrever outros dados do usuário
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

  // --- Operações com Imagens (Firebase Storage) ---

  /// Faz o upload de um arquivo de imagem para o Firebase Storage e retorna a URL de download.
  Future<String?> uploadAvatar(String petId, File imageFile) async {
    try {
      // Define o caminho no Storage: /avatars/{petId}.jpg
      final ref = _storage.ref().child('avatars').child('$petId.jpg');

      // Faz o upload do arquivo
      UploadTask uploadTask = ref.putFile(imageFile);

      // Aguarda a conclusão do upload
      TaskSnapshot snapshot = await uploadTask;

      // Retorna a URL de download da imagem
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Erro no upload do avatar: $e");
      return null;
    }
  }

  // --- Operações com Pets (Cloud Firestore) ---

  /// Busca a lista de pets de um usuário específico.
  Future<List<Pet>> getPetsForUser(String userId) async {
    try {
      final querySnapshot = await _petsRef
          .where('ownerId', isEqualTo: userId)
          .get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint("Erro ao buscar pets: $e");
      return [];
    }
  }

  /// Adiciona ou atualiza um pet no Firestore.
  Future<void> setPet(Pet pet) async {
    try {
      // Usamos 'set' com o ID do pet para criar ou sobrescrever o documento.
      await _petsRef.doc(pet.id).set(pet, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Erro ao salvar o pet: $e");
      throw Exception('Não foi possível salvar os dados do pet.');
    }
  }

  /// Deleta um pet do Firestore.
  Future<void> deletePet(String petId) async {
    try {
      await _petsRef.doc(petId).delete();
      // Opcional: deletar também a foto do storage
      await _storage.ref().child('avatars').child('$petId.jpg').delete();
    } catch (e) {
      // Ignora erro se o arquivo não existir no storage
      if (e is FirebaseException && e.code == 'object-not-found') {
        debugPrint("Avatar para deletar não encontrado, continuando...");
      } else {
        debugPrint("Erro ao deletar o pet: $e");
      }
    }
  }

  Stream<DocumentSnapshot> getVitalsStream(String petId) {
    return _vitalsRef.doc(petId).snapshots();

    /// Retorna um Stream (fluxo) de dados para os sinais vitais de um pet específico.
    /// Este método "escuta" as mudanças no documento de sinais vitais do pet e notifica o app em tempo real sempre que os dados são atualizados.
  }
}
