// ===== bottom_bar.dart ==================================
// A bottom bar with a profile button to be included
// in most of the app's screens.

import 'package:flutter/material.dart';
import 'package:app/utilities/avatar.dart';
import 'package:app/models/profile.dart';
import 'package:app/widgets/alerts.dart';
import 'package:app/routes/login.dart';
import 'package:app/services/notification_service.dart';


class BottomBar extends StatelessWidget {
  final String deviceId;
  final Profile profile;
  final Function()? addDevice;
  const BottomBar(this.profile, this.deviceId, this.addDevice, {super.key});


  void _showModalBottomSheet(BuildContext context, Widget content) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Wrap(
          children: [ content ] 
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceButton = IconButton(
      tooltip: "Linked Device",
      icon: const Icon(Icons.phonelink_setup),
      onPressed: () { _showModalBottomSheet(context, _DeviceSheet(deviceId, addDevice)); },
    );

    final profileButton = IconButton(
      tooltip: "View profile",
      icon: const Icon(Icons.person),
      onPressed: () { _showModalBottomSheet(context, _AccountSheet(profile.name, profile.email)); },
    );
    final logoutButton = IconButton(
      tooltip: "Sign out",
      icon: const Icon(Icons.logout),
      onPressed: () {confirmDiaglog(
        context: context,
        prompt: "Sign out?",
        action: () {
          NotificationService.pauseSubscribtion(profile.email);
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoginRoute(),
              transitionDuration: const Duration(milliseconds: 900),
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
          );}
      );},
    );
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        child: Row(
          children: [logoutButton, profileButton, deviceButton],
        ),
      ),
    );
  }
}


class _DeviceSheet extends StatelessWidget {
  final String deviceId;
  final Function()? action;

  const _DeviceSheet(this.deviceId, this.action);

  @override
  Widget build(BuildContext context) {
    const sizedBoxSpace = SizedBox(height: 24);
    const halfSizedBoxSpace = SizedBox(height: 12);
    final linkDeviceMessage = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'You have no linked device.',
          style: TextStyle(
            fontSize: 17,
          )
        ),
      ],
    );
    final deviceLinkedMessage = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text(
          'Linked device: ',
          style: TextStyle(
            fontSize: 17,
          )
        ),
      ]
    );

    Widget deviceIdMessage(String deviceId) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          Text("$deviceId ", style: const TextStyle(fontWeight: FontWeight.bold)),
          const Icon(Icons.done),
      ],
    );
    final linkDeviceButton = ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      ),
      onPressed: () { Navigator.of(context).pop(); action!(); },
      child: const Text(
        'Link device',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ), 
    );
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: deviceId == '' ? [
          sizedBoxSpace,
          linkDeviceMessage,
          sizedBoxSpace,
          linkDeviceButton,
          sizedBoxSpace,
        ] : [
          sizedBoxSpace,
          deviceLinkedMessage,
          halfSizedBoxSpace,
          deviceIdMessage(deviceId),
          sizedBoxSpace,
      ],
    );
  }
}



class _AccountSheet extends StatelessWidget {
  final String name;
  final String email;
  const _AccountSheet(this.name, this.email);
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(name),
            accountEmail: Text(email),
            currentAccountPicture: name2avatar(name),
            decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            ),
          ),
        ],
    );
  }
}

