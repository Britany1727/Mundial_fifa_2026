import '../../../../core/constants/team_translations.dart';
import '../../domain/entities/fixture_entity.dart';

String _roundName(String type) {
  switch (type) {
    case 'group': return 'Group Stage';
    case 'r32': return 'Round of 32';
    case 'r16': return 'Round of 16';
    case 'qf': return 'Quarter-finals';
    case 'sf': return 'Semi-finals';
    case 'third': return 'Third Place';
    case 'final': return 'Final';
    default: return type;
  }
}

String _statusFromApi(String finished, String elapsed) {
  if (finished == 'TRUE') return 'FT';
  if (elapsed == 'notstarted') return 'NS';
  return 'LIVE';
}

DateTime _parseLocalDate(String raw) {
  try {
    final p = raw.split(' ');
    if (p.length < 2) return DateTime.now();
    final dp = p[0].split('/');
    final tp = p[1].split(':');
    return DateTime(
      int.parse(dp[2]),
      int.parse(dp[0]),
      int.parse(dp[1]),
      int.parse(tp[0]),
      int.parse(tp[1]),
    );
  } catch (_) {
    return DateTime.now();
  }
}

class FixtureModel extends FixtureEntity {
  final String matchDate;

  const FixtureModel({
    required super.id,
    required super.homeTeam,
    required super.awayTeam,
    super.homeGoals,
    super.awayGoals,
    required super.status,
    super.stadium,
    super.group,
    required super.round,
    required super.dateUtc,
    super.homePoints,
    super.awayPoints,
    required this.matchDate,
  });

  factory FixtureModel.fromJson(
    Map<String, dynamic> json, {
    Map<String, String>? stadiumMap,
    Map<String, int>? pointsMap,
  }) {
    final rawDate = (json['local_date'] ?? '').toString();
    final parsedDate = _parseLocalDate(rawDate);
    final matchDate =
        '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';

    final homeScore = json['home_score']?.toString();
    final awayScore = json['away_score']?.toString();
    final finished = (json['finished'] ?? 'FALSE').toString();
    final elapsed = (json['time_elapsed'] ?? 'notstarted').toString();

    String homeTeam = json['home_team_name_en'] as String? ?? '';
    String awayTeam = json['away_team_name_en'] as String? ?? '';
    if (homeTeam.isEmpty) {
      homeTeam = json['home_team_label'] as String? ?? 'Local';
    }
    if (awayTeam.isEmpty) {
      awayTeam = json['away_team_label'] as String? ?? 'Visitante';
    }

    final stadiumId = json['stadium_id']?.toString();
    final stadiumName =
        stadiumMap != null && stadiumId != null ? stadiumMap[stadiumId] : null;

    return FixtureModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      homeTeam: teamNameEs(homeTeam),
      awayTeam: teamNameEs(awayTeam),
      homeGoals: homeScore != null ? int.tryParse(homeScore) : null,
      awayGoals: awayScore != null ? int.tryParse(awayScore) : null,
      status: _statusFromApi(finished, elapsed),
      stadium: stadiumName ?? stadiumId,
      group: json['group']?.toString(),
      round: _roundName(json['type'] as String? ?? ''),
      dateUtc: parsedDate,
      matchDate: matchDate,
      homePoints: pointsMap?[homeTeam],
      awayPoints: pointsMap?[awayTeam],
    );
  }
}