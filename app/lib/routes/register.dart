// ===== register.dart ====================================
// A registration form page, opens upon first launch of the app.

import 'dart:io';

import 'package:app/routes/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/utilities/formatters.dart';
import 'package:app/widgets/alerts.dart';
import 'package:app/widgets/password_field.dart';
import 'package:app/services/cloud_service.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/models/profile_device.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';


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
  Profile profile = Profile("", "", "","");

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

  Future<bool> _register() async {
    final notificationsOK = await NotificationService.subscribe(profile.email);
    final signupOK = await CloudService.signUp(profile.name, profile.phoneNumber, profile.email, profile.password);
    return signupOK && notificationsOK;
  }


  void _registerSuccess() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeRoute(profile),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween = Tween(begin: begin, end: end);
          final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );
          return SlideTransition(
            position: tween.animate(curvedAnimation),
            child: child,
          );
        }
      )
    );
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
      initialValue: "reemkish@gmail.com",  // TODO - remove this
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
      onSaved: (value) {
        profile.password = value!;
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
      validator: _validatePassword,
    );

    return ProgressHUD( 
      child: Builder(
        builder: (context) => Form(
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
                    onPressed: () {
                      final form = _formKey.currentState!;
                      if (!form.validate()) {
                        showInSnackBar(
                          context,
                          "Please fix the errors in red before submitting."
                        );
                      } else {
                        final progress = ProgressHUD.of(context);
                        progress?.showWithText("Creating account...");
                        form.save();
                        _register().then((ok) {
                          progress?.dismiss(); 
                          if (ok) {
                            /* showInSnackBar(context, "Registration successful!"); */
                            Future.delayed(const Duration(milliseconds: 00),
                              () => _registerSuccess()
                            );
                          } else {
                            showInSnackBar(context, "Registration failed!");
                          }
                        });
                      }
                    },
                    child: const Text("Submit"),
                  ),
                ),
                halfSizedBoxSpace,
                Text(
                  "* indicates required field",
                  style: Theme.of(context).textTheme.caption,
                ),
                sizedBoxSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}


