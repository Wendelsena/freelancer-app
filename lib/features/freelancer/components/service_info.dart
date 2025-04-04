import 'package:flutter/material.dart';
import 'package:freela_app/features/freelancer/domain/freelancer_model.dart';

class _ServiceInfo extends StatelessWidget {
  final Freelancer freelancer;

  const _ServiceInfo({required this.freelancer});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Serviço Principal', freelancer.service),
            _buildInfoRow('Experiência', '2 anos'),
            _buildInfoRow('Serviços Concluídos', '${freelancer.completedJobs}'),
            _buildInfoRow('Preço Médio', 'R\$ 150,00'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}