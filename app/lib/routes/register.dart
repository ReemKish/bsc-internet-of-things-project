// ===== register.dart ==========================
// A registration form page, opens upon first launch of the app.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iot/utilities/formatters.dart';
import 'package:iot/widgets/password_field.dart';


class RegisterRoute extends StatelessWidget {
  const RegisterRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: const RegisterForm(),
    );
  }
}


class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {

  late FocusNode _retypePassword;

  @override
  void initState() {
    super.initState();
    _retypePassword = FocusNode();
  }

  @override
  void dispose() {
    _retypePassword.dispose();
    super.dispose();
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  void _handleSubmitted() {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      showInSnackBar(
        "Please fix the errors in red before submitting."
      );
    } else {
      form.save();
      showInSnackBar("Registration successful!");
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Name is required.";
    }
    final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value)) {
      return "Please enter only alphabetical characters";
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    final phoneExp = RegExp(r'^\d\d\d\ \d\d\d\ \d\d\d\d$');
    if (!phoneExp.hasMatch(value!)) {
      return "Must be a valid IL phone number.";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final passwordField = _passwordFieldKey.currentState!;
    if (passwordField.value == null || passwordField.value!.isEmpty) {
      return "Please enter a password.";
    }
    if (passwordField.value != value) {
      return "The passwords don't match.";
    }
    return null;
  }

  final IlNumberTextInputFormatter _phoneNumberFormatter =
    IlNumberTextInputFormatter();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _passwordFieldKey =
      GlobalKey<FormFieldState<String>>();

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);
    const halfSizedBoxSpace = SizedBox(height: 12);

    final fName = TextFormField(
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        filled: true,
        icon: Icon(Icons.person),
        labelText: "Name*",
      ),
      onSaved: (value) {
        /* TODO  */
      },
      validator:  _validateName,
    );

    final fPhone = TextFormField(
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        filled: true,
        icon: Icon(Icons.phone),
        labelText: "Phone number*",
        prefixText: '+972 ',
      ),
      keyboardType: TextInputType.phone,
      onSaved: (value) {
        /* TODO  */
      },
      maxLength: 12,
      maxLengthEnforcement: MaxLengthEnforcement.none,
      validator: _validatePhoneNumber,
      // TextInputFormatters are applied in sequence.
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        // Fit the validating format.
        _phoneNumberFormatter,
      ],
    );

    final fEmail = TextFormField(
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        filled: true,
        icon: Icon(Icons.email),
        labelText: "Email",
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        /* TODO */
      },
    );

    final fPassword = PasswordField(
      textInputAction: TextInputAction.next,
      fieldKey: _passwordFieldKey,
      helperText: "No more than 16 characters.",
      labelText: "Password*",
      onFieldSubmitted: (value) {
        setState(() {
          /* person.password = value; */
          _retypePassword.requestFocus();
        });
      },
    );

    final fRetypePassword = TextFormField(
      focusNode: _retypePassword,
      decoration: const InputDecoration(
        filled: true,
        labelText: "Re-type password*",
      ),
      maxLength: 16,
      obscureText: true,
      onFieldSubmitted: (value) {
        _handleSubmitted();
      },
      validator: _validatePassword,
    );

    return Form(
      key: _formKey,
      child: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              sizedBoxSpace,
              fName,            // Name field
              sizedBoxSpace,
              fPhone,           // Phone number field
              sizedBoxSpace,
              fEmail,           // Email address field
              sizedBoxSpace,
              fPassword,        // Password field
              sizedBoxSpace,
              fRetypePassword,  // Re-type password field
              sizedBoxSpace,
              Center(
                child: ElevatedButton(
                  onPressed: _handleSubmitted,
                  child: const Text("Submit"),
                ),
              ),
              halfSizedBoxSpace,
              Text(
                /* localizations.demoTextFieldRequiredField, */
                "* indicates required field",
                style: Theme.of(context).textTheme.caption,
              ),
              sizedBoxSpace,
            ],
          ),
        ),
      ),   
    );
  }
}


