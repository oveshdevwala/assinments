import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/auth_event.dart';
import 'pin_entry_page.dart';
import 'enhanced_auth_page.dart';

/// Biometric authentication page shown on app startup
/// Determines whether to show PIN entry or setup based on current state
class BiometricAuthPage extends StatefulWidget {
  const BiometricAuthPage({super.key});

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage> {
  @override
  void initState() {
    super.initState();
    // Initialize authentication state when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const InitializeAuthEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        // Debug print to see what's happening
        print(
          'AUTH STATE DEBUG: isPinSet=${state.isPinSet}, isBiometricEnabled=${state.isBiometricEnabled}, isLoading=${state.isLoading}',
        );
      },
      builder: (context, state) {
        // Show loading while initializing
        if (state.isLoading && state.authFlowState == AuthFlowState.initial) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Checking authentication...'),
                ],
              ),
            ),
          );
        }

        // If PIN is already set, ALWAYS show PIN entry page
        if (state.isPinSet) {
          print('SHOWING PIN ENTRY PAGE - PIN IS SET');
          return const PinEntryPage();
        }

        // Otherwise, show the setup/welcome page
        print('SHOWING ENHANCED AUTH PAGE - NO PIN SET');
        return const EnhancedAuthPage();
      },
    );
  }
}
