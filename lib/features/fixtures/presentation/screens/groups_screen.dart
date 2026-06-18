import 'package:flutter/material.dart';
import '../../data/repositories/fixtures_repository_impl.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/usecases/get_groups.dart';
import '../theme/wc_colors.dart';

const double wcRadius = 16.0;

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  late Future<List<GroupEntity>> _groupsFuture;
  final _searchController = TextEditingController();
  String _query = '';
  final _useCase = GetGroups(FixturesRepositoryImpl());

  @override
  void initState() {
    super.initState();
    _groupsFuture = _useCase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<GroupEntity> _filter(List<GroupEntity> groups) {
    if (_query.isEmpty) return groups;
    final q = _query.toLowerCase();
    return groups.where((g) =>
      g.standings.any((s) => s.teamName.toLowerCase().contains(q))
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WcColors.navyDark, // consistente con home_screen.dart
      appBar: AppBar(
        backgroundColor: WcColors.navy,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('Clasificación por Grupos',
            style: TextStyle(fontWeight: FontWeight.w900)),
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
            child: FutureBuilder<List<GroupEntity>>(
              future: _groupsFuture,
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
                          const Text('Error al cargar grupos',
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
                final groups = _filter(snapshot.data ?? []);
                if (groups.isEmpty) {
                  return Center(
                    child: Text('No hay grupos disponibles',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: groups.length,
                  itemBuilder: (ctx, i) => _GroupCard(group: groups[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Diseño tomado de la "Group A Card" del HTML: header de color con el
// nombre del grupo, encabezado de columnas y filas con barra de acento
// que marca quién está clasificando (los 2 primeros de la tabla).
// Columnas simplificadas a PJ / DG / Pts, igual que el HTML (P / GD / Pts).
// ─────────────────────────────────────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  final GroupEntity group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: WcColors.navy,
        borderRadius: BorderRadius.circular(wcRadius), // antes: circular(12)
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de color, igual al "bg-primary text-on-primary" del HTML
          Container(
            width: double.infinity,
            color: WcColors.teal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              group.name.toUpperCase(),
              style: const TextStyle(
                color: WcColors.navyDark,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
          // Encabezado de columnas, igual al <thead> del HTML
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                const SizedBox(width: 4 + 8 + 28 + 8), // espacio: barra + flag + separaciones
                const Expanded(
                  child: Text('EQUIPO',
                      style: TextStyle(color: Color(0x99FFFFFF), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(
                    width: 28,
                    child: Text('PJ', textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0x99FFFFFF), fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(
                    width: 36,
                    child: Text('DG', textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0x99FFFFFF), fontSize: 11, fontWeight: FontWeight.w600))),
                const SizedBox(
                    width: 40,
                    child: Text('PTS', textAlign: TextAlign.right,
                        style: TextStyle(color: Color(0x99FFFFFF), fontSize: 11, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          ...List.generate(group.standings.length, (index) {
            return _StandingRow(
              standing: group.standings[index],
              qualifying: index < 2, // los 2 primeros -> barra/acento de color, igual al HTML
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  final GroupStanding standing;
  final bool qualifying;
  const _StandingRow({required this.standing, required this.qualifying});

  @override
  Widget build(BuildContext context) {
    // Color del nombre/puntos: clasificando -> resaltado, el resto -> atenuado.
    // Igual a "on-surface" vs "on-surface-variant" del HTML.
    final nameColor = qualifying ? Colors.white : Colors.white.withOpacity(0.6);
    final ptsColor = qualifying ? WcColors.teal : Colors.white.withOpacity(0.6);
    final accentColor = qualifying ? WcColors.teal : Colors.white.withOpacity(0.15);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: [
          // Barra de acento (w-2 h-10 rounded-full bg-primary / bg-surface-variant)
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          // Bandera (w-8 h-6 object-cover rounded-sm shadow-sm)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 3, offset: const Offset(0, 1)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: standing.flag != null && standing.flag!.isNotEmpty
                  ? Image.network(standing.flag!,
                      width: 28, height: 18, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.flag, color: Colors.white38, size: 16))
                  : Container(
                      width: 28,
                      height: 18,
                      color: WcColors.navyDark,
                      child: const Icon(Icons.flag, color: Colors.white38, size: 14),
                    ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(standing.teamName,
                style: TextStyle(color: nameColor, fontSize: 14, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
          ),
          SizedBox(
            width: 28,
            child: Text('${standing.played}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
          ),
          SizedBox(
            width: 36,
            child: Text(
              standing.goalDiff > 0 ? '+${standing.goalDiff}' : '${standing.goalDiff}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: standing.goalDiff >= 0 ? WcColors.teal : WcColors.live, // antes: 0xFF27AE60 / redAccent
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text('${standing.points}',
                textAlign: TextAlign.right,
                style: TextStyle(color: ptsColor, fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}