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

  Map<String, dynamic> toMap() {
    return {
      'freelancerId': freelancerId,
      'clientId': clientId,
      'title': title,
      'description': description,
      'budget': budget,
      'deadline': deadline,
      'status': status,
      'createdAt': createdAt,
    };
  }
}