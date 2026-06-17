import 'package:flutter/material.dart';
import '../../data/repositories/fixtures_repository_impl.dart';
import '../../domain/entities/stadium_entity.dart';
import '../../domain/usecases/get_stadiums.dart';

class StadiumsScreen extends StatefulWidget {
  const StadiumsScreen({super.key});

  @override
  State<StadiumsScreen> createState() => _StadiumsScreenState();
}

class _StadiumsScreenState extends State<StadiumsScreen> {
  late Future<List<StadiumEntity>> _stadiumsFuture;
  final _useCase = GetStadiums(FixturesRepositoryImpl());

  @override
  void initState() {
    super.initState();
    _stadiumsFuture = _useCase();
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
      appBar: AppBar(
        title: const Text('Estadios',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<StadiumEntity>>(
        future: _stadiumsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    const Text('Error al cargar estadios',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF8FA8C0), fontSize: 13)),
                  ],
                ),
              ),
            );
          }
          final stadiums = snapshot.data ?? [];
          if (stadiums.isEmpty) {
            return const Center(
              child: Text('No hay estadios disponibles',
                  style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 16)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stadiums.length,
            itemBuilder: (ctx, i) {
              final s = stadiums[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: const Color(0xFF1A2F4A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A3D62),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.stadium, color: Color(0xFFFFC300), size: 28),
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
                                style: const TextStyle(color: Color(0xFF8FA8C0), fontSize: 13)),
                          ],
                        ),
                      ),
                      Text(_formatCapacity(s.capacity),
                          style: const TextStyle(
                              color: Color(0xFFFFC300), fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
