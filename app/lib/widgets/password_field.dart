// ===== password_field.dart ==============================
// A password field widget for use in registration/login forms.

import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    Key? key,
    this.fieldKey,
    this.hintText,
    this.labelText,
    this.helperText,
    this.onSaved,
    this.validator,
    this.onFieldSubmitted,
    this.focusNode,
    this.textInputAction,
    this.maxLength = 16,
    this.icon
  }) : super(key: key);

  final Key? fieldKey;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final Icon? icon;
  final int? maxLength;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: "Stonewow1",  // TODO - remove this
      key: widget.fieldKey,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      maxLength: widget.maxLength,
      onSaved: widget.onSaved,
      validator: widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(
        filled: true,
        hintText: widget.hintText,
        labelText: widget.labelText,
        helperText: widget.helperText,
        icon: widget.icon,
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
          hoverColor: Colors.transparent,
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            semanticLabel: "TEST",
          ),
        ),
      ),
    );
  }
}
