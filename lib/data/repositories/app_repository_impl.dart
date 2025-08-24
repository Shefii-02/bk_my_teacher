import '../../domain/repositories/app_repository.dart';
import '../datasources/local_data_source.dart';

class AppRepositoryImpl implements AppRepository {
  final LocalDataSource localDataSource;

  AppRepositoryImpl(this.localDataSource);

  @override
  Future<bool> isFirstLaunch() => localDataSource.isFirstLaunch();

  @override
  Future<void> setFirstLaunchDone() => localDataSource.setFirstLaunchDone();

  @override
  Future<String?> getToken() => localDataSource.getToken();

  @override
  Future<String?> getAccountType() => localDataSource.getAccountType();
}
