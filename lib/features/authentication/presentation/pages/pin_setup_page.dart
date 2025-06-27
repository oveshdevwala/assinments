import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/auth_event.dart';
import '../widgets/pin_input_widget.dart';
import '../../../../shared/widgets/app_button.dart';

/// Page for setting up PIN and enabling biometric authentication
class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  String? _enteredPin;
  String? _confirmedPin;
  bool _isPinConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Setup'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/settings'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }

          // Navigate back to settings after successful setup
          if (state.isBiometricEnabled && !state.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Biometric authentication setup complete!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                context.go('/settings');
              }
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // Progress indicator
                  _buildProgressIndicator(theme),

                  const SizedBox(height: 40),

                  // Main content based on current step
                  if (!_isPinConfirmed) ...[
                    _buildPinSetupStep(context, state, theme),
                  ] else ...[
                    _buildBiometricEnableStep(context, state, theme),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Step 1: PIN Setup
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.primary,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 16),
        ),

        // Connector
        Container(
          width: 50,
          height: 2,
          color: _isPinConfirmed
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),

        // Step 2: Biometric Setup
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isPinConfirmed
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          child: Icon(
            Icons.fingerprint,
            color: _isPinConfirmed ? Colors.white : theme.colorScheme.onSurface,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildPinSetupStep(
    BuildContext context,
    AuthState state,
    ThemeData theme,
  ) {
    final isSettingPin = _enteredPin == null;

    return Column(
      children: [
        // Header
        Icon(Icons.lock_outline, size: 80, color: theme.colorScheme.primary),

        const SizedBox(height: 24),

        Text(
          isSettingPin ? 'Create Your PIN' : 'Confirm Your PIN',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          isSettingPin
              ? 'Enter a 4-digit PIN to secure your app'
              : 'Re-enter your PIN to confirm',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // PIN Input - with unique key to force rebuild when switching steps
        PinInputWidget(
          key: ValueKey(isSettingPin ? 'enter_pin' : 'confirm_pin'),
          title: isSettingPin ? 'Enter PIN' : 'Confirm PIN',
          subtitle: isSettingPin
              ? 'Choose a memorable 4-digit PIN'
              : 'Enter the same PIN again',
          onPinEntered: (pin) {
            if (isSettingPin) {
              setState(() {
                _enteredPin = pin;
              });
            } else {
              setState(() {
                _confirmedPin = pin;
              });
              _validateAndSetPin(context, pin);
            }
          },
          isLoading: state.isLoading,
          errorText: state.error,
        ),

        const SizedBox(height: 30),

        // Continue button for entered PIN step - only show after PIN is entered
        if (isSettingPin && _enteredPin != null) ...[
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Continue',
              onPressed: () {
                // Move to confirmation step
                setState(() {
                  // This will trigger rebuild with new key for confirmation step
                });
              },
              isLoading: false,
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Back button for confirm step
        if (!isSettingPin)
          TextButton(
            onPressed: () {
              setState(() {
                _enteredPin = null;
                _confirmedPin = null;
              });
            },
            child: const Text('Back to Enter PIN'),
          ),
      ],
    );
  }

  Widget _buildBiometricEnableStep(
    BuildContext context,
    AuthState state,
    ThemeData theme,
  ) {
    return Column(
      children: [
        // Success icon
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.withOpacity(0.1),
          ),
          child: const Icon(Icons.check_circle, size: 60, color: Colors.green),
        ),

        const SizedBox(height: 24),

        Text(
          'PIN Created Successfully!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          'Now enable biometric authentication for quick and secure access',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Biometric setup card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.fingerprint,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),

                const SizedBox(height: 16),

                Text(
                  'Enable Biometric Login',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  'Use your fingerprint or face ID for quick and secure access to your app.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: state.isLoading
                            ? null
                            : () => context.go('/settings'),
                        child: const Text('Skip'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Enable Biometric',
                        onPressed: state.isLoading
                            ? () {}
                            : () => _enableBiometric(context),
                        isLoading: state.isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _validateAndSetPin(BuildContext context, String confirmPin) {
    if (_enteredPin == confirmPin) {
      // PINs match, set the PIN
      context.read<AuthBloc>().add(CompletePinSetupEvent(pin: _enteredPin!));

      setState(() {
        _isPinConfirmed = true;
      });
    } else {
      // PINs don't match
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PINs do not match. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _enteredPin = null;
        _confirmedPin = null;
      });
    }
  }

  void _enableBiometric(BuildContext context) {
    context.read<AuthBloc>().add(const ToggleBiometricEvent(enable: true));
  }
}
