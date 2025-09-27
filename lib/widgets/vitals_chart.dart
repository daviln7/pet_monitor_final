import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Um widget reutilizável para exibir um gráfico de linha.
class VitalsChart extends StatelessWidget {
  final String title;
  final List<FlSpot> dataPoints; // O formato de dados que o fl_chart usa.
  final Color lineColor;

  const VitalsChart({
    super.key,
    required this.title,
    required this.dataPoints,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // AspectRatio garante que o gráfico mantenha uma proporção, evitando distorções.
        AspectRatio(
          aspectRatio: 2, // Largura é 2x a altura.
          // O widget principal do pacote fl_chart para gráficos de linha.
          child: LineChart(
            LineChartData(
              // Tira as bordas do gráfico.
              borderData: FlBorderData(show: false),
              // Configura as linhas de grade.
              gridData: const FlGridData(show: true),
              // Configura os títulos dos eixos X e Y.
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              // Define os dados da linha a ser desenhada.
              lineBarsData: [
                LineChartBarData(
                  spots: dataPoints, // Os pontos (x, y) do gráfico.
                  isCurved: true, // Desenha a linha com curvas suaves.
                  color: lineColor,
                  barWidth: 3,
                  dotData: const FlDotData(
                    show: false,
                  ), // Esconde os pontos individuais.
                  belowBarData: BarAreaData(
                    // Área colorida abaixo da linha.
                    show: true,
                    color: lineColor.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
