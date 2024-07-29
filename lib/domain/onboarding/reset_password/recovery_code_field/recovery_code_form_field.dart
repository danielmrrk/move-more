import 'package:flutter/widgets.dart';
import 'package:movemore/domain/onboarding/reset_password/recovery_code_field/recovery_code_field.dart';

export 'package:flutter/services.dart' show SmartDashesType, SmartQuotesType;

class RecoveryCodeFormField extends FormField<String> {
  RecoveryCodeFormField({
    super.key,
    this.controller,
    FocusNode? focusNode,
    super.onSaved,
    super.validator,
    bool autofocus = false,
  }) : super(
          builder: (FormFieldState<String> field) {
            void onChangedHandler(String value) {
              field.didChange(value);
            }

            return UnmanagedRestorationScope(
              bucket: field.bucket,
              child: RecoveryCodeField(
                autofocus: autofocus,
                onChanged: onChangedHandler,
              ),
            );
          },
        );

  final TextEditingController? controller;

  @override
  FormFieldState<String> createState() => _RecoveryCodeFormFieldState();
}

class _RecoveryCodeFormFieldState extends FormFieldState<String> {
  RestorableTextEditingController? _controller;

  TextEditingController get _effectiveController => _recoveryCodeFormField.controller ?? _controller!.value;

  RecoveryCodeFormField get _recoveryCodeFormField => super.widget as RecoveryCodeFormField;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    super.restoreState(oldBucket, initialRestore);
    if (_controller != null) {
      _registerController();
    }
    setValue(_effectiveController.text);
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null ? RestorableTextEditingController() : RestorableTextEditingController.fromValue(value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  void initState() {
    super.initState();
    if (_recoveryCodeFormField.controller == null) {
      _createLocalController(widget.initialValue != null ? TextEditingValue(text: widget.initialValue!) : null);
    } else {
      _recoveryCodeFormField.controller!.addListener(_handleControllerChanged);
    }
  }

  @override
  void didUpdateWidget(RecoveryCodeFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_recoveryCodeFormField.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _recoveryCodeFormField.controller?.addListener(_handleControllerChanged);

      if (oldWidget.controller != null && _recoveryCodeFormField.controller == null) {
        _createLocalController(oldWidget.controller!.value);
      }

      if (_recoveryCodeFormField.controller != null) {
        setValue(_recoveryCodeFormField.controller!.text);
        if (oldWidget.controller == null) {
          unregisterFromRestoration(_controller!);
          _controller!.dispose();
          _controller = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _recoveryCodeFormField.controller?.removeListener(_handleControllerChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);

    if (_effectiveController.text != value) {
      _effectiveController.text = value ?? '';
    }
  }

  @override
  void reset() {
    _effectiveController.text = widget.initialValue ?? '';
    super.reset();
  }

  void _handleControllerChanged() {
    if (_effectiveController.text != value) {
      didChange(_effectiveController.text);
    }
  }
}
