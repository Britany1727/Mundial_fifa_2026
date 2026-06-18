import 'package:flutter/material.dart';
import '../../data/repositories/fixtures_repository_impl.dart';
import '../../domain/entities/stadium_entity.dart';
import '../../domain/usecases/get_stadiums.dart';
import '../theme/wc_colors.dart';

const double wcRadius = 16.0;

class StadiumsScreen extends StatefulWidget {
  const StadiumsScreen({super.key});

  @override
  State<StadiumsScreen> createState() => _StadiumsScreenState();
}

class _StadiumsScreenState extends State<StadiumsScreen> {
  late Future<List<StadiumEntity>> _stadiumsFuture;
  final _searchController = TextEditingController();
  String _query = '';
  final _useCase = GetStadiums(FixturesRepositoryImpl());

  @override
  void initState() {
    super.initState();
    _stadiumsFuture = _useCase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<StadiumEntity> _filter(List<StadiumEntity> stadiums) {
    if (_query.isEmpty) return stadiums;
    final q = _query.toLowerCase();
    return stadiums.where((s) =>
      s.name.toLowerCase().contains(q) ||
      s.city.toLowerCase().contains(q)
    ).toList();
  }

  String _formatCapacity(int cap) {
    if (cap >= 1000) {
      return '${(cap / 1000).toStringAsFixed(cap % 1000 == 0 ? 0 : 1)} mil';
    }
    return cap.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WcColors.navyDark, // antes: color por defecto del Theme
      appBar: AppBar(
        backgroundColor: WcColors.navy, // antes: color por defecto del Theme
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Estadios',
            style: TextStyle(fontWeight: FontWeight.w900)), // antes: FontWeight.bold
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar estadio o ciudad...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)), // antes: 0xFF8FA8C0
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.4), size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.white.withOpacity(0.4), size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: WcColors.navy, // antes: 0xFF1A2F4A
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(wcRadius), // antes: circular(10)
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<StadiumEntity>>(
              future: _stadiumsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: WcColors.teal),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off, color: WcColors.live, size: 48), // antes: redAccent
                          const SizedBox(height: 16),
                          const Text('Error al cargar estadios',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text(snapshot.error.toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                }
                final stadiums = _filter(snapshot.data ?? []);
                if (stadiums.isEmpty) {
                  return Center(
                    child: Text('No hay estadios disponibles',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: stadiums.length,
                  itemBuilder: (ctx, i) {
                    final s = stadiums[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: WcColors.navy, // antes: 0xFF1A2F4A
                        borderRadius: BorderRadius.circular(wcRadius), // antes: circular(12)
                        border: Border.all(color: Colors.white.withOpacity(0.05)), // mismo borde sutil que el resto de tarjetas
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: WcColors.navyDark, // antes: 0xFF0A3D62
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.stadium, color: WcColors.teal, size: 28), // antes: 0xFFFFC300
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s.name,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('${s.city}, ${s.country}',
                                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)), // antes: 0xFF8FA8C0
                                ],
                              ),
                            ),
                            Text(_formatCapacity(s.capacity),
                                style: const TextStyle(
                                    color: WcColors.yellow, fontSize: 14, fontWeight: FontWeight.w600)), // antes: 0xFFFFC300
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}