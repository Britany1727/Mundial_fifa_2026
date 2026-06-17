import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/fixtures_repository_impl.dart';
import '../../domain/entities/fixture_entity.dart';
import '../../domain/usecases/get_fixtures_by_date.dart';
import '../widgets/fixture_card.dart';
import 'fixture_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;
  late Future<List<FixtureEntity>> _fixturesFuture;

  final _useCase = GetFixturesByDate(FixturesRepositoryImpl());

  // Límites del torneo (HU-02 escenario 3)
  static final DateTime _tournamentStart = DateTime(2026, 6, 11);
  static final DateTime _tournamentEnd = DateTime(2026, 7, 19);

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadFixtures();
  }

  void _loadFixtures() {
    setState(() {
      _fixturesFuture = _useCase(_selectedDate);
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(_tournamentStart)
          ? _tournamentStart
          : (_selectedDate.isAfter(_tournamentEnd)
                ? _tournamentEnd
                : _selectedDate),
      firstDate: _tournamentStart,
      lastDate: _tournamentEnd,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFC300),
            onPrimary: Colors.black,
            surface: Color(0xFF1A2F4A),
          ),
        ),
        child: child!,
      ),
    );

    // HU-02 escenario 4: si cierra sin confirmar, no cambiar nada
    if (picked == null) return;

    _selectedDate = picked;
    _loadFixtures();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, d MMM yyyy', 'es').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚽ Mundial 2026',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Seleccionar fecha',
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de fecha seleccionada
          Container(
            width: double.infinity,
            color: const Color(0xFF0A3D62),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(
              dateLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFC300),
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 1.1,
              ),
            ),
          ),

          // Lista de partidos
          Expanded(
            child: FutureBuilder<List<FixtureEntity>>(
              future: _fixturesFuture,
              builder: (context, snapshot) {
                // HU-01 escenario 4: cargando
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // HU-01 escenario 3: error de API
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Error al cargar partidos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF8FA8C0),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final fixtures = snapshot.data ?? [];

                // HU-01 escenario 2: no hay partidos
                if (fixtures.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay partidos del Mundial\nen esta fecha',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 16),
                    ),
                  );
                }

                // HU-01 escenario 1: mostrar lista
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: fixtures.length,
                  itemBuilder: (ctx, i) => FixtureCard(
                    fixture: fixtures[i],
                    onTap: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) =>
                            FixtureDetailScreen(fixtureId: fixtures[i].id),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
