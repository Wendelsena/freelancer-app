import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freela_app/core/firebase/firebase_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _testFirestoreConnection(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTestSection(),
          Expanded(child: _buildFreelancersList()),
        ],
      ),
    );
  }

  Widget _buildTestSection() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Teste do Banco de Dados',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTestData,
              child: const Text('Adicionar Dados de Teste'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreelancersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseConfig.firestore
          .collection('usuarios')
          .where('tipo', isEqualTo: 'prestador')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final documents = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final data = documents[index].data() as Map<String, dynamic>;
            return FreelancerCard(
              name: data['nome'] ?? 'Nome não informado',
              rating: (data['avaliacao'] ?? 0.0).toDouble(),
              service: data['servico'] ?? 'Serviço não definido',
              onTap: () => _showFreelancerDetails(context, data),
            );
          },
        );
      },
    );
  }

  Future<void> _addTestData() async {
    try {
      await FirebaseConfig.firestore.collection('usuarios').add({
        'nome': 'Teste Freelancer',
        'servico': 'Desenvolvimento Flutter',
        'avaliacao': 4.8,
        'tipo': 'prestador',
        'data_criacao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Erro ao adicionar dados: $e');
    }
  }

  void _showFreelancerDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['nome']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Serviço: ${data['servico']}'),
            Text('Avaliação: ${data['avaliacao']}'),
            Text('Tipo: ${data['tipo']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _testFirestoreConnection(BuildContext context) {
    FirebaseConfig.firestore
        .collection('testes')
        .add({'timestamp': FieldValue.serverTimestamp()})
        .then((_) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Conexão com Firestore bem sucedida!')),
            ))
        .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro na conexão: $error')),
            ));
  }
}

class FreelancerCard extends StatelessWidget {
  final String name;
  final double rating;
  final String service;
  final String imageUrl;
  final VoidCallback? onTap;

  const FreelancerCard({
    super.key,
    required this.name,
    required this.rating,
    required this.service,
    this.imageUrl = 'https://picsum.photos/200',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / 
                              loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, size: 50),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber[700], size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          service,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}