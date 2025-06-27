import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget for entering a 4-digit PIN
class PinInputWidget extends StatefulWidget {
  final Function(String) onPinEntered;
  final Function(String)? onPinChanged;
  final bool isLoading;
  final String? errorText;
  final String title;
  final String subtitle;
  final bool autofocus;

  const PinInputWidget({
    super.key,
    required this.onPinEntered,
    this.onPinChanged,
    this.isLoading = false,
    this.errorText,
    this.title = 'Enter PIN',
    this.subtitle = 'Enter your 4-digit PIN',
    this.autofocus = true,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget>
    with TickerProviderStateMixin {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeControllers();
  }

  void _setupAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 24).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _initializeControllers() {
    for (int i = 0; i < 4; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    // Add listeners to handle automatic focus progression
    for (int i = 0; i < 4; i++) {
      _controllers[i].addListener(() {
        final text = _controllers[i].text;
        if (text.isNotEmpty) {
          if (i < 3) {
            _focusNodes[i + 1].requestFocus();
          } else {
            // All digits entered
            final pin = _controllers.map((c) => c.text).join();
            widget.onPinEntered(pin);
          }
        }

        // Notify parent of changes
        final currentPin = _controllers.map((c) => c.text).join();
        widget.onPinChanged?.call(currentPin);
      });
    }

    // Auto-focus the first field
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _clearPin() {
    for (final controller in _controllers) {
      controller.clear();
    }
    if (_focusNodes.isNotEmpty && _focusNodes[0].canRequestFocus) {
      _focusNodes[0].requestFocus();
    }
  }

  /// Public method to clear the PIN from outside
  void clearPin() {
    _clearPin();
  }

  void _shakeAndClear() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
      _clearPin();
    });
  }

  @override
  void didUpdateWidget(PinInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Shake and clear on error
    if (widget.errorText != null && oldWidget.errorText != widget.errorText) {
      _shakeAndClear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          widget.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          widget.subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        // PIN input boxes
        AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildPinBox(index, theme),
                  );
                }),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Error text
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: widget.errorText != null
              ? Container(
                  key: ValueKey(widget.errorText),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox(height: 16),
        ),

        const SizedBox(height: 24),

        // Loading indicator
        if (widget.isLoading)
          const CircularProgressIndicator()
        else
          const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPinBox(int index, ThemeData theme) {
    final isError = widget.errorText != null;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(
          color: isError
              ? theme.colorScheme.error
              : _focusNodes[index].hasFocus
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: _focusNodes[index].hasFocus
            ? theme.colorScheme.primary.withOpacity(0.05)
            : theme.colorScheme.surface,
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        enabled: !widget.isLoading,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 1,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.isEmpty && index > 0) {
            // Move to previous field on backspace
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }
}
