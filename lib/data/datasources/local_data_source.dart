import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

class LocalDataSource {
  final FlutterSecureStorage secureStorage;
  final Box box;

  LocalDataSource(this.secureStorage, this.box);

  Future<bool> isFirstLaunch() async =>
      box.get('first_launch', defaultValue: true);
  Future<void> setFirstLaunchDone() async => box.put('first_launch', false);

  Future<String?> getToken() => secureStorage.read(key: 'token');
  Future<String?> getAccountType() => secureStorage.read(key: 'accountType');
}
