import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'pages/home_page.dart';

void main() {
  runApp(const AppWrapper());
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: lightDynamic,
            scaffoldBackgroundColor: Colors.transparent,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkDynamic,
            scaffoldBackgroundColor: Colors.transparent,
            useMaterial3: true,
          ),
          color: Colors.transparent,
          home: const HomePage());
    });
  }
}
