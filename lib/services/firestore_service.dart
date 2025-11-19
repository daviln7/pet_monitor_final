import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/pet_models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- PETS ---
  Future<void> setPet(Pet pet) async {
    await _db.collection('pets').doc(pet.id).set(pet.toMap());
  }

  // Obtém stream de pets (usado na home)
  Stream<List<Pet>> getPetsStream(String ownerId) {
    return _db
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pet.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Função alias para corrigir o erro "getPetsForUser not defined"
  Stream<List<Pet>> getPetsForUser(String ownerId) {
    return getPetsStream(ownerId);
  }

  Future<void> deletePet(String petId) async {
    await _db.collection('pets').doc(petId).delete();
  }

  // --- IMAGENS ---
  Future<String> uploadAvatar(String petId, File imageFile) async {
    try {
      final ref = _storage.ref().child('avatars').child('$petId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Erro upload: $e');
      return '';
    }
  }

  // --- USUÁRIO / AUTH ---
  // Função placeholder para corrigir erro "saveUserToken"
  Future<void> saveUserToken(String? token) async {
    // Se você não tiver a lógica de usuário pronta, isso evita o erro.
    // Se tiver, coloque aqui a lógica para salvar o token FCM no documento do usuário.
    if (token == null) return;
    // Exemplo: await _db.collection('users').doc(userId).update({'fcmToken': token});
  }

  // --- VITAL SIGNS ---
  Stream<Map<String, dynamic>> getLatestVitals(String petId) {
    return _db.collection('vitals').doc(petId).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!;
      }
      return {};
    });
  }

  Future<List<VitalSign>> getVitalsHistory(String petId) async {
    try {
      final snapshot = await _db
          .collection('vitals')
          .doc(petId)
          .collection('history')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => VitalSign.fromMap(doc.data())).toList();
    } catch (e) {
      print("Erro histórico: $e");
      return [];
    }
  }
}
