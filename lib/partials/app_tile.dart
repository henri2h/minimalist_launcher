import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

import '../utils/settings.dart';

class AppTile extends StatelessWidget {
  const AppTile(
      {super.key,
      required this.app,
      this.displayIcon = false,
      this.callback,
      this.onFavorite,
      this.onDeleted});

  final AppInfo app;
  final bool displayIcon;
  final VoidCallback? callback;
  final VoidCallback? onFavorite;
  final VoidCallback? onDeleted;

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
                      await InstalledApps.openSettings(app.packageName);
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
                      await InstalledApps.uninstallApp(app.packageName);
                      if (context.mounted) {
                        onDeleted?.call();
                      }
                    }),
              ],
            );
          });
    }

    return ListTile(
      title: Text(app.name, style: const TextStyle(fontSize: 18)),
      leading: displayIcon && app.icon != null
          ? CircleAvatar(
              child: Image.memory(app.icon!, width: 32),
            )
          : null,
      onTap: () async {
        if (await InstalledApps.startApp(app.packageName) ?? false) {
          callback?.call();
        }
      },
      onLongPress: onLongPress,
    );
  }
}
