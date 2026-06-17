import '../entities/stadium_entity.dart';
import '../repositories/fixtures_repository.dart';

class GetStadiums {
  final FixturesRepository repository;
  GetStadiums(this.repository);

  Future<List<StadiumEntity>> call() => repository.getStadiums();
}
