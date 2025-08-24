import '../repositories/app_repository.dart';

enum LaunchStatus { firstTime, loggedInStudent, loggedInTeacher, notLoggedIn }

class CheckLaunchStatusUseCase {
  final AppRepository repository;

  CheckLaunchStatusUseCase(this.repository);

  Future<LaunchStatus> execute() async {
    final isFirst = await repository.isFirstLaunch();
    if (isFirst) {
      await repository.setFirstLaunchDone();
      return LaunchStatus.firstTime;
    }

    final token = await repository.getToken();
    final type = await repository.getAccountType();

    if (token != null) {
      if (type == 'student') return LaunchStatus.loggedInStudent;
      if (type == 'teacher') return LaunchStatus.loggedInTeacher;
    }

    return LaunchStatus.notLoggedIn;
  }
}
