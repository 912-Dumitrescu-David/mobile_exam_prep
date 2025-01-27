import 'package:app/Controller/controller.dart';
import 'package:app/Model/entity.dart';
import 'package:app/Repository/abstract_repo.dart';
import 'package:app/Repository/server_repo.dart';
import 'package:flutter/material.dart';
import 'Controller/web_socket_service.dart';
import 'Pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Abstractrepo repo = Abstractrepo();
  repo.initDb();
  ServerRepo serverRepo = ServerRepo();
  WebSocketService ws = WebSocketService(serverUrl: 'ws://192.168.1.132:3000');
  // repo.clearAllEntities();
  Controller.initialize(localRepo: repo, serverRepo: serverRepo, isOnline: ws.isConnected);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage()
    );
  }
}
