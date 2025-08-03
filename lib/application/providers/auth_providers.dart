import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/authentication_controller.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../../domain/entities/user.dart' as domain;
import '../../infrastructure/repositories/supabase_authentication_repository.dart';
import '../../infrastructure/services/supabase_service.dart';

final authenticationRepositoryProvider = Provider<AuthenticationRepository>((ref) {
  final supabaseClient = SupabaseService.instance.client;
  return SupabaseAuthenticationRepository(supabaseClient);
});

final authenticationControllerProvider = 
    StateNotifierProvider<AuthenticationController, AsyncValue<domain.User?>>((ref) {
  final repository = ref.watch(authenticationRepositoryProvider);
  return AuthenticationController(repository);
});

final currentUserProvider = Provider<domain.User?>((ref) {
  final authState = ref.watch(authenticationControllerProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});