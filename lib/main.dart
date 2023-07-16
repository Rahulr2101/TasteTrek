import 'package:flutter/material.dart';
import 'package:tastetrek/body.dart';
import 'package:tastetrek/share.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Store.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tastetrek',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: Colors.white,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: body(),
    );
  }
}
