import '../entities/fixture_entity.dart';

abstract class FixturesRepository {
  Future<List<FixtureEntity>> getFixturesByDate(String date);
  Future<FixtureEntity> getFixtureById(int id);
}
