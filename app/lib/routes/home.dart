// ===== home.dart ========================================
// Home page of the app. Shows list of linked devices.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app/widgets/alerts.dart';
import 'package:app/widgets/bottom_bar.dart';
import 'package:app/models/profile_device.dart';
import 'package:app/utilities/avatar.dart';
import 'package:app/routes/scan_qr.dart';
import 'package:app/services/cloud_service.dart';
import 'package:app/services/notification_service.dart';
import 'package:app/utilities/alarm.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';


class HomeRoute extends StatefulWidget {
  final Profile profile;
  const HomeRoute(this.profile, {Key? key}) : super(key: key);

  @override
  State createState() => HomeRouteState();
}


class HomeRouteState extends State<HomeRoute> with WidgetsBindingObserver{
  bool _registerdHandler = false;  // register notification foreground handler only once.
  final _followedDevices = <String, DeviceEntry>{
    "ARC-001": DeviceEntry("ARC-001", Profile(name: "Reem Kishinevsky", email: "reem.kishinevsky@gmail.com", phoneNumber: "054-642-1200")),
    "ARC-002": DeviceEntry('ARC-002', Profile(name: "David Molina", email: "davidm@gmail.com", phoneNumber: "054-123-4567")),
  };


  Widget _buildDeviceList() => ListView(
    padding: const EdgeInsets.only(top: 4.0, bottom: 32),
    children: _followedDevices.values.map((device) => DeviceItem(
      device: device,
      delFun: () => setState(() {_followedDevices.remove(device.deviceId);}),
      dismissAlarm: () => setState(() {device.emergenecy = false;}),
      emergency: device.emergenecy,
      key: Key(device.deviceId))
    ).toList()
  );

  void _followDevice(BuildContext ctx, String deviceId) async {
    /* update device list */
    final progress = ProgressHUD.of(ctx);
    progress?.show();
    final profile = await CloudService.follow(widget.profile.email, deviceId);
    if (profile == null) {
      progress?.dismiss();
      alertDiaglog(
        context: context,
        title: "Unrecognized device",
        content: "Make sure to register device [$deviceId] before following it.",
      );
      return;
    }
    /* subscribe to notifications */
    await NotificationService.followDevice(widget.profile.email, deviceId);
    final device = DeviceEntry(deviceId, profile);
    setState(() {
      _followedDevices[deviceId] = device;
    });
    progress?.dismiss();
  }

  void _scanDeviceQR(BuildContext ctx) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
          buildqr(context, (id) {
            _followDevice(ctx, id);
        })
      )
    );
  }

  void _addDevice(BuildContext ctx) async {
    Navigator.of(context).push(
      DialogRoute<String>(
        context: context,
        builder: (context) => SimpleDialog(
          title: const Text("Add Device"),
          children: [
            DialogItem(
              icon: Icons.qr_code_scanner,
              text: 'Scan device QR',
              action: () => _scanDeviceQR(ctx),
            ),
            DialogFieldButton(
              icon: Icons.vpn_key,
              text: 'Enter device ID',
              action: (deviceId) => _followDevice(ctx, deviceId),
            ),
          ],
        )
      )
    );
  }


  @override
  Widget build(BuildContext context) {
    // Register a foreground notification handler to indicate emergency on a specific device.
    if (!_registerdHandler) {
      _registerdHandler = true;
      NotificationService.registerForegroundHandler((String deviceId) {
        setState(() {
          _followedDevices[deviceId]?.emergenecy = true;
        });
        Alarm.beep();
      });
    }

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

    return ProgressHUD(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(toolbarHeight: 40),
          body: _followedDevices.isEmpty ? noDevicesMsg : _buildDeviceList(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {_addDevice(context); },
            tooltip: "Scan device QR",
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          bottomNavigationBar: BottomBar(widget.profile),
        ),
      ),
    );
  }
}


class DeviceItem extends StatefulWidget {
  final DeviceEntry device;
  final Function() delFun;
  final Function() dismissAlarm;
  final bool emergency;
  const DeviceItem({
    required this.device,
    required this.delFun,
    required this.dismissAlarm,
    required this.emergency,
  Key? key}) : super(key: key);

  @override
  State<DeviceItem> createState() => _DeviceItemState();
}

class _DeviceItemState extends State<DeviceItem> {
  Color baseNonEmergencyColor = Colors.grey;
  Color baseEmergencyColor = Colors.red.shade700;
  Color emergencyColor = Colors.red;
  Timer? timerColor, timerAlarm;

  void animateEmergencyColor() {
    setState(() {
      emergencyColor = (emergencyColor == baseEmergencyColor ? Theme.of(context).scaffoldBackgroundColor : baseEmergencyColor);
    });
  }

  @override
  void initState() {
      timerColor = Timer.periodic(const Duration(seconds: 1), (Timer t) => animateEmergencyColor());
      timerAlarm = Timer.periodic(const Duration(seconds: 10), (Timer t) => () {} );
      /* timerAlarm = Timer.periodic(const Duration(seconds: 10), (Timer t) => () { Alarm.beep();}); */
      super.initState();
    }

  @override
  void dispose() {
    timerColor?.cancel();
    timerAlarm?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;
    final holder = device.holder;
    final emergency = widget.emergency;
    final dismissAlarm = widget.dismissAlarm;

    final removeButton = IconButton(  // Delete
                  onPressed: () {
                    confirmDiaglog(
                      context: context,
                      prompt: "Stop tracking ${holder.name}?",
                      action: widget.delFun,
                    );
                  },
                  tooltip: "Remove",
                  icon: const Icon(
                    Icons.delete_forever_outlined,
                    color: Colors.red
                  ),
                );

    final notifyButton = IconButton(  // Notify
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
                );

    final dismissAlarmButton = IconButton(  // Delete
                  onPressed: dismissAlarm,
                  tooltip: "Dismiss alarm",
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.red
                  ),
                );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      color: emergency ? emergencyColor : Theme.of(context).scaffoldBackgroundColor,
      child: Card(
        child: ExpansionTile(
          childrenPadding: const EdgeInsets.only(top: 0),
          title: Text(
            holder.name,
            style: const TextStyle(
              fontSize: 22,
            ),
          ),
          subtitle:
            emergency ?
              Text("EMERGENCY", style: TextStyle(fontSize: 16, color: Colors.red.shade300)) :
              Text("OK", style: TextStyle(fontSize: 16, color: Colors.green.shade300)),
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
              children: emergency ?
                [removeButton, notifyButton, dismissAlarmButton] : 
                [removeButton, notifyButton],
            )
          ]
          /* tileColor: const Color(0x0A00FF00), // greyish-green */
          /* tileColor: const Color(), // greyish-red */
        )
      )
    );
  }
}
