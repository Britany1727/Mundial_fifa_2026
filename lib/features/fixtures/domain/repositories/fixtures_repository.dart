import '../entities/fixture_entity.dart';
import '../entities/group_entity.dart';
import '../entities/stadium_entity.dart';

abstract class FixturesRepository {
  Future<List<FixtureEntity>> getFixturesByDate(String date);
  Future<FixtureEntity> getFixtureById(int id);
  Future<List<StadiumEntity>> getStadiums();
  Future<List<GroupEntity>> getGroups();
}
