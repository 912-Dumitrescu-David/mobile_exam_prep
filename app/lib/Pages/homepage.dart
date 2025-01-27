import 'dart:async';

import 'package:app/Controller/web_socket_service.dart';
import 'package:flutter/material.dart';
import 'package:app/Pages/ListPage.dart';
import 'package:app/Pages/SortPage.dart';
import 'package:app/Pages/FilterPage.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}


class HomePageState extends State<HomePage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ListPage()),
                );
              },
              child: Text('List Section'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SortPage()),
                );
              },
              child: Text('Sort Page'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FilterPage()),
                );
              },
              child: Text('Filter Page'),
            ),
          ],
        ),
      ),
    );
  }
}
