import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/fixtures_repository_impl.dart';
import '../../domain/entities/fixture_entity.dart';
import '../../domain/usecases/get_fixture_detail.dart';

class FixtureDetailScreen extends StatefulWidget {
  final int fixtureId;

  const FixtureDetailScreen({super.key, required this.fixtureId});

  @override
  State<FixtureDetailScreen> createState() => _FixtureDetailScreenState();
}

class _FixtureDetailScreenState extends State<FixtureDetailScreen> {
  late Future<FixtureEntity> _fixtureFuture;
  final _useCase = GetFixtureDetail(FixturesRepositoryImpl());

  @override
  void initState() {
    super.initState();
    _fixtureFuture = _useCase(widget.fixtureId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Partido'),
        leading: const BackButton(), // HU-03 escenario 3
      ),
      body: FutureBuilder<FixtureEntity>(
        future: _fixtureFuture,
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
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFF8FA8C0), fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          final f = snapshot.data!;
          return _DetailBody(fixture: f);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final FixtureEntity fixture;
  const _DetailBody({required this.fixture});

  @override
  Widget build(BuildContext context) {
    // Fecha/hora local (HU-03 escenario 2)
    final localDate =
        DateFormat('EEE d MMM yyyy · HH:mm', 'es').format(fixture.dateLocal);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Fase del torneo
          _ChipLabel(label: fixture.round),
          const SizedBox(height: 24),

          // Marcador principal
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  fixture.homeTeam,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: fixture.notStarted
                      ? const Color(0xFF0A3D62)
                      : const Color(0xFF27AE60),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  fixture.scoreDisplay,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900),
                ),
              ),
              Expanded(
                child: Text(
                  fixture.awayTeam,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(color: Color(0xFF2A4A6A)),
          const SizedBox(height: 20),

          // Información adicional
          _InfoRow(icon: Icons.access_time, label: 'Fecha y hora', value: localDate),

          // Estadio (si está disponible) — HU-03 escenario 2
          if (fixture.stadium != null)
            _InfoRow(
                icon: Icons.stadium,
                label: 'Estadio',
                value: fixture.stadium!),

          // Grupo (solo si aplica) — HU-03 escenario 4
          if (fixture.group != null && fixture.group!.isNotEmpty)
            _InfoRow(
                icon: Icons.group,
                label: 'Grupo',
                value: fixture.group!),

          // Puntos de cada equipo
          if (fixture.homePoints != null && fixture.awayPoints != null)
            _InfoRow(
                icon: Icons.leaderboard,
                label: 'Puntos',
                value: '${fixture.homeTeam}: ${fixture.homePoints}  ·  ${fixture.awayTeam}: ${fixture.awayPoints}'),
        ],
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String label;
  const _ChipLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A3D62),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC300), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Color(0xFFFFC300),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFFC300), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Color(0xFF8FA8C0),
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}