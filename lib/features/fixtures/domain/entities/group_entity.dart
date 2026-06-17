class GroupStanding {
  final String teamName;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDiff;
  final int points;

  const GroupStanding({
    required this.teamName,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDiff,
    required this.points,
  });
}

class GroupEntity {
  final String name;
  final List<GroupStanding> standings;

  const GroupEntity({
    required this.name,
    required this.standings,
  });
}
