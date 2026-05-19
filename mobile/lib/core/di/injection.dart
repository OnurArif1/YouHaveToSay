import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/auth_token_storage.dart';
import '../network/firebase_token_provider.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/polls/data/polls_repository_impl.dart';
import '../../features/polls/domain/polls_repository.dart';
import '../../features/comparisons/data/comparison_repository_impl.dart';
import '../../features/comparisons/domain/comparison_repository.dart';
import '../../features/comparisons/presentation/bloc/comparison_feed_bloc.dart';
import '../../features/polls/presentation/bloc/poll_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies(AppConfig config) async {
  getIt.registerSingleton<AppConfig>(config);
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingleton<AuthTokenStorage>(
    () => AuthTokenStorage(getIt()),
  );
  getIt.registerLazySingleton<FirebaseTokenProvider>(
    () => FirebaseTokenProvider(useDevAuth: config.useDevAuth),
  );
  getIt.registerLazySingleton<Dio>(
    () => createApiClient(
      config: config,
      tokenStorage: getIt(),
      firebaseTokenProvider: getIt(),
    ),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dio: getIt(),
      tokenStorage: getIt(),
      firebaseTokenProvider: getIt(),
      config: config,
    ),
  );
  getIt.registerLazySingleton<PollsRepository>(
    () => PollsRepositoryImpl(dio: getIt()),
  );
  getIt.registerLazySingleton<ComparisonRepository>(
    () => ComparisonRepositoryImpl(dio: getIt()),
  );
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt()),
  );
  getIt.registerFactory<PollBloc>(
    () => PollBloc(pollsRepository: getIt()),
  );
  getIt.registerFactory<ComparisonFeedBloc>(
    () => ComparisonFeedBloc(comparisonRepository: getIt()),
  );
}
