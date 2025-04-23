import 'package:flutter/material.dart';
import 'package:freela_app/features/components/nav_bar.dart';
import 'package:freela_app/features/home/views/chat_list_screen.dart';
import 'package:freela_app/features/home/views/history_screen.dart';
import 'package:freela_app/features/home/views/profile._screen.dart';
import 'package:freela_app/features/home/views/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int activeMenu = 0;
  final List<String> menu = ['Serviços', 'Freelancers', 'Promoções'];
  final TextEditingController _searchController = TextEditingController();
  String _location = "São Paulo";

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }


  void _scanQRCode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR Code em desenvolvimento')),
    );
  }


   void _navigateToSearch(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchScreen()));
  }

  void _updateLocation(String newLocation) {
    setState(() => _location = newLocation);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zelo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _scanQRCode(context),
          ),
        ],
      ),
      body: _buildCurrentScreen(size),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildCurrentScreen(Size size) {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(size);
      case 1:
        return const SearchScreen();
      case 2:
        return const ChatListScreen();
      case 3:
        return const HistoryScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHomeContent(Size size) {
    return ListView(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(menu.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: GestureDetector(
                    onTap: () => setState(() => activeMenu = index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: activeMenu == index ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        child: Text(
                          menu[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: activeMenu == index ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToSearch(context),
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 15, right: 10),
                              child: Icon(Icons.search, color: Colors.grey),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Buscar serviços...',
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (value) => _navigateToSearch(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 45,
                    width: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: GestureDetector(
                      onTap: () => _showLocationDialog(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey, size: 20),
                          const SizedBox(width: 5),
                          Text(_location, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            _buildCustomSlider(),
            _buildCategoriesSection(),
            _buildFeaturedSection(size),
            _buildDivider(),
            _buildExploreSection(size),
            _buildDivider(),
            _buildPopularSection(size),
          ],
        ),
      ],
    );
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alterar Localização'),
        content: TextField(
          onSubmitted: (value) {
            _updateLocation(value);
            Navigator.pop(context);
          },
          decoration: const InputDecoration(hintText: 'Digite nova localização'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (_searchController.text.isNotEmpty) {
                _updateLocation(_searchController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomSlider() {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                'https://picsum.photos/800/400?random=$index',
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(5, (index) => Padding(
                padding: const EdgeInsets.only(left: 30, right: 35),
                child: Column(
                  children: [
                    const Icon(Icons.design_services, size: 40),
                    const SizedBox(height: 15),
                    Text('Categoria ${index + 1}', style: const TextStyle(fontSize: 14)),
                  ],
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleFavorite(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidade de favoritos em desenvolvimento')),
    );
  }

  Widget _buildFeaturedSection(Size size) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  'https://picsum.photos/800/400?random=10',
                  height: 160,
                  width: size.width,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 15,
                right: 15,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(context),
                  child: const Icon(Icons.favorite_border, color: Colors.white),
                ),
              )
            ],
          ),
          const SizedBox(height: 15),
          const Text("Serviço em Destaque", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          _buildServiceDetails(),
        ],
      ),
    );
  }

  Widget _buildServiceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text("Patrocinado", style: TextStyle(fontSize: 14)),
            SizedBox(width: 5),
            Icon(Icons.info, color: Colors.grey, size: 15),
          ],
        ),
        const SizedBox(height: 8),
        const Text("Descrição do serviço em destaque", style: TextStyle(fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildDetailChip(icon: Icons.access_time, label: "2h"),
            const SizedBox(width: 8),
            _buildDetailChip(label: "Entrega Grátis"),
            const SizedBox(width: 8),
            _buildDetailChip(label: "4.8", icon: Icons.star),
          ],
        )
      ],
    );
  }

  Widget _buildDetailChip({IconData? icon, required String label}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(
          children: [
            if (icon != null) Icon(icon, color: Colors.blue, size: 16),
            if (icon != null) const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreSection(Size size) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Mais para Explorar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 15),
                child: SizedBox(
                  width: size.width - 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceItem('https://picsum.photos/800/400?random=${index + 20}'),
                      const SizedBox(height: 15),
                      const Text("Serviço Premium", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      _buildServiceDetails(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSection(Size size) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Populares na Região", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 15),
                child: SizedBox(
                  width: size.width - 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceItem('https://picsum.photos/800/400?random=${index + 30}'),
                      const SizedBox(height: 15),
                      const Text("Serviço Popular", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      _buildServiceDetails(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String imageUrl) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 15,
          right: 15,
          child: GestureDetector(
            onTap: () => _toggleFavorite(context),
            child: const Icon(Icons.favorite_border, color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: double.infinity,
      height: 10,
      color: const Color(0xFFF5F5F5),
      margin: const EdgeInsets.symmetric(vertical: 20),
    );
  }
}