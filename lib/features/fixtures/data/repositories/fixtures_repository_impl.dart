import '../../domain/entities/fixture_entity.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/stadium_entity.dart';
import '../../domain/repositories/fixtures_repository.dart';
import '../datasources/fixtures_remote_datasource.dart';

class FixturesRepositoryImpl implements FixturesRepository {
  final FixturesRemoteDatasource _datasource;

  FixturesRepositoryImpl({FixturesRemoteDatasource? datasource})
      : _datasource = datasource ?? FixturesRemoteDatasource();

  @override
  Future<List<FixtureEntity>> getFixturesByDate(String date) =>
      _datasource.getFixturesByDate(date);

  @override
  Future<FixtureEntity> getFixtureById(int id) =>
      _datasource.getFixtureById(id);

  @override
  Future<List<StadiumEntity>> getStadiums() => _datasource.getStadiums();

  @override
  Future<List<GroupEntity>> getGroups() => _datasource.getGroups();
}
