
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/ahp_provider.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AhpProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Agro-AHP Pro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle('Maintenance Criteria'),
            _buildList(provider.criteria, Icons.check_circle_outline),
            const SizedBox(height: 24),
            _buildSectionTitle('Machines (Alternatives)'),
            _buildList(provider.alternatives, Icons.precision_manufacturing),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  provider.initMatrices();
                  Navigator.pushNamed(context, '/comparison');
                },
                child: const Text('START ASSESSMENT'),
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade800, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Case Study: Pabrik Gula Tebu',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Student: Dindam Darusalam',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 16),
          Text(
            'Microservices-Based Maintenance Decision System',
            style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildList(List<String> items, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: items.map((item) {
          return ListTile(
            leading: Icon(icon, color: Colors.green),
            title: Text(item, style: const TextStyle(fontWeight: FontWeight.w500)),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX();
  }
}
