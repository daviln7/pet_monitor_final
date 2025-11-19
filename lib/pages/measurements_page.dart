import 'package:flutter/material.dart';
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
  String? _lastAlertType;
  DateTime? _lastAlertTime;

  void _checkVitalsAndCreateAlert(Map<String, dynamic> data) {
    final double? temp = double.tryParse(data['temperature']?.toString() ?? '');
    final double? heartRate =
        double.tryParse(data['heartRate']?.toString() ?? '');
    final double? spo2 = double.tryParse(data['spo2']?.toString() ?? '');

    if (temp == null || heartRate == null || spo2 == null) return;

    String? alertType;
    // Estes nomes agora batem com o pet_models.dart
    if (temp > widget.pet.thresholds.maxTemp)
      alertType = 'Temperatura Alta';
    else if (temp < widget.pet.thresholds.minTemp)
      alertType = 'Temperatura Baixa';
    else if (heartRate > widget.pet.thresholds.maxHeartRate)
      alertType = 'Taquicardia';
    else if (heartRate < widget.pet.thresholds.minHeartRate)
      alertType = 'Bradicardia';
    else if (spo2 < widget.pet.thresholds.minSpo2)
      alertType = 'Baixa Oxigenação';

    if (alertType != null) {
      final now = DateTime.now();
      if (_lastAlertType != alertType ||
          _lastAlertTime == null ||
          now.difference(_lastAlertTime!) > const Duration(minutes: 5)) {
        _lastAlertType = alertType;
        _lastAlertTime = now;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('ALERTA: $alertType!'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet.name)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 800;
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
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
                                fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.pet.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall),
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
                      StreamBuilder<Map<String, dynamic>>(
                        stream:
                            _firestoreService.getLatestVitals(widget.pet.id),
                        builder: (context, snapshot) {
                          if (snapshot.hasError)
                            return const Text('Erro ao carregar');
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return const CircularProgressIndicator();
                          final data = snapshot.data ?? {};
                          if (data.isNotEmpty) _checkVitalsAndCreateAlert(data);

                          final heartRate =
                              data['heartRate']?.toStringAsFixed(0) ?? '--';
                          final temperature =
                              data['temperature']?.toStringAsFixed(1) ?? '--';
                          final spo2 = data['spo2']?.toStringAsFixed(0) ?? '--';
                          final battery =
                              data['batteryLevel']?.toStringAsFixed(0) ?? '--';

                          return GridView.count(
                            crossAxisCount: isWideScreen ? 4 : 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: isWideScreen ? 1.4 : 1.2,
                            children: [
                              VitalSignCard(
                                  icon: Icons.favorite,
                                  label: 'Frequência',
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
                      Text("Histórico das Medições",
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      FutureBuilder<List<VitalSign>>(
                        future:
                            _firestoreService.getVitalsHistory(widget.pet.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            return const CircularProgressIndicator();
                          final history = snapshot.data ?? [];
                          if (history.isEmpty)
                            return const Text("Sem histórico recente.");

                          final tempSpots = history
                              .asMap()
                              .entries
                              .map((e) => FlSpot(
                                  e.key.toDouble(), e.value.temperature ?? 0))
                              .toList();
                          final bpmSpots = history
                              .asMap()
                              .entries
                              .map((e) => FlSpot(
                                  e.key.toDouble(), e.value.heartRate ?? 0))
                              .toList();
                          final spo2Spots = history
                              .asMap()
                              .entries
                              .map((e) =>
                                  FlSpot(e.key.toDouble(), e.value.spo2 ?? 0))
                              .toList();

                          return Column(
                            children: [
                              VitalsChart(
                                  title: "Temperatura (°C)",
                                  dataPoints: tempSpots,
                                  lineColor: Colors.orange),
                              const SizedBox(height: 16),
                              VitalsChart(
                                  title: "Frequência Cardíaca (BPM)",
                                  dataPoints: bpmSpots,
                                  lineColor: Colors.red),
                              const SizedBox(height: 16),
                              VitalsChart(
                                  title: "Saturação de Oxigénio (%)",
                                  dataPoints: spo2Spots,
                                  lineColor: Colors.blue),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
