import 'package:flutter/material.dart';
import '../../data/repositories/fixtures_repository_impl.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/usecases/get_groups.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  late Future<List<GroupEntity>> _groupsFuture;
  final _useCase = GetGroups(FixturesRepositoryImpl());

  @override
  void initState() {
    super.initState();
    _groupsFuture = _useCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clasificación por Grupos',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<GroupEntity>>(
        future: _groupsFuture,
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
                    const Text('Error al cargar grupos',
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
          final groups = snapshot.data ?? [];
          if (groups.isEmpty) {
            return const Center(
              child: Text('No hay grupos disponibles',
                  style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 16)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (ctx, i) => _GroupCard(group: groups[i]),
          );
        },
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final GroupEntity group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A2F4A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(group.name,
                style: const TextStyle(
                    color: Color(0xFFFFC300),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: const [
                SizedBox(width: 24),
                SizedBox(width: 6),
                Expanded(child: Text('Equipo',
                    style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 11, fontWeight: FontWeight.w600))),
                SizedBox(width: 20, child: Text('PJ', textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 11, fontWeight: FontWeight.w600))),
                SizedBox(width: 20, child: Text('G', textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 11, fontWeight: FontWeight.w600))),
                SizedBox(width: 20, child: Text('E', textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 11, fontWeight: FontWeight.w600))),
                SizedBox(width: 20, child: Text('P', textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 11, fontWeight: FontWeight.w600))),
                SizedBox(width: 20, child: Text('GF', textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 11, fontWeight: FontWeight.w600))),
                SizedBox(width: 20, child: Text('GC', textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 11, fontWeight: FontWeight.w600))),
                SizedBox(width: 20, child: Text('DG', textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 11, fontWeight: FontWeight.w600))),
                SizedBox(width: 24, child: Text('Pts', textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8FA8C0), fontSize: 11, fontWeight: FontWeight.w600))),
              ],
            ),
            const SizedBox(height: 8),
            ...group.standings.map((s) => _StandingRow(standing: s)),
          ],
        ),
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final GroupStanding standing;
  const _StandingRow({required this.standing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 16,
            child: standing.flag != null && standing.flag!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.network(standing.flag!,
                        width: 24, height: 16, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.flag, color: Colors.white38, size: 16)),
                  )
                : const Icon(Icons.flag, color: Colors.white38, size: 16),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(standing.teamName,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 20, child: Text('${standing.played}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12))),
          SizedBox(width: 20, child: Text('${standing.won}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12))),
          SizedBox(width: 20, child: Text('${standing.drawn}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12))),
          SizedBox(width: 20, child: Text('${standing.lost}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12))),
          SizedBox(width: 20, child: Text('${standing.goalsFor}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12))),
          SizedBox(width: 20, child: Text('${standing.goalsAgainst}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 12))),
          SizedBox(width: 20, child: Text('${standing.goalDiff}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: standing.goalDiff >= 0 ? const Color(0xFF27AE60) : Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600))),
          SizedBox(width: 24, child: Text('${standing.points}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFFFFC300), fontSize: 14, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
