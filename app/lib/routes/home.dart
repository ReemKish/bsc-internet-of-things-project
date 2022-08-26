// ===== home.dart ========================================
// Home page of the app. Shows list of linked devices.

import 'dart:io';

import 'package:app/utilities/alarm.dart';
import 'package:flutter/material.dart';
import 'package:app/utilities/alerts.dart';
import 'package:app/widgets/bottom_bar.dart';
import 'package:app/models/profile_device.dart';
import 'package:app/utilities/avatar.dart';
import 'package:app/routes/scan_qr.dart';
import 'package:app/widgets/dialog.dart';
import 'package:app/services/cloud_service.dart';
import 'package:app/services/notification_service.dart';


class HomeRoute extends StatefulWidget {
  final Profile profile;
  HomeRoute(this.profile, {Key? key}) : super(key: key) {
    NotificationService.registerForegroundHandler((String deviceId) {});
    /* registerBackgroundHandler((String deviceId) {}); */
}

  @override
  State createState() => HomeRouteState();
}


class HomeRouteState extends State<HomeRoute> with WidgetsBindingObserver{
  final _tracked = <Device>[
    Device("ARC-001", Profile("Reem Kishinevsky", "reem.kishinevsky@gmail.com", "054-642-1200", "pas1")),
    Device('ARC-002', Profile("David Molina", "davidm@gmail.com", "054-123-4567", "pas2"))
  ];


  var _viewed = <DeviceItem>[];

  void constructViewed() {
    _viewed = _tracked.map((device) => DeviceItem(this, device, key: Key(device.id))).toList();
  }

  Widget _buildDeviceList() {
    constructViewed();
    return ListView(
      padding: const EdgeInsets.only(top: 4.0, bottom: 32),
      children: _viewed,
    );
  }

  void _followDevice(String id) {
    /* update device list */
    setState(() {
      _tracked.add(CloudService.id2device(id));
    });
    /* subscribe to notifications */
    NotificationService.followDevice(widget.profile.email, id);
  }

  void _scanDeviceQR() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
          buildqr(context, (id) {
            _followDevice(id);
        })
      )
    );
  }

  void _addDevice() async {
    Navigator.of(context).push(
      DialogRoute<String>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text("Add Device"),
          children: [
            DialogItem(
              icon: Icons.qr_code_scanner,
              text: 'Scan device QR',
              action: _scanDeviceQR,
            ),
            DialogFieldButton(
              icon: Icons.vpn_key,
              text: 'Enter device ID',
              action: _followDevice,
            ),
          ],
        )
      )
    );
  }

  void _setEmergency(String deviceId, bool emergency) {
    print(deviceId);
    for (var i = 0; i < _viewed.length; i++) {
      if (_viewed[i].key == Key(deviceId)) {
        _viewed[i].setEmergency(emergency);
      }
    }
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
        onPressed: _addDevice,
        tooltip: "Scan device QR",
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BottomBar(widget.profile),
    );
  }
}


class DeviceItem extends StatefulWidget {
  final Device? device;
  final HomeRouteState deviceList;
  late Function setEmergency;
  DeviceItem(this.deviceList, this.device, {Key? key, isExpand = false}) : super(key: key);

  @override
  State<DeviceItem> createState() {
    final state = _DeviceItemState();
    setEmergency = state.setEmergency;
    return state;
  }
}

class _DeviceItemState extends State<DeviceItem> {
  bool emergency = false;

  void setEmergency(bool emergency) {
    setState(() {
      this.emergency = emergency;
    });
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final holder = device!.holder;
    return Card(
      color: emergency ? Colors.red : Theme.of(context).cardColor,
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
                      setState(() {
                        widget.deviceList.setState(() {
                          widget.deviceList._tracked.remove(device);
                          print(widget.deviceList._tracked);
                          widget.deviceList.constructViewed();
                          print(widget.deviceList._viewed);
                        });
                      });
                    }
                  );
                },
                tooltip: "Remove",
                icon: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red
                ),
              ),
              IconButton(  // Notify
                onPressed: () {
                  device.notify ?
                    showInSnackBar(context, "Disabled notifictations from ${holder.name}.") :
                    showInSnackBar(context, "Enabled notifictations from ${holder.name}.");
                  setState(() {
                    device.notify = !device.notify;
                  });
                },
                tooltip: "Notify",
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
