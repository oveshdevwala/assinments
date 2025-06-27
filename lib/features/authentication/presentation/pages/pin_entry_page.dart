import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/auth_event.dart';
import '../widgets/pin_input_widget.dart';

/// Page for entering PIN to authenticate (not for setup)
class PinEntryPage extends StatefulWidget {
  const PinEntryPage({super.key});

  @override
  State<PinEntryPage> createState() => _PinEntryPageState();
}

class _PinEntryPageState extends State<PinEntryPage>
    with TickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _authenticateWithPin(String pin) {
    context.read<AuthBloc>().add(AuthenticateWithPinEvent(pin: pin));
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

  void _shakeOnError() {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // Only handle UI feedback, let GoRouter handle navigation
          if (state.error != null && state.error!.contains('Wrong PIN')) {
            _shakeOnError();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.background,
                theme.colorScheme.secondary.withOpacity(0.05),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // App title
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

                        // Lock icon
                        AnimatedBuilder(
                          animation: _shakeAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_shakeAnimation.value, 0),
                              child: Icon(
                                Icons.lock,
                                size: 80,
                                color: theme.colorScheme.primary,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // Welcome message
                        Text(
                          'Welcome Back!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your PIN to continue',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),

                        if (state.canUseBiometric &&
                            state.isBiometricEnabled) ...[
                          Text(
                            'or',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : _authenticateWithBiometrics,
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Use Biometric'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        // PIN Input
                        PinInputWidget(
                          title: '',
                          subtitle: '',
                          onPinEntered: _authenticateWithPin,
                          isLoading: state.isLoading,
                          errorText: state.error,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
