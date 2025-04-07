// ... (imports anteriores)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freela_app/features/freelancer/bloc/requests_bloc.dart';
import 'package:freela_app/features/services/domain/service_request_model.dart';

class _RequestItem extends StatelessWidget {
  final ServiceRequest request;

  const _RequestItem({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(request.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prazo: ${request.deadline.toLocal().toString()}'), // Usar 'deadline'
            Text('Orçamento: R\$ ${request.budget.toStringAsFixed(2)}'), // Usar 'budget'
            Text('Status: ${request.status}'),
          ],
        ),
        trailing: request.status == 'pendente'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () => _updateStatus(context, 'aceito'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => _updateStatus(context, 'recusado'),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _updateStatus(BuildContext context, String newStatus) {
    context.read<RequestsBloc>().add(
          UpdateRequestStatus(requestId: request.id, newStatus: newStatus),
        );
  }
}