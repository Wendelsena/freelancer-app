import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freela_app/features/freelancer/domain/freelancer_model.dart';
import 'package:freela_app/features/chat/views/chat_screen.dart';
import 'package:freela_app/features/services/views/service_request_screen.dart';

class FreelancerProfileScreen extends StatelessWidget {
  final String freelancerId;

  const FreelancerProfileScreen({
    super.key,
    required this.freelancerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('prestadores')
            .doc(freelancerId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Prestador não encontrado'));
          }

          // Converte o DocumentSnapshot em um objeto Freelancer
          final freelancer = Freelancer.fromFirestore(snapshot.data!);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    freelancer.fotoUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  _ProfileHeader(freelancer: freelancer),
                  _ServiceInfo(freelancer: freelancer),
                  _PortfolioSection(freelancer: freelancer),
                  _ReviewsSection(freelancer: freelancer),
                ]),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showContactOptions(context),
        icon: const Icon(Icons.contact_page),
        label: const Text('Contatar'),
      ),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Enviar Mensagem'),
            onTap: () => _navigateToChat(context),
          ),
          ListTile(
            leading: const Icon(Icons.request_page),
            title: const Text('Solicitar Serviço'),
            onTap: () => _navigateToServiceRequest(context),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(freelancerId: freelancerId),
      ),
    );
  }

  void _navigateToServiceRequest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceRequestScreen(freelancerId: freelancerId),
      ),
    );
  }
}

// Componente: Cabeçalho do Perfil
class _ProfileHeader extends StatelessWidget {
  final Freelancer freelancer;

  const _ProfileHeader({required this.freelancer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            freelancer.nome,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.star, color: Colors.amber[700], size: 20),
              const SizedBox(width: 4),
              Text(
                freelancer.avaliacaoMedia.toStringAsFixed(1),
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 16),
              Icon(Icons.location_on, color: Colors.grey, size: 20),
              const SizedBox(width: 4),
              Text(
                '${freelancer.localizacao.latitude.toStringAsFixed(4)}, '
                '${freelancer.localizacao.longitude.toStringAsFixed(4)}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            freelancer.bio,
            style: TextStyle(color: Colors.grey[600], height: 1.5),
          ),
        ],
      ),
    );
  }
}

// Componente: Informações do Serviço
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
            _buildInfoRow('Serviços', freelancer.servicos.join(', ')),
            _buildInfoRow('Experiência', '2 anos'),
            _buildInfoRow('Serviços Concluídos', freelancer.servicosConcluidos.toString()),
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

// Componente: Seção de Portfólio
class _PortfolioSection extends StatelessWidget {
  final Freelancer freelancer;

  const _PortfolioSection({required this.freelancer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Portfólio',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: freelancer.portfolio.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    freelancer.portfolio[index],
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// Componente: Seção de Avaliações
class _ReviewsSection extends StatelessWidget {
  final Freelancer freelancer;

  const _ReviewsSection({required this.freelancer});

  @override
  Widget build(BuildContext context) {
    final reviews = freelancer.reviews;

    if (reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Ainda não há avaliações.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avaliações',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...reviews.map((review) => _ReviewItem(review: review)),
        ],
      ),
    );
  }
}

// Componente: Item de Avaliação
class _ReviewItem extends StatelessWidget {
  final Review review;

  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline, size: 40),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.usuario,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber[700], size: 16),
                          const SizedBox(width: 4),
                          Text(review.avaliacao.toStringAsFixed(1)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comentario),
          ],
        ),
      ),
    );
  }
}
