import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/auth_event.dart';
import '../../../../shared/widgets/app_button.dart';

/// Settings page for managing biometric authentication
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // Refresh auth state when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const InitializeAuthEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
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
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Biometric Authentication',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Secure your app with fingerprint or face recognition',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),

              // Biometric status card
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return _buildBiometricStatusCard(context, theme, state);
                },
              ),

              const SizedBox(height: 24),

              // Biometric toggle
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return _buildBiometricToggle(context, theme, state);
                },
              ),

              const SizedBox(height: 32),

              // Info section
              _buildInfoSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricStatusCard(
    BuildContext context,
    ThemeData theme,
    AuthState state,
  ) {
    final isAvailable = state.canUseBiometric;
    final isEnabled = state.isBiometricEnabled;
    final statusColor = isAvailable ? Colors.green : Colors.orange;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.1),
              statusColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isAvailable ? Icons.fingerprint : Icons.warning,
                    color: statusColor,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Biometric Status',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          isAvailable
                              ? 'Available on this device'
                              : 'Not available on this device',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isAvailable) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      isEnabled
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: isEnabled ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isEnabled
                          ? 'Biometric authentication is enabled'
                          : 'Biometric authentication is disabled',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricToggle(
    BuildContext context,
    ThemeData theme,
    AuthState state,
  ) {
    final isAvailable = state.canUseBiometric;
    final isEnabled = state.isBiometricEnabled;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.security, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enable Biometric Login',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Require biometric authentication when opening the app',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isEnabled,
              onChanged: (value) {
                if (value) {
                  // Navigate to PIN setup page
                  _navigateToSetup(context);
                } else {
                  // Disable biometric authentication and clear PIN
                  _showDisableDialog(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About Biometric Authentication',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          theme,
          Icons.info_outline,
          'When enabled, you\'ll need to authenticate with your fingerprint or face ID each time you open the app.',
        ),
        const SizedBox(height: 8),
        _buildInfoItem(
          theme,
          Icons.lock_outline,
          'Your biometric data is securely stored on your device and never shared.',
        ),
        const SizedBox(height: 8),
        _buildInfoItem(
          theme,
          Icons.warning_amber_outlined,
          'If biometric authentication fails, you can disable it from this settings page.',
        ),
      ],
    );
  }

  Widget _buildInfoItem(ThemeData theme, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  /// Navigate to PIN setup page
  void _navigateToSetup(BuildContext context) {
    context.go('/pin-setup');
  }

  /// Show dialog to disable biometric authentication
  Future<void> _showDisableDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Biometric Authentication'),
        content: const Text(
          'This will disable biometric authentication and remove your stored PIN. You can set it up again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear all authentication data
      context.read<AuthBloc>().add(const LogoutEvent());

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric authentication disabled'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
