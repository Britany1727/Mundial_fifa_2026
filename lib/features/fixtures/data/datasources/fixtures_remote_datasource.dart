import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/fixture_model.dart';

class FixturesRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Map<String, String>? _stadiumMap;
  Map<String, int>? _pointsMap;
  DateTime? _auxLastFetch;

  Future<void> _ensureAuxData() async {
    if (_auxLastFetch != null &&
        DateTime.now().difference(_auxLastFetch!) < const Duration(minutes: 10)) {
      return;
    }

    try {
      final resStadiums = await _dio.get('/get/stadiums');
      final stadiumsData = resStadiums.data;
      final List<dynamic> stadiumsList = stadiumsData is List
          ? stadiumsData
          : (stadiumsData['stadiums'] as List<dynamic>? ?? []);
      _stadiumMap = {
        for (final s in stadiumsList)
          s['id'].toString(): s['name_en'] as String? ?? '',
      };
    } catch (_) {
      _stadiumMap ??= {};
    }

    try {
      final resTeams = await _dio.get('/get/teams');
      final teamsData = resTeams.data;
      final List<dynamic> teamsList = teamsData is List
          ? teamsData
          : (teamsData['teams'] as List<dynamic>? ?? []);
      final Map<String, String> teamIdToName = {
        for (final t in teamsList) t['id'].toString(): t['name_en'] as String? ?? '',
      };

      try {
        final resGroups = await _dio.get('/get/groups');
        final groupsData = resGroups.data;
        final List<dynamic> groupsList = groupsData is List
            ? groupsData
            : (groupsData['groups'] as List<dynamic>? ?? []);
        _pointsMap = {};
        for (final g in groupsList) {
          for (final t in (g['teams'] as List<dynamic>? ?? [])) {
            final teamId = t['team_id']?.toString();
            final name = teamId != null ? teamIdToName[teamId] : null;
            if (name != null) {
              _pointsMap![name] = int.tryParse(t['pts']?.toString() ?? '0') ?? 0;
            }
          }
        }
      } catch (_) {
        _pointsMap ??= {};
      }
    } catch (_) {
      // equipos no disponibles
    }

    _auxLastFetch = DateTime.now();
  }

  Future<List<FixtureModel>> getFixturesByDate(String date) async {
    await _ensureAuxData();

    final response = await _dio.get('/get/games');
    final data = response.data;
    final List<dynamic> all = data is List
        ? data
        : (data['games'] as List<dynamic>? ?? []);

    return all
        .map((e) => FixtureModel.fromJson(e as Map<String, dynamic>,
            stadiumMap: _stadiumMap, pointsMap: _pointsMap))
        .where((f) => f.matchDate == date)
        .toList();
  }

  Future<FixtureModel> getFixtureById(int id) async {
    await _ensureAuxData();

    final response = await _dio.get('/get/games');
    final data = response.data;
    final List<dynamic> all = data is List
        ? data
        : (data['games'] as List<dynamic>? ?? []);

    final match = all.cast<Map<String, dynamic>>().firstWhere(
          (e) => e['id'].toString() == id.toString(),
        );
    return FixtureModel.fromJson(match,
        stadiumMap: _stadiumMap, pointsMap: _pointsMap);
  }
}
