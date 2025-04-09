import 'package:flutter/material.dart';
import 'package:freela_app/features/freelancer/domain/freelancer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freela_app/features/freelancer/domain/data/freelancer_repository.dart';
import 'package:freela_app/features/freelancer/views/freelancer_profile_screen.dart';
import 'package:freela_app/features/search/bloc/search_bloc.dart';
import 'package:freela_app/features/search/bloc/search_event.dart';
import 'package:freela_app/features/search/bloc/search_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<String> _recentIds = [];
  final int _maxRecent = 5;

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentIds = prefs.getStringList('recentFreelancers') ?? [];
    });
  }

  Future<void> _addRecent(String freelancerId) async {
    final prefs = await SharedPreferences.getInstance();
    _recentIds = _recentIds.where((id) => id != freelancerId).toList();
    _recentIds.insert(0, freelancerId);
    if (_recentIds.length > _maxRecent) _recentIds.removeLast();
    await prefs.setStringList('recentFreelancers', _recentIds);
    _loadRecent();
  }

  Future<void> _removeRecent(String freelancerId) async {
    final prefs = await SharedPreferences.getInstance();
    _recentIds.remove(freelancerId);
    await prefs.setStringList('recentFreelancers', _recentIds);
    _loadRecent();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(FreelancerRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buscar Prestadores'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterModal(context),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nome, serviço ou localização...',
              suffixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onChanged: (value) {
              context.read<SearchBloc>().add(SearchFreelancers(query: value));
            },
          ),
        );
      },
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(freelancer.servicos.join(', ')),
                    if (freelancer.distancia != null)
                      Text(
                        'Distância: ${_formatarDistancia(freelancer.distancia!)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('⭐ ${freelancer.avaliacaoMedia.toStringAsFixed(1)}'),
                    if (freelancer.distancia != null)
                      Text(
                        '${_formatarDistancia(freelancer.distancia!)}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  _addRecent(freelancer.id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          FreelancerProfileScreen(freelancerId: freelancer.id),
                    ),
                  );
                },
              );
            },
          );
        }
        return _buildRecentList();
      },
    );
  }

  Widget _buildRecentList() {
    if (_recentIds.isEmpty) {
      return const Center(child: Text('Nenhum prestador acessado recentemente'));
    }

    return FutureBuilder<List<Freelancer>>(
      future: _getRecentFreelancers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Acessados Recentemente:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final freelancer = snapshot.data![index];
                  return ListTile(
                    title: Text(freelancer.nome),
                    subtitle: Text(freelancer.servicos.join(', ')),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeRecent(freelancer.id),
                    ),
                    onTap: () {
                      _addRecent(freelancer.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FreelancerProfileScreen(
                              freelancerId: freelancer.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Freelancer>> _getRecentFreelancers() async {
    final repository = FreelancerRepository();
    List<Freelancer> recent = [];

    for (String id in _recentIds) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('prestadores')
            .doc(id)
            .get();
        if (doc.exists) {
          recent.add(Freelancer.fromFirestore(doc));
        }
      } catch (e) {
        print('Erro ao carregar prestador recente: $e');
      }
    }
    return recent;
  }

  String _formatarDistancia(double metros) {
    if (metros < 1000) return '${metros.round()}m';
    return '${(metros / 1000).toStringAsFixed(1)}km';
  }

  void _showFilterModal(BuildContext context) {
    String? selectedServico;
    GeoPoint? selectedLocalizacao;
    double? selectedAvaliacao = 0.0;
    double raioKm = 10;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Corrige altura do modal
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    hint: const Text('Selecione um serviço'),
                    items: const [
                      DropdownMenuItem(value: 'Design', child: Text('Design')),
                      DropdownMenuItem(value: 'Programação', child: Text('Programação')),
                    ],
                    onChanged: (value) => selectedServico = value,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                        if (!serviceEnabled) {
                          throw 'Ative os serviços de localização';
                        }

                        LocationPermission permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                          if (permission == LocationPermission.denied) {
                            throw 'Permissão de localização negada';
                          }
                        }

                        if (permission == LocationPermission.deniedForever) {
                          throw 'Permissão permanentemente negada';
                        }

                        final position = await Geolocator.getCurrentPosition();
                        selectedLocalizacao = GeoPoint(
                          position.latitude,
                          position.longitude,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Localização capturada com sucesso!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const Text('Usar localização atual'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Avaliação Mínima:'),
                  StatefulBuilder( // Corrige atualização do slider
                    builder: (context, setState) {
                      return Slider(
                        min: 0,
                        max: 5,
                        divisions: 5,
                        value: selectedAvaliacao!,
                        label: selectedAvaliacao?.toStringAsFixed(1),
                        onChanged: (value) => setState(() => selectedAvaliacao = value),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SearchBloc>().add(
                        SearchFreelancers(
                          servico: selectedServico,
                          localizacaoUsuario: selectedLocalizacao,
                          avaliacaoMinima: selectedAvaliacao,
                          raioKm: raioKm,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Aplicar Filtros'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
