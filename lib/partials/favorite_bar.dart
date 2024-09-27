import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:mylauncher/pages/home_page.dart';
import 'package:mylauncher/partials/app_button.dart';
import 'package:mylauncher/utils/settings.dart';

class FavoriteBar extends StatelessWidget {
  FavoriteBar({super.key, required this.apps});
  List<AppInfo> apps;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Favorite>>(
        future: Settings.getFavorites(),
        builder: (context, snapFav) {
          final favApps = snapFav.data ?? [];

          if (favApps.isEmpty) return Container();
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (Favorite fav in favApps)
                  Builder(builder: (context) {
                    final item = apps
                        .firstWhereOrNull((app) => app.packageName == fav.id);
                    if (item == null) {
                      return Container();
                    }
                    return AppButton(
                        icon: fav.icon != null || item.icon == null
                            ? Icon(fav.icon)
                            : Image.memory(item.icon!, width: 32),
                        onPressed: () async {
                          print("open app ${item.packageName}");
                          await InstalledApps.startApp(item.packageName);
                        });
                  }),
              ],
            ),
          );
        });
  }
}
