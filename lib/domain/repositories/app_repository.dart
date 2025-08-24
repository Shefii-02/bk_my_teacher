abstract class AppRepository {
  Future<bool> isFirstLaunch();
  Future<void> setFirstLaunchDone();
  Future<String?> getToken();
  Future<String?> getAccountType();
}
