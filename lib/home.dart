import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class mainScreen extends StatefulWidget {
  const mainScreen({Key? key}) : super(key: key);

  @override
  State<mainScreen> createState() => _mainScreenState();
}

class _mainScreenState extends State<mainScreen> {
  final foodController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Color.fromARGB(255, 255, 184, 0)),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: 50,
            ),
            TextField(
              controller: foodController,
              decoration: InputDecoration(
                  hintText: 'food',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            ElevatedButton(onPressed: fetchdata, child: Text('Search'))
          ]),
        ),
      ),
    );
  }

  void fetchdata() async {
    print('data');
    final url =
        'https://api.edamam.com/search?q=${foodController.text}&app_id=52f1e434&app_key=dfbc1dbae383fc5f5b68ab38f84d24ba';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body);
    print(json);
  }
}
