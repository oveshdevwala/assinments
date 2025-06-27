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
      create: (context) => sl.sl<AuthBloc>()..add(const CheckAuthStatusEvent()),
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

/// Authentication splash screen that handles initial routing
class AuthSplashScreen extends StatelessWidget {
  const AuthSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security,
                    size: 80,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'SecureAuth',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.isLoading ? 'Initializing...' : 'Secure Your Data',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (state.isLoading)
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  if (state.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        state.error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Application router configuration
final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash/Auth check route
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const AuthSplashScreen(),
    ),
    // Authentication routes
    GoRoute(
      path: '/biometric-auth',
      name: 'biometric-auth',
      builder: (context, state) => const BiometricAuthPage(),
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
    // Protected routes - now without AuthGuard to prevent double authentication
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
  // Redirect logic for route protection
  redirect: (context, state) {
    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;

    final isOnSplash = state.matchedLocation == '/splash';
    final isOnAuthRoutes = [
      '/biometric-auth',
      '/pin-setup',
      '/auth-error',
    ].contains(state.matchedLocation);
    final isOnProtectedRoutes = [
      '/home',
      '/settings',
    ].contains(state.matchedLocation);

    // If we're still initializing, stay on splash
    if (authState.authenticationStatus == AuthenticationStatus.unknown ||
        authState.isLoading) {
      return isOnSplash ? null : '/splash';
    }

    // If user is authenticated and on auth/splash routes, redirect to home
    if (authState.isAuthenticated && (isOnAuthRoutes || isOnSplash)) {
      return '/home';
    }

    // If user requires initial setup and not on pin-setup
    if (authState.requiresInitialSetup &&
        state.matchedLocation != '/pin-setup') {
      return '/pin-setup';
    }

    // If user requires authentication and not on auth routes
    if (authState.requiresAuthentication && !isOnAuthRoutes && !isOnSplash) {
      return '/biometric-auth';
    }

    // If user is not authenticated and trying to access protected routes
    if (!authState.isAuthenticated && isOnProtectedRoutes) {
      return '/splash';
    }

    return null; // No redirect needed
  },
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
            onPressed: () => context.go('/splash'),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    ),
  ),
);
