import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

enum HealthStatus {
  healthy,
  warning,
  critical,
  unknown;

  String get displayName {
    switch (this) {
      case HealthStatus.healthy:
        return 'Saudável';
      case HealthStatus.warning:
        return 'Atenção';
      case HealthStatus.critical:
        return 'Crítico';
      case HealthStatus.unknown:
        return 'Desconhecido';
    }
  }

  Color get color {
    switch (this) {
      case HealthStatus.healthy:
        return Colors.green;
      case HealthStatus.warning:
        return Colors.orange;
      case HealthStatus.critical:
        return Colors.red;
      case HealthStatus.unknown:
        return Colors.grey;
    }
  }
}

class VitalThresholds {
  final double minTemp;
  final double maxTemp;
  final double minHeartRate;
  final double maxHeartRate;
  final double minSpo2;

  VitalThresholds({
    this.minTemp = 37.5,
    this.maxTemp = 39.5,
    this.minHeartRate = 60.0,
    this.maxHeartRate = 140.0,
    this.minSpo2 = 95.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'minHeartRate': minHeartRate,
      'maxHeartRate': maxHeartRate,
      'minSpo2': minSpo2,
    };
  }

  factory VitalThresholds.fromMap(Map<String, dynamic> map) {
    return VitalThresholds(
      minTemp: (map['minTemp'] ?? 37.5).toDouble(),
      maxTemp: (map['maxTemp'] ?? 39.5).toDouble(),
      minHeartRate: (map['minHeartRate'] ?? 60.0).toDouble(),
      maxHeartRate: (map['maxHeartRate'] ?? 140.0).toDouble(),
      minSpo2: (map['minSpo2'] ?? 95.0).toDouble(),
    );
  }
}

class VitalSign {
  final DateTime timestamp;
  final double? temperature;
  final double? heartRate;
  final double? spo2;

  VitalSign({
    required this.timestamp,
    this.temperature,
    this.heartRate,
    this.spo2,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': Timestamp.fromDate(timestamp),
      'temperature': temperature,
      'heartRate': heartRate,
      'spo2': spo2,
    };
  }

  factory VitalSign.fromMap(Map<String, dynamic> map) {
    DateTime date;
    if (map['timestamp'] is Timestamp) {
      date = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is String) {
      date = DateTime.parse(map['timestamp']);
    } else {
      date = DateTime.now();
    }

    return VitalSign(
      timestamp: date,
      temperature: map['temperature'] != null
          ? (map['temperature'] as num).toDouble()
          : null,
      heartRate: map['heartRate'] != null
          ? (map['heartRate'] as num).toDouble()
          : null,
      spo2: map['spo2'] != null ? (map['spo2'] as num).toDouble() : null,
    );
  }
}

class Pet {
  final String id;
  final String name;
  final String breed;
  final Species species;
  final int age;
  final File? avatarFile;
  final String? avatarUrl;
  final String ownerId;
  final HealthStatus healthStatus;
  final VitalThresholds thresholds;

  Pet({
    required this.id,
    required this.name,
    required this.breed,
    required this.species,
    required this.age,
    this.avatarFile,
    this.avatarUrl,
    required this.ownerId,
    this.healthStatus = HealthStatus.unknown,
    required this.thresholds,
  });

  ImageProvider get avatar {
    if (avatarFile != null) return FileImage(avatarFile!);
    if (avatarUrl != null && avatarUrl!.isNotEmpty)
      return NetworkImage(avatarUrl!);
    return species == Species.dog
        ? const AssetImage('assets/images/default_dog.png')
        : const AssetImage('assets/images/default_cat.png');
  }

  Pet copyWith({
    String? id,
    String? name,
    String? breed,
    Species? species,
    int? age,
    File? avatarFile,
    String? avatarUrl,
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
      avatarFile: avatarFile ?? this.avatarFile,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ownerId: ownerId ?? this.ownerId,
      healthStatus: healthStatus ?? this.healthStatus,
      thresholds: thresholds ?? this.thresholds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'species': species.index,
      'age': age,
      'avatarUrl': avatarUrl,
      'ownerId': ownerId,
      'healthStatus': healthStatus.index,
      'thresholds': thresholds.toMap(),
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map, String documentId) {
    return Pet(
      id: documentId,
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      species: Species.values[map['species'] ?? 0],
      age: map['age'] ?? 0,
      avatarUrl: map['avatarUrl'],
      ownerId: map['ownerId'] ?? '',
      healthStatus: HealthStatus.values[map['healthStatus'] ?? 3],
      thresholds: map['thresholds'] != null
          ? VitalThresholds.fromMap(map['thresholds'])
          : VitalThresholds(),
    );
  }
}

// --- CLASSE ALERT ATUALIZADA ---
class Alert {
  final String id;
  final String petId;
  final String ownerId; // Novo campo
  final String petName; // Novo campo
  final String title;
  final String message;
  final String severity; // Novo campo (Ex: "high", "medium")
  final DateTime timestamp;
  final bool acknowledged;

  Alert({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.petName,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.acknowledged = false,
  });
}
