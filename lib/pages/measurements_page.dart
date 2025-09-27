// lib/pages/measurements_page.dart (VERSÃO ATUALIZADA)

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NOVO: Importe o Firestore
import 'package:provider/provider.dart';
import '../models/pet_models.dart';
import '../providers/pet_provider.dart';
import '../services/firestore_service.dart'; // NOVO: Importe o FirestoreService
import '../widgets/vital_sign_card.dart';
import '../widgets/vitals_chart.dart';

class MeasurementsPage extends StatefulWidget {
  final Pet pet;
  const MeasurementsPage({super.key, required this.pet});

  @override
  _MeasurementsPageState createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage> {
  // NOVO: Criamos uma instância do nosso serviço de Firestore.
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<VitalSign>> _vitalHistoryFuture;

  @override
  void initState() {
    super.initState();
    // Nenhuma alteração aqui, a lógica para buscar o histórico continua perfeita.
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    _vitalHistoryFuture = petProvider.getVitalHistory(widget.pet.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.pet.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seção de Cabeçalho (sem alterações)
            Row(
              children: [
                ClipRRect(/* ... seu código ... */),
                const SizedBox(width: 16),
                Expanded(child: Column(/* ... seu código ... */)),
              ],
            ),
            const SizedBox(height: 24),

            //******************************************************************
            //    ↓↓↓   AQUI ESTÁ A PRINCIPAL MUDANÇA   ↓↓↓
            //******************************************************************
            // Trocamos o 'Consumer' por um 'StreamBuilder' para ouvir
            // diretamente as atualizações do documento de sinais vitais.
            StreamBuilder<DocumentSnapshot>(
              // 1. A Fonte dos Dados:
              // Nos conectamos diretamente ao stream do Firestore para este pet.
              stream: _firestoreService.getVitalsStream(widget.pet.id),

              // 2. O Construtor da UI:
              // Esta função é chamada sempre que novos dados chegam.
              builder: (context, snapshot) {
                // Lidamos com os diferentes estados da conexão.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Enquanto espera, podemos mostrar os cards com um indicador de carregamento.
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro de conexão em tempo real.'),
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text('Aguardando dados do sensor...'),
                  );
                }

                // Se temos dados, extraímos e mostramos.
                final data = snapshot.data!.data() as Map<String, dynamic>;

                final heartRate =
                    data['heartRate']?.toStringAsFixed(1) ?? 'N/A';
                final temperature =
                    data['temperature']?.toStringAsFixed(1) ?? 'N/A';
                final spo2 = data['spo2']?.toStringAsFixed(1) ?? 'N/A';
                // Adicione outros campos que o sensor enviar, como 'activityLevel'
                // final activity = data['activityLevel']?.toStringAsFixed(1) ?? 'N/A';

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    VitalSignCard(
                      icon: Icons.favorite,
                      label: 'Frequência Cardíaca',
                      value: heartRate,
                      unit: 'BPM',
                      color: Colors.red,
                    ),
                    VitalSignCard(
                      icon: Icons.thermostat,
                      label: 'Temperatura',
                      value: temperature,
                      unit: '°C',
                      color: Colors.orange,
                    ),
                    VitalSignCard(
                      icon: Icons.air,
                      label: 'SpO₂',
                      value: spo2,
                      unit: '%',
                      color: Colors.blue,
                    ),
                    const VitalSignCard(
                      icon: Icons.directions_run,
                      label: 'Atividade',
                      value: 'N/A', // O sensor precisa enviar este dado
                      unit: '%',
                      color: Colors.green,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // O FutureBuilder para os gráficos permanece o mesmo,
            // pois o histórico não precisa ser em tempo real.
            FutureBuilder<List<VitalSign>>(
              future: _vitalHistoryFuture,
              builder: (context, snapshot) {
                // Nenhuma alteração aqui, seu código para o histórico está ótimo.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // ... seu código ...
                }
                if (snapshot.hasError) {
                  // ... seu código ...
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // ... seu código ...
                }

                // ... resto do seu código para construir os gráficos ...
                return Column(
                  children: [/* ... seus widgets VitalsChart ... */],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
