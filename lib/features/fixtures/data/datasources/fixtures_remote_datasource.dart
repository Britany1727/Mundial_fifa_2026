import 'package:dio/dio.dart';
import '../../../../core/constants/team_translations.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/stadium_entity.dart';
import '../models/fixture_model.dart';

class FixturesRemoteDatasource {
  static final FixturesRemoteDatasource _instance = FixturesRemoteDatasource._();
  factory FixturesRemoteDatasource() => _instance;
  FixturesRemoteDatasource._();

  Dio? _dio;

  Future<Dio> get _dioReady async {
    _dio ??= await DioClient.getInstance();
    return _dio!;
  }

  Map<String, String>? _stadiumMap;
  Map<String, int>? _pointsMap;
  Map<String, String>? _flagMap;
  DateTime? _auxLastFetch;
  List<dynamic>? _cachedStadiums;
  List<dynamic>? _cachedTeams;
  List<dynamic>? _cachedGroups;

  Future<void> _ensureAuxData() async {
    if (_auxLastFetch != null &&
        DateTime.now().difference(_auxLastFetch!) < const Duration(minutes: 10)) {
      return;
    }

    try {
      final resStadiums = await (await _dioReady).get('/get/stadiums');
      final stadiumsData = resStadiums.data;
      _cachedStadiums = stadiumsData is List
          ? stadiumsData
          : (stadiumsData['stadiums'] as List<dynamic>? ?? []);
      _stadiumMap = {
        for (final s in _cachedStadiums!)
          s['id'].toString(): s['name_en'] as String? ?? '',
      };
    } catch (_) {
      _cachedStadiums ??= [];
      _stadiumMap ??= {};
    }

    try {
      final resTeams = await (await _dioReady).get('/get/teams');
      final teamsData = resTeams.data;
      _cachedTeams = teamsData is List
          ? teamsData
          : (teamsData['teams'] as List<dynamic>? ?? []);
      final Map<String, String> teamIdToName = {
        for (final t in _cachedTeams!) t['id'].toString(): t['name_en'] as String? ?? '',
      };
      _flagMap = {
        for (final t in _cachedTeams!) t['id'].toString(): (t['flag'] as String? ?? ''),
      };

      try {
        final resGroups = await (await _dioReady).get('/get/groups');
        final groupsData = resGroups.data;
        _cachedGroups = groupsData is List
            ? groupsData
            : (groupsData['groups'] as List<dynamic>? ?? []);
        _pointsMap = {};
        for (final g in _cachedGroups!) {
          for (final t in (g['teams'] as List<dynamic>? ?? [])) {
            final teamId = t['team_id']?.toString();
            final name = teamId != null ? teamIdToName[teamId] : null;
            if (name != null) {
              _pointsMap![name] = int.tryParse(t['pts']?.toString() ?? '0') ?? 0;
            }
          }
        }
      } catch (_) {
        _cachedGroups ??= [];
        _pointsMap ??= {};
      }
    } catch (_) {
      _cachedTeams ??= [];
    }

    _auxLastFetch = DateTime.now();
  }

  // ── Fixtures (NO dependen de _ensureAuxData) ──

  Future<List<FixtureModel>> getFixturesByDate(String date) async {
    final response = await (await _dioReady).get('/get/games');
    final data = response.data;
    final List<dynamic> all = data is List
        ? data
        : (data['games'] as List<dynamic>? ?? []);

    return all
        .map((e) => FixtureModel.fromJson(e as Map<String, dynamic>,
            stadiumMap: _stadiumMap, pointsMap: _pointsMap, flagMap: _flagMap))
        .where((f) => f.matchDate == date)
        .toList();
  }

  Future<FixtureModel> getFixtureById(int id) async {
    final response = await (await _dioReady).get('/get/games');
    final data = response.data;
    final List<dynamic> all = data is List
        ? data
        : (data['games'] as List<dynamic>? ?? []);

    final match = all.cast<Map<String, dynamic>>().firstWhere(
          (e) => e['id'].toString() == id.toString(),
        );
    return FixtureModel.fromJson(match,
        stadiumMap: _stadiumMap, pointsMap: _pointsMap, flagMap: _flagMap);
  }

  // ── Stadiums ──

  Future<List<StadiumEntity>> getStadiums() async {
    await _ensureAuxData();

    return (_cachedStadiums ?? []).map((s) {
      return StadiumEntity(
        id: s['id'].toString(),
        name: s['name_en'] as String? ?? '',
        city: s['city'] as String? ?? '',
        country: s['country'] as String? ?? '',
        capacity: int.tryParse(s['capacity']?.toString() ?? '0') ?? 0,
      );
    }).toList();
  }

  // ── Groups ──

  Future<List<GroupEntity>> getGroups() async {
    await _ensureAuxData();

    final Map<String, String> teamIdToName = {
      for (final t in (_cachedTeams ?? [])) t['id'].toString(): t['name_en'] as String? ?? '',
    };
    final Map<String, String> teamIdToFlag = {
      for (final t in (_cachedTeams ?? [])) t['id'].toString(): (t['flag'] as String? ?? ''),
    };

    return (_cachedGroups ?? []).map((g) {
      final teams = (g['teams'] as List<dynamic>? ?? []).map((t) {
        final teamId = t['team_id']?.toString() ?? '';
        return GroupStanding(
          teamName: teamNameEs(teamIdToName[teamId] ?? ''),
          flag: teamIdToFlag[teamId],
          played: int.tryParse(t['mp']?.toString() ?? '0') ?? 0,
          won: int.tryParse(t['w']?.toString() ?? '0') ?? 0,
          drawn: int.tryParse(t['d']?.toString() ?? '0') ?? 0,
          lost: int.tryParse(t['l']?.toString() ?? '0') ?? 0,
          goalsFor: int.tryParse(t['gf']?.toString() ?? '0') ?? 0,
          goalsAgainst: int.tryParse(t['ga']?.toString() ?? '0') ?? 0,
          goalDiff: int.tryParse(t['gd']?.toString() ?? '0') ?? 0,
          points: int.tryParse(t['pts']?.toString() ?? '0') ?? 0,
        );
      }).toList();
      teams.sort((a, b) => b.points.compareTo(a.points));

      return GroupEntity(
        name: 'Grupo ${g['name'] ?? ''}',
        standings: teams,
      );
    }).toList();
  }
}
