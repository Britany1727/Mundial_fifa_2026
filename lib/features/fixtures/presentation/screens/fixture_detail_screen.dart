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
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Detalle del Partido'),
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<FixtureEntity>(
        future: _fixtureFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC300)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF8FA8C0), fontSize: 13)),
                  ],
                ),
              ),
            );
          }
          return _DetailBody(fixture: snapshot.data!);
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
    final localDate = DateFormat("EEEE d 'de' MMMM yyyy · HH:mm", 'es').format(fixture.dateLocal);

    return SingleChildScrollView(
      child: Column(
        children: [
          // --- Header con gradiente + mascotas ---
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/mascotas.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomRight,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A2F4A).withValues(alpha: 0.82),
                          const Color(0xFF0A1A2A).withValues(alpha: 0.94),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                    bottom: 32,
                    left: 20,
                    right: 20,
                  ),
                  child: Column(
                    children: [
                      // Round chip + badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _chip(fixture.round),
                    if (fixture.timeBadge.isNotEmpty) ...[
                      const SizedBox(width: 10),
                      _badge(fixture.timeBadge, fixture.status == 'LIVE'),
                    ],
                  ],
                ),
                const SizedBox(height: 28),

                // Scoreboard
                Row(
                  children: [
                    // Home team
                    Expanded(
                      child: Column(
                        children: [
                          _teamFlag(fixture.homeFlag, 56, 38),
                          const SizedBox(height: 10),
                          Text(fixture.homeTeam,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              )),
                          if (fixture.homePoints != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('${fixture.homePoints} pts',
                                  style: const TextStyle(
                                    color: Color(0xFFFFC300),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                        ],
                      ),
                    ),

                    // Score
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      decoration: BoxDecoration(
                        color: fixture.notStarted
                            ? const Color(0xFF0A3D62)
                            : const Color(0xFF27AE60),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (fixture.notStarted ? const Color(0xFF0A3D62) : const Color(0xFF27AE60))
                                .withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        fixture.scoreDisplay,
                        style: TextStyle(
                          color: fixture.notStarted
                              ? const Color(0xFFFFC300)
                              : Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),

                    // Away team
                    Expanded(
                      child: Column(
                        children: [
                          _teamFlag(fixture.awayFlag, 56, 38),
                          const SizedBox(height: 10),
                          Text(fixture.awayTeam,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              )),
                          if (fixture.awayPoints != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text('${fixture.awayPoints} pts',
                                  style: const TextStyle(
                                    color: Color(0xFFFFC300),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Fecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF8FA8C0), size: 16),
                    const SizedBox(width: 6),
                    Text(localDate[0].toUpperCase() + localDate.substring(1),
                        style: const TextStyle(color: Color(0xFF8FA8C0), fontSize: 13)),
                  ],
                ),
              ],
            ),
          ),
          ],
        ),
      ),

      // --- Info cards ---
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(
              children: [
                // Estadio
                if (fixture.stadium != null)
                  _infoCard(
                    icon: Icons.stadium,
                    title: 'Estadio',
                    value: fixture.stadium!,
                  ),

                // Grupo
                if (fixture.group != null && fixture.group!.isNotEmpty)
                  _infoCard(
                    icon: Icons.emoji_events,
                    title: 'Grupo',
                    value: fixture.group!,
                  ),

                // Puntos
                if (fixture.homePoints != null && fixture.awayPoints != null)
                  _infoCard(
                    icon: Icons.trending_up,
                    title: 'Puntos',
                    value: '${fixture.homeTeam}: ${fixture.homePoints}  ·  ${fixture.awayTeam}: ${fixture.awayPoints}',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamFlag(String? url, double w, double h) {
    if (url == null || url.isEmpty) {
      return Container(
        width: w, height: h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF0A1A2A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.flag, color: Colors.white24, size: 20),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(url, width: w, height: h, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: w, height: h,
              alignment: Alignment.center,
              color: const Color(0xFF0A1A2A),
              child: const Icon(Icons.flag, color: Colors.white24, size: 20),
            )),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A3D62),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFC300), width: 1),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Color(0xFFFFC300), fontSize: 12,
              fontWeight: FontWeight.w700, letterSpacing: 1.2)),
    );
  }

  Widget _badge(String text, bool live) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: live ? Colors.redAccent : const Color(0xFF0A3D62),
        borderRadius: BorderRadius.circular(20),
        boxShadow: live
            ? [
                BoxShadow(
                  color: Colors.redAccent.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (live) ...[
            Container(
              width: 7, height: 7,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(text,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11,
                  fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String value}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2F4A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0A3D62),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFFFC300), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF8FA8C0), fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
