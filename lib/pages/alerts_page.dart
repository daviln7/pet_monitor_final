import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';
import '../widgets/alert_list_item.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas')),
      // Usamos o Consumer para que a tela se reconstrua sempre que a lista de alertas mudar.
      body: Consumer<PetProvider>(
        builder: (context, petProvider, child) {
          // Filtramos os alertas em duas listas: novos e reconhecidos.
          final unacknowledged = petProvider.alerts
              .where((a) => !a.acknowledged)
              .toList();
          final acknowledged = petProvider.alerts
              .where((a) => a.acknowledged)
              .toList();

          if (petProvider.alerts.isEmpty) {
            return const Center(child: Text('Nenhum alerta no momento.'));
          }

          // Usamos um ListView para que o conteúdo seja rolável.
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Seção de Novos Alertas
              if (unacknowledged.isNotEmpty) ...[
                Text(
                  'Novos Alertas',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                // Para cada alerta não reconhecido, criamos um AlertListItem.
                ...unacknowledged
                    .map(
                      (alert) => AlertListItem(
                        alert: alert,
                        onAcknowledge: (alertId) {
                          // O botão no item da lista chama diretamente o método do provider!
                          petProvider.acknowledgeAlert(alertId);
                        },
                      ),
                    )
                    ,
                const SizedBox(height: 24),
              ],

              // Seção de Alertas Reconhecidos
              if (acknowledged.isNotEmpty) ...[
                Text(
                  'Alertas Reconhecidos',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                // Para cada alerta reconhecido, criamos um AlertListItem.
                ...acknowledged
                    .map(
                      (alert) => AlertListItem(
                        alert: alert,
                        onAcknowledge:
                            (
                              alertId,
                            ) {}, // O botão não será exibido, então a função fica vazia.
                      ),
                    )
                    ,
              ],
            ],
          );
        },
      ),
    );
  }
}
