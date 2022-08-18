// ===== home.dart ==============================
// Home page of the app. Shows list of linked devices.

import 'package:flutter/material.dart';
import 'package:app/utilities/alerts.dart';
import 'package:app/widgets/bottom_bar.dart';
import 'package:app/utilities/structures.dart';
import 'package:app/utilities/avatar.dart';


class HomeRoute extends StatefulWidget {
  const HomeRoute({Key? key}) : super(key: key);

  @override
  State createState() => HomeRouteState();
}


class HomeRouteState extends State<HomeRoute> {
  final _tracked = <Device>[
    Device(1, Profile("David Molina", "davidm@gmail.com", "054-123-4567"), notify: false),
    Device(2, Profile("Yuval Cohen", "yuvalc@walla.co.il", "054-631-1200")),
  ];


  Widget _buildDeviceList() {
    return  ListView(
      children: _tracked.map(
        (device) {
          return DeviceItem(this, device);
        },
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget noDevicesMsg = const Center(
      child: Text(
        "You have no tracked devices.",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 21,
          color: Colors.grey,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(toolbarHeight: 40),
      body: _tracked.isEmpty ? noDevicesMsg : _buildDeviceList(),
      floatingActionButton: FloatingActionButton(
              onPressed: () {},
              tooltip: "Scan device QR",
              child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: const BottomBar(),
    );
  }
}


class DeviceItem extends StatefulWidget {
  final Device? device;
  final HomeRouteState deviceList;
  const DeviceItem(this.deviceList, this.device, {Key? key, isExpand = false}) : super(key: key);

  @override
  State<DeviceItem> createState() => _DeviceItemState();
}

class _DeviceItemState extends State<DeviceItem> {
  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final holder = device!.holder;
    return Card(
      child: ExpansionTile(
        childrenPadding: const EdgeInsets.only(top: 0),
        title: Text(
          holder.name,
          style: const TextStyle(
            fontSize: 22,
          ),
        ),
        subtitle: Text(
          "OK",
          style: TextStyle(
            fontSize: 16,
            color: Colors.green.shade300,
          ),
        ),
        leading: ExcludeSemantics(
          child: name2avatar(holder.name, size: 18),
        ),
        children: <Widget>[
          ListTile(  // Email
            title: Text(holder.email),
            leading: const Icon(Icons.email),
            horizontalTitleGap: 0,
            visualDensity: const VisualDensity(vertical: -4),
          ),
          ListTile(  // Phone number
            title: Text(holder.phoneNumber),
            leading: const Icon(Icons.phone),
            horizontalTitleGap: 0,
            visualDensity: const VisualDensity(vertical: -4),
          ),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              IconButton(  // Delete
                onPressed: () {
                  confirmDiaglog(
                    context: context,
                    prompt: "Stop tracking ${holder.name}?",
                    action: () { 
                      widget.deviceList.setState(() {
                        widget.deviceList._tracked.remove(device);
                      });
                    }
                  );
                },
                icon: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red
                ),
              ),
              IconButton(  // Notify
                onPressed: () {
                  device.notify ?
                    showInSnackBar(context, "off") :
                    showInSnackBar(context, "on");
                  setState(() {
                    device.notify = !device.notify;
                  });
                },
                icon: Icon(
                  device.notify ? Icons.notifications_on : Icons.notifications_off,
                  color: device.notify ?
                            (
                              Theme.of(context).brightness == Brightness.dark ?
                                Colors.yellow.shade100 :
                                Colors.black.withRed(195).withGreen(195)
                            ) : 
                            Theme.of(context).iconTheme.color,
                ),
              ),
            ]
          )
        ]
        /* tileColor: const Color(0x0A00FF00), // greyish-green */
        /* tileColor: const Color(0x40FF0000), // greyish-red */
      )
    );
  }
}
