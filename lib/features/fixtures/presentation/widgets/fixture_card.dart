import 'package:flutter/material.dart';
import '../../domain/entities/fixture_entity.dart';

class FixtureCard extends StatelessWidget {
  final FixtureEntity fixture;
  final VoidCallback onTap;

  const FixtureCard({
    super.key,
    required this.fixture,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: const Color(0xFF1A2F4A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Fase del torneo
              Text(
                fixture.round,
                style: const TextStyle(
                  color: Color(0xFFFFC300),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),

              // Equipos, marcador y puntos
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          fixture.homeTeam,
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (fixture.homePoints != null)
                          Text(
                            '${fixture.homePoints} pts',
                            style: const TextStyle(
                              color: Color(0xFFFFC300),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: fixture.notStarted
                          ? const Color(0xFF0A3D62)
                          : const Color(0xFF27AE60),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      fixture.scoreDisplay,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fixture.awayTeam,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (fixture.awayPoints != null)
                          Text(
                            '${fixture.awayPoints} pts',
                            style: const TextStyle(
                              color: Color(0xFFFFC300),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Estadio o info
              if (fixture.stadium != null)
                Text(
                  '🏟️ ${fixture.stadium}',
                  style: const TextStyle(
                    color: Color(0xFF8FA8C0),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}