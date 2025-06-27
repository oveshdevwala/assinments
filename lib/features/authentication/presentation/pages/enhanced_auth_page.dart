import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_state.dart';
import '../blocs/auth_event.dart';
import '../widgets/pin_input_widget.dart';
import '../../../../shared/widgets/app_button.dart';

/// Enhanced authentication page with biometric and PIN options
class EnhancedAuthPage extends StatefulWidget {
  const EnhancedAuthPage({super.key});

  @override
  State<EnhancedAuthPage> createState() => _EnhancedAuthPageState();
}

class _EnhancedAuthPageState extends State<EnhancedAuthPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Initialize authentication state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const InitializeAuthEvent());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh auth state whenever we return to this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(const InitializeAuthEvent());
      }
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
    _slideController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
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

  void _authenticateWithPin(String pin) {
    context.read<AuthBloc>().add(AuthenticateWithPinEvent(pin: pin));
  }

  void _selectAuthMethod(AuthenticationMethod method) {
    context.read<AuthBloc>().add(SelectAuthMethodEvent(method: method));

    if (method == AuthenticationMethod.biometric) {
      _authenticateWithBiometrics();
    }
  }

  void _showBiometricSetup() {
    context.go('/pin-setup');
  }

  void _goToSettings() {
    context.go('/settings');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.authenticationStatus ==
              AuthenticationStatus.authenticated) {
            context.go('/home');
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state.isLoading &&
                          state.authFlowState == AuthFlowState.initial) {
                        return _buildLoadingView(theme);
                      }

                      return _buildAuthView(state, theme);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView(ThemeData theme) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initializing...'),
        ],
      ),
    );
  }

  Widget _buildAuthView(AuthState state, ThemeData theme) {
    return Column(
      children: [
        const Spacer(),

        // App title and subtitle
        _buildHeader(theme),

        const SizedBox(height: 64),

        // Main authentication content
        if (state.authFlowState == AuthFlowState.authenticatingWithPin)
          _buildPinAuthView(state, theme)
        else if (state.isPinSet)
          _buildPinEntryView(state, theme)
        else if (state.shouldShowAuthOptions)
          _buildMainAuthView(state, theme)
        else
          _buildWelcomeView(state, theme),

        const Spacer(),

        // Footer buttons
        _buildFooter(state, theme),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildWelcomeView(AuthState state, ThemeData theme) {
    return Column(
      children: [
        Icon(Icons.security, size: 80, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        Text(
          'Welcome to Secure Authentication',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Set up secure authentication to protect your app and data',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (state.canUseBiometric) ...[
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Enable Biometric Authentication',
              onPressed: _showBiometricSetup,
              isLoading: state.isLoading,
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              // Show PIN setup for PIN-only authentication
              _showPinOnlySetup();
            },
            child: const Text('Set Up PIN Only'),
          ),
        ),
      ],
    );
  }

  Widget _buildMainAuthView(AuthState state, ThemeData theme) {
    return Column(
      children: [
        // Show biometric and PIN options
        _buildAuthOptionsView(state, theme),
      ],
    );
  }

  Widget _buildAuthOptionsView(AuthState state, ThemeData theme) {
    // Show available authentication methods
    final hasAnyAuth = state.isBiometricEnabled || state.isPinSet;

    if (!hasAnyAuth) {
      // No authentication methods set up yet, show welcome view
      return _buildWelcomeView(state, theme);
    }

    return Column(
      children: [
        Text(
          'Choose Authentication Method',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Biometric option
        if (state.isBiometricEnabled && state.canUseBiometric) ...[
          _buildAuthOption(
            icon: Icons.fingerprint,
            title: 'Biometric Authentication',
            subtitle: 'Use fingerprint or face recognition',
            onTap: () => _selectAuthMethod(AuthenticationMethod.biometric),
            isLoading:
                state.isLoading &&
                state.authFlowState ==
                    AuthFlowState.authenticatingWithBiometric,
          ),
          const SizedBox(height: 16),
        ],

        // PIN option - show if PIN is set
        if (state.isPinSet) ...[
          _buildAuthOption(
            icon: Icons.pin,
            title: 'PIN Authentication',
            subtitle: 'Enter your 4-digit PIN',
            onTap: () => _selectAuthMethod(AuthenticationMethod.pin),
            isLoading: false,
          ),
        ],

        // Message when only biometric is enabled but PIN is not set
        if (state.isBiometricEnabled && !state.isPinSet) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Set up PIN for backup authentication',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'A PIN provides an alternative way to access your app',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/pin-setup'),
                  child: const Text('Set Up PIN'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAuthOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isLoading,
  }) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isLoading ? _pulseAnimation.value : 1.0,
          child: Card(
            elevation: 4,
            child: InkWell(
              onTap: isLoading ? null : onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 30,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPinEntryView(AuthState state, ThemeData theme) {
    return Column(
      children: [
        Icon(Icons.lock, size: 80, color: theme.colorScheme.primary),
        const SizedBox(height: 32),
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
        const SizedBox(height: 40),
        PinInputWidget(
          title: 'Enter Your PIN',
          subtitle: 'Use your 4-digit PIN to authenticate',
          onPinEntered: _authenticateWithPin,
          isLoading: state.isLoading,
          errorText: state.error,
        ),
        const SizedBox(height: 24),

        // Show biometric option if available
        if (state.canUseBiometric && state.isBiometricEnabled) ...[
          Text(
            'or',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _authenticateWithBiometrics,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Use Biometric'),
          ),
        ],
      ],
    );
  }

  Widget _buildPinAuthView(AuthState state, ThemeData theme) {
    return Column(
      children: [
        Icon(Icons.lock, size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 24),
        PinInputWidget(
          title: 'Enter Your PIN',
          subtitle: 'Use your 4-digit PIN to authenticate',
          onPinEntered: _authenticateWithPin,
          isLoading: state.isLoading,
          errorText: state.error,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            context.read<AuthBloc>().add(const ResetAuthFlowEvent());
          },
          child: const Text('Use Different Method'),
        ),
      ],
    );
  }

  Widget _buildFooter(AuthState state, ThemeData theme) {
    return Column(
      children: [
        if (state.error != null &&
            state.authFlowState != AuthFlowState.authenticatingWithPin) ...[
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: theme.colorScheme.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPinInputSection(AuthState state, ThemeData theme) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.lock, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Enter Your PIN',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Use your 4-digit PIN to access the app',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            PinInputWidget(
              key: const ValueKey('main_pin_login'),
              title: '',
              subtitle: '',
              onPinEntered: _authenticateWithPin,
              isLoading:
                  state.isLoading &&
                  state.authFlowState == AuthFlowState.authenticatingWithPin,
              errorText:
                  state.authFlowState == AuthFlowState.authenticatingWithPin
                  ? state.error
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showPinOnlySetup() {
    context.go('/pin-setup');
  }
}
