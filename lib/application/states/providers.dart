import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/landmark_repository.dart';
import '../../infrastructure/repositories/supabase_user_repository.dart';
import '../../infrastructure/repositories/supabase_landmark_repository.dart';
import '../../infrastructure/services/supabase_service.dart';
import '../use_cases/get_current_user_use_case.dart';
import '../use_cases/search_landmarks_nearby_use_case.dart';

// Service providers
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

// Repository providers
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  return SupabaseUserRepository(supabaseService);
});

final landmarkRepositoryProvider = Provider<LandmarkRepository>((ref) {
  final supabaseService = ref.read(supabaseServiceProvider);
  return SupabaseLandmarkRepository(supabaseService);
});

// Use case providers
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final userRepository = ref.read(userRepositoryProvider);
  return GetCurrentUserUseCase(userRepository);
});

final searchLandmarksNearbyUseCaseProvider = Provider<SearchLandmarksNearbyUseCase>((ref) {
  final landmarkRepository = ref.read(landmarkRepositoryProvider);
  return SearchLandmarksNearbyUseCase(landmarkRepository);
});