// ===== bottom_bar.dart ==============================
// A bottom bar with a profile button to be included
// in most of the app's screens.

import 'package:flutter/material.dart';
import 'package:app/utilities/avatar.dart';
import 'package:app/utilities/models.dart';


class BottomBar extends StatelessWidget {
  final Profile profile;
  const BottomBar(this.profile, {super.key});


  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Wrap(
          children: [ _BottomSheetContent(profile.name, profile.email) ] 
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        child: Row(
          children: [
            IconButton(
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              icon: const Icon(Icons.person),
              onPressed: () { _showModalBottomSheet(context); },
            ),
          ],
        ),
      ),
    );
  }
}




class _BottomSheetContent extends StatelessWidget {
  final String name;
  final String email;
  const _BottomSheetContent(this.name, this.email);
  @override
  Widget build(BuildContext context) {
    return Column(
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

