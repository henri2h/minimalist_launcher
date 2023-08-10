import 'dart:async';

import 'package:collection/collection.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';

import 'partials/app_button.dart';
import 'partials/app_tile.dart';
import 'partials/time_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Favorite {
  final IconData? icon;
  final String id;

  Favorite({this.icon, required this.id});
}

class _HomePageState extends State<HomePage> {
  List<Favorite> favorites = [
    Favorite(icon: Icons.phone, id: "com.google.android.dialer"),
    Favorite(icon: Icons.message, id: "com.google.android.apps.messaging"),
    Favorite(id: "com.facebook.orca", icon: Icons.group),
    Favorite(id: "com.whatsapp", icon: Icons.timer),
    Favorite(id: "com.instagram.android", icon: Icons.camera),
  ];

  @override
  Widget build(BuildContext context) {
    List<Application>? apps;
    Future<List<Application>> getAppList() async {
      return apps ??= await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true,
        includeSystemApps: true,
        includeAppIcons: true,
      );
    }

    void callback(SearchController controller) {
      controller.clear();
      controller.closeView(null);
    }

    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () async {
        apps = null;
        await getAppList();
      },
      child: SafeArea(
        child: FutureBuilder<List<Application>>(
            future: getAppList(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();

              final appList = snapshot.data!;
              appList.sort((a, b) => a.appName.compareTo(b.appName));
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TimeTile(),
                    ),
                    SearchAnchor(
                      suggestionsBuilder: (context, controller) {
                        final text = controller.text.toLowerCase();
                        final apps = appList.where((element) =>
                            element.appName.toLowerCase().contains(text));
                        return apps
                            .map((app) => AppTile(
                                  app: app,
                                  callback: () => callback(controller),
                                ))
                            .toList();
                      },
                      builder:
                          (BuildContext context, SearchController controller) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Icon(Icons.search,
                                      size: 25,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                  const SizedBox(
                                    width: 14,
                                  ),
                                  const Expanded(
                                    child: Text("Search",
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: ListView.builder(
                          itemCount: appList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final app = appList[index];
                            return AppTile(app: app);
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Builder(builder: (context) {
                        if (!snapshot.hasData) {
                          return const Text("no data");
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            for (final fav in favorites)
                              Builder(builder: (context) {
                                final item = snapshot.data!.firstWhereOrNull(
                                    (app) => app.packageName == fav.id);
                                if (item == null) {
                                  return Container();
                                }
                                return AppButton(
                                  icon: fav.icon != null
                                      ? Icon(fav.icon)
                                      : Image.memory(
                                          (item as ApplicationWithIcon).icon,
                                          width: 32),
                                  onPressed: () => item.openApp(),
                                );
                              }),
                          ],
                        );
                      }),
                    )
                  ],
                ),
              );
            }),
      ),
    ));
  }
}
