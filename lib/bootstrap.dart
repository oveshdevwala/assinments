import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/config/service_locator.dart' as sl;
import 'features/home/presentation/pages/home_page.dart';
import 'features/authentication/presentation/blocs/auth_bloc.dart';
import 'features/authentication/presentation/blocs/auth_event.dart';
import 'features/authentication/presentation/blocs/auth_state.dart';
import 'features/authentication/presentation/pages/biometric_auth_page.dart';
import 'features/authentication/presentation/pages/settings_page.dart';
import 'features/authentication/presentation/pages/auth_error_page.dart';
import 'features/authentication/presentation/pages/pin_setup_page.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize dependencies
  await sl.init();

  runApp(const HelloApp());
}

class HelloApp extends StatelessWidget {
  const HelloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl.sl<AuthBloc>()..add(const InitializeAuthEvent()),
      child: MaterialApp.router(
        title: 'SecureAuth',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}

/// Route wrapper that handles authentication flow
class AuthRouteWrapper extends StatelessWidget {
  final Widget child;
  const AuthRouteWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Show biometric auth page if enabled and not authenticated
        if (state.requiresBiometricOnStartup &&
            state.authenticationStatus != AuthenticationStatus.authenticated) {
          return const BiometricAuthPage();
        }

        // Otherwise show the intended page
        return child;
      },
    );
  }
}

/// Application router configuration
final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/biometric-auth',
      name: 'biometric-auth',
      builder: (context, state) => const BiometricAuthPage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/pin-setup',
      name: 'pin-setup',
      builder: (context, state) => const PinSetupPage(),
    ),
    GoRoute(
      path: '/auth-error',
      name: 'auth-error',
      builder: (context, state) {
        final errorMessage = state.uri.queryParameters['error'];
        return AuthErrorPage(errorMessage: errorMessage);
      },
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => AuthRouteWrapper(child: const HomePage()),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Page Not Found',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'The page you are looking for does not exist.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),
);
