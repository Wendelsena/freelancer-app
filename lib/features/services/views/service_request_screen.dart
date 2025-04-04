import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:freela_app/features/services/domain/service_request_model.dart';

class ServiceRequestScreen extends StatefulWidget {
  final String freelancerId;

  const ServiceRequestScreen({super.key, required this.freelancerId});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  DateTime? _selectedDeadline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar Serviço')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // ... (restante do código igual)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate() && _selectedDeadline != null) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('Usuário não autenticado');

        final request = ServiceRequest(
          id: '',
          freelancerId: widget.freelancerId,
          clientId: user.uid,
          title: _titleController.text,
          description: _descriptionController.text,
          budget: double.parse(_budgetController.text),
          deadline: _selectedDeadline!,
          status: 'pendente',
          createdAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('solicitacoes')
            .add(request.toMap());

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação enviada com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${e.toString()}')),
        );
      }
    }
  }
}