import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pet_models.dart';

class AlertListItem extends StatelessWidget {
  final Alert alert;
  final Function(String alertId) onAcknowledge;

  const AlertListItem({
    super.key,
    required this.alert,
    required this.onAcknowledge,
  });

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(alert.severity);
    return Opacity(
      opacity: alert.acknowledged ? 0.6 : 1.0,
      child: Card(
        // A 'shape' pode ser definida no tema (CardTheme) ou individualmente aqui.
        // Como já definimos no tema, esta linha abaixo é opcional, mas não causa erro.
        // Se você quiser um estilo diferente para este card específico, pode descomentá-la.
        shape: RoundedRectangleBorder(
          side: BorderSide(color: color, width: 4),
          borderRadius: BorderRadius.circular(8),
        ),

        // CORRETO: A propriedade 'margin' está aqui, no widget Card individual.
        // É por isso que este arquivo não apresentava o erro do main.dart.
        margin: const EdgeInsets.symmetric(vertical: 6),

        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: color, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alerta para ${alert.petName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(alert.message),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(alert.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!alert.acknowledged)
                TextButton(
                  onPressed: () => onAcknowledge(alert.id),
                  child: const Text('Reconhecer'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
// Este widget exibe um alerta com informações sobre o pet e a gravidade do alerta.
// Ele inclui um botão para reconhecer o alerta, que chama a função onAcknowledge quando pressionado.