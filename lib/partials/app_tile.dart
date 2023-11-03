import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

import '../utils/settings.dart';

class AppTile extends StatelessWidget {
  const AppTile(
      {super.key,
      required this.app,
      this.displayIcon = false,
      this.callback,
      this.onFavorite});

  final Application app;
  final bool displayIcon;
  final VoidCallback? callback;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    void onLongPress() async {
      await showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Column(
              children: [
                ListTile(
                    title: const Text("Settings"),
                    leading: const Icon(Icons.settings),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await app.openSettingsScreen();
                    }),
                ListTile(
                    title: const Text("Add to favorites"),
                    leading: const Icon(Icons.favorite),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await Settings.toggleFavorite(app.packageName);
                      onFavorite?.call();
                    }),
                ListTile(
                    title: const Text("Uninstall app"),
                    leading: const Icon(Icons.delete),
                    onTap: () async {
                      Navigator.of(context).pop();
                      await app.uninstallApp();
                    }),
              ],
            );
          });
    }

    return ListTile(
      title: Text(app.appName, style: const TextStyle(fontSize: 18)),
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
      onLongPress: onLongPress,
    );
  }
}
