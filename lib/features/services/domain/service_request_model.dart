import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceRequest {
  final String id;
  final String freelancerId;
  final String clientId;
  final String title;
  final String description;
  final double budget;
  final DateTime deadline;
  final String status; // 'pendente', 'aceito', 'recusado', 'concluído'
  final DateTime createdAt;

  ServiceRequest({
    required this.id,
    required this.freelancerId,
    required this.clientId,
    required this.title,
    required this.description,
    required this.budget,
    required this.deadline,
    required this.status,
    required this.createdAt,
  });

  // Remover o getter 'prazo' incorreto (usar 'deadline' diretamente)

  factory ServiceRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceRequest(
      id: doc.id,
      freelancerId: data['freelancerId'],
      clientId: data['clientId'],
      title: data['title'],
      description: data['description'],
      budget: data['budget'].toDouble(),
      deadline: (data['deadline'] as Timestamp).toDate(),
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'freelancerId': freelancerId,
      'clientId': clientId,
      'title': title,
      'description': description,
      'budget': budget,
      'deadline': Timestamp.fromDate(deadline), // Converter para Timestamp
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt), // Converter para Timestamp
    };
  }
}