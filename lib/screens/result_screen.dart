
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/ahp_provider.dart';
import '../services/api_service.dart';
import '../models/ahp_data.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<AhpResult> _calculationFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AhpProvider>(context, listen: false);
    _calculationFuture = ApiService().submitAhpCalculation(provider.getSubmitData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Decision Results')),
      body: FutureBuilder<AhpResult>(
        future: _calculationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'Error Calculating Results',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                           final provider = Provider.of<AhpProvider>(context, listen: false);
                           _calculationFuture = ApiService().submitAhpCalculation(provider.getSubmitData());
                        });
                      },
                      child: const Text('RETRY CONNECTION'),
                    )
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            return _buildResults(snapshot.data!);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildResults(AhpResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConsistencyCard(result.consistencyRatio),
          const SizedBox(height: 24),
          const Text(
            'Machine Priority Ranking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.3,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: result.results.map((e) => e.score).reduce((a, b) => a > b ? a : b) * 1.2,
                    titlesData: FlTitlesData(
                      show: true,
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            if (value.toInt() < result.results.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  result.results[value.toInt()].alternative.split(' ').first, // Short name
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: result.results.asMap().entries.map((entry) {
                      int idx = entry.key;
                      AhpRank rank = entry.value;
                      return BarChartGroupData(
                        x: idx,
                        barRods: [
                          BarChartRodData(
                            toY: rank.score,
                            color: idx == 0 ? Colors.green : Colors.green.shade200,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 1.0, // Should be max possible score? Usually scores sum to 1.
                              color: Colors.grey.shade100,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Detailed Scores',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: result.results.length,
            itemBuilder: (context, index) {
              final item = result.results[index];
              return Card(
                elevation: 0,
                color: index == 0 ? Colors.green.shade50 : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: index == 0 ? Colors.green : Colors.grey.shade200,
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: index == 0 ? Colors.green : Colors.grey.shade300,
                    foregroundColor: index == 0 ? Colors.white : Colors.black54,
                    child: Text('#${item.rank}'),
                  ),
                  title: Text(
                    item.alternative,
                    style: TextStyle(fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal),
                  ),
                  trailing: Text(
                    (item.score * 100).toStringAsFixed(2) + '%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyCard(double cr) {
    bool isConsistent = cr <= 0.1;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConsistent ? Colors.blue.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isConsistent ? Colors.blue.shade200 : Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(isConsistent ? Icons.check_circle : Icons.warning_amber, color: isConsistent ? Colors.blue : Colors.orange),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consistency Ratio (CR): ${cr.toStringAsFixed(3)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                isConsistent ? 'Judgments are consistent (< 0.1)' : 'Inconsistent! Please review inputs.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
