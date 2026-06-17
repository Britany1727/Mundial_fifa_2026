import '../entities/fixture_entity.dart';
import '../repositories/fixtures_repository.dart';

class GetFixtureDetail {
  final FixturesRepository repository;

  GetFixtureDetail(this.repository);

  Future<FixtureEntity> call(int id) => repository.getFixtureById(id);
}