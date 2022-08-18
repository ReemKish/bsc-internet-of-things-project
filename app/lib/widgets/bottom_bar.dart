// ===== bottom_bar.dart ==============================
// A bottom bar with a profile button to be included
// in most of the app's screens.

import 'package:flutter/material.dart';
import 'package:app/utilities/avatar.dart';


class BottomBar extends StatelessWidget {
  const BottomBar({super.key});


  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Wrap(
          children: [ _BottomSheetContent() ] 
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
  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Re'em Kishinevsky"),
            accountEmail: const Text("reem.kishinevsky@gmail.com"),
            currentAccountPicture: name2avatar("Re'em Kishinevsky"),
            decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          ),
        ],
    );
  }
}

