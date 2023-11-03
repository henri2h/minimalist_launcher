import 'dart:async';

import 'package:collection/collection.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

import 'partials/app_button.dart';
import 'partials/app_tile.dart';
import 'partials/time_tile.dart';
import 'utils/settings.dart';

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
  void callback(SearchController controller) {
    controller.clear();
    controller.closeView(null);
  }

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

    return FutureBuilder<bool>(
        future: FlutterWindowManager.addFlags(
            FlutterWindowManager.FLAG_SHOW_WALLPAPER),
        builder: (context, snapWallpaper) {
          return AnnotatedRegion(
            value: const SystemUiOverlayStyle(
              systemNavigationBarColor: Colors.transparent, // Navigation bar
              statusBarColor: Colors.transparent, // Status bar
            ),
            child: Scaffold(
                body: RefreshIndicator(
              onRefresh: () async {
                apps = null;
                await getAppList();
              },
              child: SafeArea(
                child: FutureBuilder<List<Application>>(
                    future: getAppList(),
                    builder: (context, snapAppList) {
                      final appList = snapAppList.data ?? [];

                      appList.sort((a, b) => a.appName
                          .toLowerCase()
                          .compareTo(b.appName.toLowerCase()));

                      return Column(
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
                            builder: (BuildContext context,
                                SearchController controller) {
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
                            child: ListView.builder(
                              itemCount: appList.length,
                              itemBuilder: (BuildContext context, int index) {
                                final app = appList[index];
                                return AppTile(
                                  app: app,
                                  onFavorite: () {
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Builder(builder: (context) {
                              if (!snapAppList.hasData) {
                                return const Text("no data");
                              }

                              return FutureBuilder<List<Favorite>>(
                                  future: Settings.getFavorites(),
                                  builder: (context, snapFav) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        for (Favorite fav in snapFav.data ?? [])
                                          Builder(builder: (context) {
                                            final item = snapAppList.data!
                                                .firstWhereOrNull((app) =>
                                                    app.packageName == fav.id);
                                            if (item == null) {
                                              return Container();
                                            }
                                            return AppButton(
                                              icon: fav.icon != null
                                                  ? Icon(fav.icon)
                                                  : Image.memory(
                                                      (item as ApplicationWithIcon)
                                                          .icon,
                                                      width: 32),
                                              onPressed: () => item.openApp(),
                                            );
                                          }),
                                      ],
                                    );
                                  });
                            }),
                          )
                        ],
                      );
                    }),
              ),
            )),
          );
        });
  }
}
