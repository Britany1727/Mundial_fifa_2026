import '../entities/fixture_entity.dart';
import '../repositories/fixtures_repository.dart';

class GetFixturesByDate {
  final FixturesRepository repository;

  GetFixturesByDate(this.repository);

  Future<List<FixtureEntity>> call(DateTime date) {
    final formatted =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return repository.getFixturesByDate(formatted);
  }
}