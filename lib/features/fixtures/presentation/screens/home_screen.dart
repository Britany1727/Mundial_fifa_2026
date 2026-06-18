import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/fixtures_repository_impl.dart';
import '../../domain/entities/fixture_entity.dart';
import '../../domain/usecases/get_fixtures_by_date.dart';
import '../theme/wc_colors.dart';
import '../widgets/fixture_card.dart';
import 'fixture_detail_screen.dart';

const double wcRadius = 16.0;


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDate;
  late Future<List<FixtureEntity>> _fixturesFuture;
  final _searchController = TextEditingController();
  String _query = '';

  final _useCase = GetFixturesByDate(FixturesRepositoryImpl());

  static final DateTime _tournamentStart = DateTime(2026, 6, 11);
  static final DateTime _tournamentEnd = DateTime(2026, 7, 19);

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadFixtures();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            primary: WcColors.teal,      // antes: 0xFFFFC300
            onPrimary: WcColors.navyDark, // texto oscuro sobre el acento, igual que en el HTML
            surface: WcColors.navy,      // antes: 0xFF1A2F4A
          ),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;

    _selectedDate = picked;
    _loadFixtures();
  }

  List<FixtureEntity> _filter(List<FixtureEntity> fixtures) {
    if (_query.isEmpty) return fixtures;
    final q = _query.toLowerCase();
    return fixtures.where((f) =>
      f.homeTeam.toLowerCase().contains(q) ||
      f.awayTeam.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, d MMM yyyy', 'es').format(_selectedDate);

    return Scaffold(
      backgroundColor: WcColors.navyDark, // antes: color por defecto del Theme
      appBar: AppBar(
        backgroundColor: WcColors.navy,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset('assets/images/mascotas.png', width: 30, height: 30, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            const Text.rich(
              TextSpan(
                text: 'Mundial ',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: '2026',
                    style: TextStyle(
                      color: WcColors.gold,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: WcColors.teal), // antes: color por defecto
            tooltip: 'Seleccionar fecha',
            onPressed: _pickDate,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: WcColors.navy, // antes: 0xFF0A3D62
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Text(
              dateLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: WcColors.yellow, // antes: 0xFFFFC300
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar equipo...',
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
            child: FutureBuilder<List<FixtureEntity>>(
              future: _fixturesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: WcColors.teal), // antes: sin color explícito
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.wifi_off,
                            color: WcColors.live, // antes: Colors.redAccent
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Error al cargar partidos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900, // antes: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            textAlign: TextAlign.center,
              style: const TextStyle(
                color: WcColors.textSecondary, // antes: Colors.white.withOpacity(0.6)
                fontSize: 13,
              ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final fixtures = _filter(snapshot.data ?? []);

                if (fixtures.isEmpty) {
                  return Center(
                    child: Text(
                      'No hay partidos del Mundial\nen esta fecha',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                    ),
                  );
                }

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