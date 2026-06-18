class FixtureEntity {
  final int id;
  final String homeTeam;
  final String awayTeam;
  final int? homeGoals;
  final int? awayGoals;
  final String status;
  final String? stadium;
  final String? group;
  final String round;
  final DateTime dateUtc;
  final int? homePoints;
  final int? awayPoints;
  final String? homeFlag;
  final String? awayFlag;

  const FixtureEntity({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.homeGoals,
    this.awayGoals,
    required this.status,
    this.stadium,
    this.group,
    required this.round,
    required this.dateUtc,
    this.homePoints,
    this.awayPoints,
    this.homeFlag,
    this.awayFlag,
  });

  /// Devuelve true si el partido aún no comenzó
  bool get notStarted => status == 'NS' || status == 'TBD';

  /// Devuelve el marcador como texto, o 'vs' si no empezó
  String get scoreDisplay {
    if (notStarted) return 'vs';
    final h = homeGoals ?? 0;
    final a = awayGoals ?? 0;
    return '$h - $a';
  }

  /// Fecha/hora en zona local del dispositivo
  DateTime get dateLocal => dateUtc.toLocal();

  /// Texto descriptivo del tiempo restante o estado actual
  String get timeBadge {
    if (status == 'LIVE') return 'EN VIVO';
    if (status == 'FT' || status == 'TBD') return '';
    final diff = dateLocal.difference(DateTime.now());
    if (diff.isNegative) return '';
    if (diff.inDays > 1) return 'En ${diff.inDays}d';
    if (diff.inDays == 1) return 'Mañana';
    if (diff.inHours > 0) return 'En ${diff.inHours}h ${diff.inMinutes.remainder(60)}m';
    if (diff.inMinutes > 0) return 'En ${diff.inMinutes}m';
    return '';
  }
}