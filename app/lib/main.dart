import 'package:app/Controller/controller.dart';
import 'package:app/Controller/web_socket_service.dart';
import 'package:app/Model/entity.dart';
import 'package:app/Repository/abstract_repo.dart';
import 'package:app/Repository/server_repo.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Abstractrepo repo = Abstractrepo();
  ServerRepo serverRepo = ServerRepo();
  WebSocketService ws = WebSocketService(serverUrl: 'ws://localhost:3000');

  Controller.initialize(localRepo: repo, serverRepo: serverRepo, isOnline: ws.isConnected);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TestEntity> _entities = [];

  void _getAllEntities() async {
    final controller = Controller.instance;
    await controller.addEntity(TestEntity(id: 1, name: "test"));
    final entities = await controller.getAllEntities();
    setState(() {
      _entities = entities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Entities fetched from the server/local:',
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _entities.length,
                itemBuilder: (context, index) {
                  final entity = _entities[index];
                  return ListTile(
                    title: Text(entity.name),
                    subtitle: Text('ID: ${entity.id}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getAllEntities,
        tooltip: 'Get All',
        child: const Icon(Icons.download),
      ),
    );
  }
}
