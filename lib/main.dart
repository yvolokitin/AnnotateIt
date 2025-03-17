import "package:vap/widgets/debugborder.dart";
import "package:vap/utils/theme.dart";

import "package:vap/pages/mainmenu.dart";
// import "package:vap/pages/account.dart";
// import "package:vap/pages/learn.dart";
// import "package:vap/pages/about.dart";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

ThemeData themeData = getSystemTheme();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);

  runApp(const AnnotateItApp());
}

class AnnotateItApp extends StatefulWidget {
  const AnnotateItApp({super.key});

  @override
  AnnotateItAppState createState() => AnnotateItAppState();
}

class AnnotateItAppState extends State<AnnotateItApp> {
  ThemeData theme = getSystemTheme();

  // changes the widget state when updating the theme through changing the theme variable to the given theme.
  updateTheme(ThemeData theme) {
    setState(() {
      this.theme = theme;
    });
    themeData = theme;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Annot@It",
      theme: theme,
      home: MainPage(),
    );
  }
}
