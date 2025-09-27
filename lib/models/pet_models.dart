// lib/models/pet_models.dart
import 'dart:io';
import 'package:flutter/material.dart';

enum Species {
  dog,
  cat;

  String get displayName {
    switch (this) {
      case Species.dog:
        return 'Cachorro';
      case Species.cat:
        return 'Gato';
    }
  }
}

enum HealthStatus { stable, attention, critical, unknown }

class User {
  final String id;
  final String email;
  final bool isGuest;

  User({required this.id, required this.email, required this.isGuest});
}

class Pet {
  final String id;
  final String name;
  final String breed;
  final Species species;
  final int age;
  final String? avatarUrl;
  final File? avatarFile;
  final String ownerId;
  final HealthStatus healthStatus;
  final VitalThresholds thresholds;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.species,
    required this.age,
    this.avatarUrl,
    this.avatarFile,
    required this.ownerId,
    required this.healthStatus,
    required this.thresholds,
  });

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    Species? species,
    int? age,
    String? avatarUrl,
    File? avatarFile,
    String? ownerId,
    HealthStatus? healthStatus,
    VitalThresholds? thresholds,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      species: species ?? this.species,
      age: age ?? this.age,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarFile: avatarFile ?? this.avatarFile,
      ownerId: ownerId ?? this.ownerId,
      healthStatus: healthStatus ?? this.healthStatus,
      thresholds: thresholds ?? this.thresholds,
    );
  }

  ImageProvider get avatar {
    if (avatarFile != null) {
      return FileImage(avatarFile!);
    }
    if (avatarUrl != null) {
      return NetworkImage(avatarUrl!);
    }
    if (species == Species.dog) {
      return const AssetImage('assets/images/default_dog.png');
    } else {
      return const AssetImage('assets/images/default_cat.png');
    }
  }

  // NOVO: Converte um objeto Pet para um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'species': species.toString().split('.').last,
      'age': age,
      'avatarUrl': avatarUrl, // O avatarUrl é o que será salvo!
      //'avatarFile': avatarFile?.path, // REMOVA OU COMENTE ESTA LINHA
      'ownerId': ownerId,
      'healthStatus': healthStatus.toString().split('.').last,
      'heartRateMin': thresholds.heartRateMin,
      'heartRateMax': thresholds.heartRateMax,
      'temperatureMin': thresholds.temperatureMin,
      'temperatureMax': thresholds.temperatureMax,
      'spo2Min': thresholds.spo2Min,
    };
  }

  // NOVO: Cria um objeto Pet a partir de um Map
  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'],
      name: map['name'],
      breed: map['breed'],
      species: Species.values.firstWhere(
        (e) => e.toString() == 'Species.${map['species']}',
      ),
      age: map['age'],
      avatarUrl: map['avatarUrl'],
      avatarFile: map['avatarFile'] != null ? File(map['avatarFile']) : null,
      ownerId: map['ownerId'],
      healthStatus: HealthStatus.values.firstWhere(
        (e) => e.toString() == 'HealthStatus.${map['healthStatus']}',
      ),
      thresholds: VitalThresholds(
        heartRateMin: map['heartRateMin'],
        heartRateMax: map['heartRateMax'],
        temperatureMin: map['temperatureMin'],
        temperatureMax: map['temperatureMax'],
        spo2Min: map['spo2Min'],
      ),
    );
  }
}

class VitalSign {
  final DateTime timestamp;
  final double? heartRate;
  final double? temperature;
  final double? spo2;
  final double? activityLevel;

  VitalSign({
    required this.timestamp,
    this.heartRate,
    this.temperature,
    this.spo2,
    this.activityLevel,
  });
}

class VitalThresholds {
  final double heartRateMin;
  final double heartRateMax;
  final double temperatureMin;
  final double temperatureMax;
  final double spo2Min;

  VitalThresholds({
    required this.heartRateMin,
    required this.heartRateMax,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.spo2Min,
  });
}

class Alert {
  final String id;
  final String petId;
  final String petName;
  final DateTime timestamp;
  final String message;
  final String severity;
  final bool acknowledged;

  Alert({
    required this.id,
    required this.petId,
    required this.petName,
    required this.timestamp,
    required this.message,
    required this.severity,
    required this.acknowledged,
  });
}
