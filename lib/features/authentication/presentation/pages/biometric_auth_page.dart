import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/auth_event.dart';
import '../../../../shared/widgets/app_button.dart';

/// Biometric authentication page shown on app startup
class BiometricAuthPage extends StatefulWidget {
  const BiometricAuthPage({super.key});

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Trigger biometric authentication immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authenticateWithBiometrics();
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _authenticateWithBiometrics() {
    context.read<AuthBloc>().add(
      const AuthenticateWithBiometricsEvent(
        reason: 'Authenticate to access the app',
        useErrorDialogs: true,
        stickyAuth: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.authenticationStatus ==
              AuthenticationStatus.authenticated) {
            // Navigate to home page after successful authentication
            context.go('/home');
          } else if (state.error != null) {
            // Navigate to error page when authentication fails
            context.go(
              '/auth-error?error=${Uri.encodeComponent(state.error!)}',
            );
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.background,
                theme.colorScheme.primary.withOpacity(0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),

                  // App logo or title
                  Text(
                    'Hello App',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Secure Access',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 64),

                  // Animated biometric icon
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: state.isLoading
                                ? _pulseAnimation.value
                                : 1.0,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: theme.colorScheme.primary.withOpacity(
                                  0.1,
                                ),
                                border: Border.all(
                                  color: theme.colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.fingerprint,
                                size: 64,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Status text
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      String statusText = 'Touch the fingerprint sensor';
                      if (state.isLoading) {
                        statusText = 'Authenticating...';
                      } else if (state.error != null) {
                        statusText = 'Authentication failed';
                      }

                      return Text(
                        statusText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: state.error != null
                              ? theme.colorScheme.error
                              : theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Use your fingerprint or face ID to unlock the app',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Action buttons
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: 'Try Again',
                              onPressed: () => _authenticateWithBiometrics(),
                              isLoading: state.isLoading,
                            ),
                          ),

                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
