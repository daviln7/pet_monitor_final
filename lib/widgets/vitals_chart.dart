import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class VitalsChart extends StatelessWidget {
  final String title;
  final List<FlSpot> dataPoints;
  final Color lineColor; // Certifique-se que esta linha existe

  const VitalsChart({
    super.key,
    required this.title,
    required this.dataPoints,
    required this.lineColor, // E esta também
  });

  @override
  Widget build(BuildContext context) {
    // Proteção para lista vazia
    if (dataPoints.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const SizedBox(
              height: 150,
              child: Center(child: Text("Sem dados para o gráfico"))),
        ],
      );
    }

    final double minY =
        dataPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b) - 2;
    final double maxY =
        dataPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b) + 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: dataPoints,
                  isCurved: true,
                  color: lineColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        lineColor.withOpacity(0.3),
                        lineColor.withOpacity(0.0)
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              minY: minY,
              maxY: maxY,
              titlesData: const FlTitlesData(
                leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
