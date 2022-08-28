// ===== register.dart ====================================
// A registration form page, opens upon first launch of the app.

import 'package:app/routes/home.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/alerts.dart';
import 'package:app/widgets/password_field.dart';
import 'package:app/services/cloud_service.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/routes/register.dart';
import 'package:app/models/login_data.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';


class LoginRoute extends StatelessWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: const Scaffold(
        body: LoginForm(),
      ),
    );
  }
}


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late LoginData? loginData;
  late String email;
  late String password;

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _login() async {
    loginData = await CloudService.logIn(email, password);
    if (loginData != null) {
      /* final notificationsOK = await NotificationService.subscribe(email); */
      const notificationsOK = true;
      NotificationService.resumeSubscription(email);
      if (notificationsOK) {
        return true;
      }
    }
    return false;
  }


  void _loginSuccess() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomeRoute(loginData!),
        transitionDuration: const Duration(milliseconds: 900),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
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


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);
    const halfSizedBoxSpace = SizedBox(height: 12);

    const logInLabel = Text(
      "Log in",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 40,
        /* color: Colors.orange, */
        fontWeight: FontWeight.bold,
      ),
    );

    final fEmail = TextFormField(
      /* initialValue: "@arc.com",  // - remove this */
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        filled: true,
        icon: Icon(Icons.email),
        labelText: "Email",
      ),
      keyboardType: TextInputType.emailAddress,
      onSaved: (value) {
        email = value!;
      },
    );

    final fPassword = PasswordField(
      textInputAction: TextInputAction.next,
      labelText: "Password",
      onSaved: (value) {
        password = value!;
      },
      icon: const Icon(Icons.lock),
      maxLength: null,
    );

    Widget signinButton(BuildContext ctx) => ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
      ),
      onPressed: () {
        final form = _formKey.currentState!;
        final progress = ProgressHUD.of(ctx);
        progress?.showWithText("Signing in...");
        form.save();
        _login().then((ok) {
          progress?.dismiss(); 
          if (ok) {
              _loginSuccess();
          } else {
            showInSnackBar(ctx, "Login failed: invalid email/password", seconds: 3);
          }
        });
      },
      child: const Text(
        'Sign in',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ), 
    );

    final signupMessage = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Not registered yet?'),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const RegisterRoute(),
                transitionDuration: const Duration(milliseconds: 600),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
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
          },
          child: const Text('Create an account'),
        ),
      ],
    );

    return ProgressHUD( 
      child: Builder(
        builder: (context) => Align(
          alignment: const Alignment(0,-0.5),
          child:Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  logInLabel,
                  sizedBoxSpace,
                  fEmail,           // Email address field
                  sizedBoxSpace,
                  fPassword,        // Password field
                  sizedBoxSpace,
                  signinButton(context),     // Sign in button
                  halfSizedBoxSpace,
                  signupMessage     // Not registered yet? create an account
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



