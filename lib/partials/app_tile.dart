import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

class AppTile extends StatelessWidget {
  const AppTile(
      {super.key, required this.app, this.displayIcon = false, this.callback});

  final Application app;
  final bool displayIcon;
  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(app.appName),
      leading: displayIcon
          ? CircleAvatar(
              child: Image.memory((app as ApplicationWithIcon).icon, width: 32),
            )
          : null,
      onTap: () async {
        if (await app.openApp()) {
          callback?.call();
        }
      },
      onLongPress: app.openSettingsScreen,
    );
  }
}
