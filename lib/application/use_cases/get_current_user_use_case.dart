import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class GetCurrentUserUseCase {
  final UserRepository _userRepository;

  GetCurrentUserUseCase(this._userRepository);

  Future<User?> call() async {
    return await _userRepository.getCurrentUser();
  }
}