import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/user_model.dart';
import '../services/user_repository.dart';


final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userProvider =
StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  final repo = ref.read(userRepositoryProvider);
  return UserNotifier(repo);
});

class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> loadUser({bool silent = false}) async {
    try {
      if (!silent) state = const AsyncValue.loading();
      print("-loaderUSerStarted");
      final user = await _repository.profileUserData();
      print("-loaderUSerEnded");
      state = AsyncValue.data(user);
    } catch (e, st) {

      state = AsyncValue.error(e, st);
    }
  }

  void updateUser(UserModel updatedUser) {
    state = AsyncValue.data(updatedUser);
  }
}
