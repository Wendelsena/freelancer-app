import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freela_app/features/freelancer/domain/data/freelancer_repository.dart';
import 'package:freela_app/features/freelancer/views/freelancer_profile_screen.dart';
import 'package:freela_app/features/search/bloc/search_bloc.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SearchBloc searchBloc = SearchBloc(FreelancerRepository());

    return BlocProvider.value(
      value: searchBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buscar Prestadores'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterModal(context, searchBloc),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(searchBloc),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(SearchBloc bloc) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Buscar por nome, serviço ou localização...',
          suffixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onChanged: (value) {
          bloc.add(SearchFreelancers(query: value));
        },
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        if (state is SearchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SearchError) {
          return Center(child: Text(state.message));
        }
        if (state is SearchSuccess) {
          return ListView.builder(
            itemCount: state.freelancers.length,
            itemBuilder: (context, index) {
              final freelancer = state.freelancers[index];
              return ListTile(
                title: Text(freelancer.nome),
                subtitle: Text(freelancer.servicos.join(', ')),
                trailing: Text('⭐ ${freelancer.avaliacaoMedia.toStringAsFixed(1)}'),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FreelancerProfileScreen(freelancerId: freelancer.id),
                  ),
                ),
              );
            },
          );
        }
        return const Center(child: Text('Digite para iniciar a busca'));
      },
    );
  }

  void _showFilterModal(BuildContext context, SearchBloc bloc) {
    String? selectedServico;
    String? selectedLocalizacao;
    double? selectedAvaliacao = 0.0;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filtro de Serviço
              DropdownButtonFormField<String>(
                hint: const Text('Selecione um serviço'),
                items: const [
                  DropdownMenuItem(value: 'Design', child: Text('Design')),
                  DropdownMenuItem(value: 'Programação', child: Text('Programação')),
                  DropdownMenuItem(value: 'Mecânico', child: Text('Mecânico')),
                  DropdownMenuItem(value: 'Encanador', child: Text('Encanador')),
                ],
                onChanged: (value) => selectedServico = value,
              ),

              // Filtro de Localização
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Localização (ex: São Paulo, SP)',
                ),
                onChanged: (value) => selectedLocalizacao = value,
              ),

              // Filtro de Avaliação Mínima
              Slider(
                min: 0,
                max: 5,
                divisions: 5,
                label: selectedAvaliacao?.toStringAsFixed(1),
                value: selectedAvaliacao ?? 0,
                onChanged: (value) {
                  selectedAvaliacao = value;
                },
              ),

              // Botão de Aplicar
              ElevatedButton(
                onPressed: () {
                  bloc.add(SearchFreelancers(
                    servico: selectedServico,
                    localizacao: selectedLocalizacao,
                    avaliacaoMinima: selectedAvaliacao,
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Aplicar Filtros'),
              ),
            ],
          ),
        );
      },
    );
  }
}
