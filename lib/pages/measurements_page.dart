// lib/pages/measurements_page.dart

import 'dart:math'; // --- NOVO: Para gerar dados aleatórios
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/pet_models.dart';
import '../services/firestore_service.dart';
import '../widgets/vital_sign_card.dart';
import '../widgets/vitals_chart.dart';

class MeasurementsPage extends StatefulWidget {
  final Pet pet;
  const MeasurementsPage({super.key, required this.pet});

  @override
  _MeasurementsPageState createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<VitalSign>> _vitalHistoryFuture;

  String? _lastAlertType;
  DateTime? _lastAlertTime;

  // --- NOVO: Função para gerar dados simulados para os gráficos ---
  Future<List<VitalSign>> _getSimulatedVitalHistory() async {
    // Aguarda um pouco para simular uma chamada de rede
    await Future.delayed(const Duration(seconds: 1));

    final random = Random();
    final List<VitalSign> simulatedData = [];
    final now = DateTime.now();

    // Gera 20 pontos de dados simulados
    for (int i = 0; i < 20; i++) {
      simulatedData.add(VitalSign(
        timestamp: now.subtract(
            Duration(minutes: i * 5)), // Dados a cada 5 mins no passado
        temperature: 38.5 + random.nextDouble() * 1.5, // Temp entre 38.5 e 40.0
        heartRate: 80 + random.nextInt(20).toDouble(), // BPM entre 80 e 100
        spo2: 96 + random.nextDouble() * 2, // SpO2 entre 96 e 98
      ));
    }
    // Retorna os dados em ordem cronológica (o mais antigo primeiro)
    return simulatedData.reversed.toList();
  }

  @override
  void initState() {
    super.initState();
    // --- ALTERAÇÃO: Escolha entre a função real e a de simulação ---

    // Para usar os dados REAIS do Firestore, use esta linha:
    //_vitalHistoryFuture = _firestoreService.getVitalHistory(widget.pet.id);

    // Para SIMULAR os dados e testar os gráficos, use esta linha:
    _vitalHistoryFuture = _getSimulatedVitalHistory();
  }

  void _checkVitalsAndCreateAlert(Map<String, dynamic> data) {
    final petThresholds = widget.pet.thresholds;
    String? alertMessage;
    String? currentAlertType;

    final temp = (data['temperature'] as num?)?.toDouble();
    final bpm = (data['heartRate'] as num?)?.toDouble();

    if (temp != null) {
      if (temp > petThresholds.temperatureMax) {
        alertMessage =
            "${widget.pet.name} está com febre! (${temp.toStringAsFixed(1)}°C)";
        currentAlertType = "temp_high";
      } else if (temp < petThresholds.temperatureMin) {
        alertMessage =
            "${widget.pet.name} está com hipotermia. (${temp.toStringAsFixed(1)}°C)";
        currentAlertType = "temp_low";
      }
    }

    if (bpm != null) {
      if (bpm > petThresholds.heartRateMax) {
        alertMessage =
            "${widget.pet.name} está com taquicardia! (${bpm.toInt()} BPM)";
        currentAlertType = "bpm_high";
      } else if (bpm < petThresholds.heartRateMin) {
        alertMessage =
            "${widget.pet.name} está com bradicardia. (${bpm.toInt()} BPM)";
        currentAlertType = "bpm_low";
      }
    }

    if (alertMessage != null && currentAlertType != null) {
      final now = DateTime.now();
      if (_lastAlertType == currentAlertType &&
          _lastAlertTime != null &&
          now.difference(_lastAlertTime!).inMinutes < 5) {
        return;
      }

      _lastAlertType = currentAlertType;
      _lastAlertTime = now;

      final newAlert = Alert(
        id: '',
        petId: widget.pet.id,
        petName: widget.pet.name,
        ownerId: widget.pet.ownerId,
        timestamp: now,
        message: alertMessage,
        severity: 'high',
        acknowledged: false,
      );

      _firestoreService.createAlert(newAlert);
    }
  }

  @override
  Widget build(BuildContext context) {
    // O resto do seu ficheiro `build` permanece exatamente o mesmo,
    // pois o `FutureBuilder` irá funcionar tanto com dados reais como simulados.
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet.name)),
      body: SingleChildScrollView(
        // ... (todo o seu código da UI continua aqui, sem alterações)
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image(
                      image: widget.pet.avatar,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.pet.name,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                          '${widget.pet.species.displayName} - ${widget.pet.breed}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text("Monitoramento em Tempo Real",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            StreamBuilder<DocumentSnapshot>(
              stream: _firestoreService.getVitalsStream(widget.pet.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Erro de conexão em tempo real.'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                      child: Text('Aguardando dados do sensor...'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                _checkVitalsAndCreateAlert(data);

                final heartRate =
                    data['heartRate']?.toStringAsFixed(1) ?? 'N/A';
                final temperature =
                    data['temperature']?.toStringAsFixed(1) ?? 'N/A';
                final spo2 = data['spo2']?.toStringAsFixed(1) ?? 'N/A';
                final battery =
                    data['batteryLevel']?.toStringAsFixed(0) ?? 'N/A';

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    VitalSignCard(
                        icon: Icons.favorite,
                        label: 'Frequência Cardíaca',
                        value: heartRate,
                        unit: 'BPM',
                        color: Colors.red),
                    VitalSignCard(
                        icon: Icons.thermostat,
                        label: 'Temperatura',
                        value: temperature,
                        unit: '°C',
                        color: Colors.orange),
                    VitalSignCard(
                        icon: Icons.air,
                        label: 'SpO₂',
                        value: spo2,
                        unit: '%',
                        color: Colors.blue),
                    VitalSignCard(
                        icon: Icons.battery_full,
                        label: 'Bateria',
                        value: battery,
                        unit: '%',
                        color: Colors.green),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text("Histórico das Últimas Medições",
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            FutureBuilder<List<VitalSign>>(
              future: _vitalHistoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Erro ao carregar o histórico.'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Nenhum histórico disponível.'));
                }

                final history = snapshot.data!;

                final tempSpots = history.asMap().entries.map((entry) {
                  return FlSpot(
                      entry.key.toDouble(), entry.value.temperature ?? 0);
                }).toList();

                final bpmSpots = history.asMap().entries.map((entry) {
                  return FlSpot(
                      entry.key.toDouble(), entry.value.heartRate ?? 0);
                }).toList();

                final spo2Spots = history.asMap().entries.map((entry) {
                  return FlSpot(entry.key.toDouble(), entry.value.spo2 ?? 0);
                }).toList();

                return Column(
                  children: [
                    VitalsChart(
                      title: "Temperatura (°C)",
                      dataPoints: tempSpots,
                      lineColor: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    VitalsChart(
                      title: "Frequência Cardíaca (BPM)",
                      dataPoints: bpmSpots,
                      lineColor: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    VitalsChart(
                      title: "Saturação de Oxigénio (SpO₂ %)",
                      dataPoints: spo2Spots,
                      lineColor: Colors.blue,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
