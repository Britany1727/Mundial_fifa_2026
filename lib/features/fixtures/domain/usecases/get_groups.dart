import '../entities/group_entity.dart';
import '../repositories/fixtures_repository.dart';

class GetGroups {
  final FixturesRepository repository;
  GetGroups(this.repository);

  Future<List<GroupEntity>> call() => repository.getGroups();
}
