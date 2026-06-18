import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/fixture_entity.dart';
import '../theme/wc_colors.dart';

class FixtureCard extends StatelessWidget {
  final FixtureEntity fixture;
  final VoidCallback onTap;

  const FixtureCard({
    super.key,
    required this.fixture,
    required this.onTap,
  });

  Widget _flag3d(String? url, double size) {
    if (url == null || url.isEmpty) {
      return Container(
        width: size,
        height: size * 0.6,
        decoration: BoxDecoration(
          color: WcColors.navyDark,
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14FFFFFF),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(Icons.flag, color: WcColors.textMuted, size: size * 0.35),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1FFFFFFF),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x144FC3F7),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          url,
          width: size,
          height: size * 0.6,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: size,
            height: size * 0.6,
            color: WcColors.navyDark,
            child: Icon(Icons.flag, color: WcColors.textMuted, size: size * 0.35),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = fixture.timeBadge;
    final groupLabel = fixture.group != null && fixture.group!.isNotEmpty
        ? fixture.group!
        : fixture.round;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: WcColors.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: WcColors.divider.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: Image.asset(
                'assets/images/mascotas.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        groupLabel,
                        style: const TextStyle(
                          color: WcColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      if (badge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: fixture.status == 'LIVE'
                                ? WcColors.live
                                : WcColors.navyDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _flag3d(fixture.homeFlag, 56),
                            const SizedBox(height: 8),
                            Text(
                              fixture.homeTeam,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: WcColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (fixture.homePoints != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '${fixture.homePoints} pts',
                                  style: const TextStyle(
                                    color: WcColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        decoration: BoxDecoration(
                          color: WcColors.success,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          fixture.scoreDisplay,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _flag3d(fixture.awayFlag, 56),
                            const SizedBox(height: 8),
                            Text(
                              fixture.awayTeam,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: WcColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (fixture.awayPoints != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '${fixture.awayPoints} pts',
                                  style: const TextStyle(
                                    color: WcColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (fixture.stadium != null || fixture.notStarted)
                    Text(
                      '${fixture.stadium ?? ''}${fixture.stadium != null && fixture.notStarted ? ' · ' : ''}${fixture.notStarted ? DateFormat('HH:mm', 'es').format(fixture.dateLocal) : ''}',
                      style: const TextStyle(
                        color: WcColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
