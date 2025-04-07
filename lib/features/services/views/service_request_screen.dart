import 'package:flutter/material.dart';
import 'package:freela_app/features/services/domain/service_request_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class ServiceRequestScreen extends StatefulWidget {
  final String freelancerId;

  const ServiceRequestScreen({
    super.key,
    required this.freelancerId,
  });

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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição'),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(labelText: 'Orçamento (R\$)'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              ListTile(
                title: Text(_selectedDeadline == null
                    ? 'Selecione o prazo'
                    : 'Prazo: ${_selectedDeadline!.toLocal().toString()}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2025),
                  );
                  if (date != null) {
                    setState(() => _selectedDeadline = date);
                  }
                },
              ),
              ElevatedButton(
                onPressed: _submitRequest,
                child: const Text('Enviar Solicitação'),
              ),
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
          id: '', // Firestore gera o ID automaticamente
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
            .add(request.toMap()); // Usar toMap() corrigido

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