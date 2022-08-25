// ===== register.dart ==========================
// A registration form page, opens upon first launch of the app.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/utilities/formatters.dart';
import 'package:app/utilities/alerts.dart';
import 'package:app/widgets/password_field.dart';
import 'package:app/api/notification_hub.dart';
import 'package:app/utilities/cloud.dart';
import 'package:app/utilities/models.dart';


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
  /* final notificationRegistrationService = NotificationRegistrationService(Config.backendServiceEndpoint, Config.apiKey); */

  late FocusNode _retypePassword;
  Profile profile = Profile("", "", "");

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

  void _register() async {
    subscribeToNotifications(profile.email);
  }


  void _handleSubmitted() {
    final form = _formKey.currentState!;
    if (!form.validate()) {
      showInSnackBar(
        context,
        "Please fix the errors in red before submitting."
      );
    } else {
      form.save();
      _register();
      showInSnackBar(context, "Registration successful!");
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
      initialValue: "Reem Kishinevsky",  // TODO - remove this
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(
        filled: true,
        icon: Icon(Icons.person),
        labelText: "Name*",
      ),
      onSaved: (value) {
        profile.name = value!;
      },
      validator:  _validateName,
    );

    final fPhone = TextFormField(
      initialValue: "054 642 1200",  // TODO - remove this
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        filled: true,
        icon: Icon(Icons.phone),
        labelText: "Phone number*",
        prefixText: '+972 ',
      ),
      keyboardType: TextInputType.phone,
      onSaved: (value) {
        profile.phoneNumber = value!;
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
      initialValue: "reem.kishinevsky@gmail.com",  // TODO - remove this
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        filled: true,
        icon: Icon(Icons.email),
        labelText: "Email",
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        profile.email = value!;
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
      initialValue: "Stonewow1",  // TODO - remove this
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
    );
  }
}


