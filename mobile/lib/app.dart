import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/auth_screen.dart';
import 'features/comparisons/presentation/bloc/comparison_feed_bloc.dart';
import 'features/comparisons/presentation/comparison_feed_screen.dart';
import 'features/comparisons/presentation/widgets/feed_background.dart';
import 'features/polls/presentation/bloc/poll_bloc.dart';

class YouHaveToSayApp extends StatelessWidget {
  const YouHaveToSayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'app_name'.tr(),
          theme: AppTheme.app(),
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: child,
        );
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<AuthBloc>()..add(const AuthStarted()),
          ),
          BlocProvider(create: (_) => getIt<PollBloc>()),
          BlocProvider(create: (_) => getIt<ComparisonFeedBloc>()),
        ],
        child: const _RootRouter(),
      ),
    );
  }
}

class _RootRouter extends StatelessWidget {
  const _RootRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.unknown:
            return const Scaffold(
              backgroundColor: Colors.transparent,
              body: FeedBackground(
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          case AuthStatus.authenticated:
            return const ComparisonFeedScreen();
          case AuthStatus.unauthenticated:
            return const AuthScreen();
        }
      },
    );
  }
}
