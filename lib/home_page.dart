import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:mylauncher/utils/distance.dart';
import 'package:url_launcher/url_launcher.dart';

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
  @override
  void initState() {
    super.initState();

    // preload contact list
    // getContacts();
  }

  void callback(SearchController controller) {
    controller.clear();
    controller.closeView(null);
  }

  /*List<Contact>? _contacts;
  Future<List<Contact>> getContacts() async {
    if (_contacts != null) {
      return _contacts!;
    }

    if (await FlutterContacts.requestPermission()) {
      // Get all contacts (lightly fetched)
      return _contacts = await FlutterContacts.getContacts();
    }

    return [];
  }*/

  Future<Iterable<Widget>> suggestionsBuilder(BuildContext context,
      SearchController controller, List<Application> appList) async {
    final text = controller.text.toLowerCase();

    appList = appList.toList();

    final map = <String, int>{};

    int i = 0;
    while (i < appList.length) {
      final app = appList[i];

      final aName = app.appName
          .toLowerCase()
          .substring(0, min(app.appName.length, text.length));

      final dist = levenstheinDistance(aName, text);

      if (dist < 2) {
        map[app.packageName] = dist;
        i++;
      } else {
        appList.removeAt(i);
      }
    }

    appList.sort((A, B) {
      int aDist = map[A.packageName]!;
      int bDist = map[B.packageName]!;

      return aDist.compareTo(bDist);
    });

    return [
      if (text.isNotEmpty)
        ListTile(
          title: Text(text),
          leading: const Icon(Icons.web),
          subtitle: const Text("Launch web search"),
          trailing: const Icon(Icons.navigate_next),
          onTap: () async {
            final Uri url = Uri.https("duckduckgo.com", "/", {"q": text});
            if (!await launchUrl(url)) {
              if(context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not launch $url")));
              }
            }
            else{
              callback(controller);
            }
          },
        ),
      ...appList.map((app) => AppTile(
            app: app,
            callback: () => callback(controller),
          ))
    ];
  }

  List<Application>? apps;
  Future<List<Application>> getAppList() async {
    return apps ??= await DeviceApps.getInstalledApplications(
      onlyAppsWithLaunchIntent: true,
      includeSystemApps: true,
      includeAppIcons: true,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                            suggestionsBuilder: (context, controller) =>
                                suggestionsBuilder(
                                    context, controller, appList),
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
                          Builder(builder: (context) {
                            if (!snapAppList.hasData) {
                              return const Text("Loading");
                            }

                            return FutureBuilder<List<Favorite>>(
                                future: Settings.getFavorites(),
                                builder: (context, snapFav) {
                                  final apps = snapFav.data ?? [];

                                  if (apps.isEmpty) return Container();
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        for (Favorite fav in apps)
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
                                    ),
                                  );
                                });
                          })
                        ],
                      );
                    }),
              ),
            )),
          );
        });
  }
}
