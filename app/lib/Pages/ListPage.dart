import 'dart:async';

import 'package:app/Controller/web_socket_service.dart';
import 'package:flutter/material.dart';
import 'package:app/Controller/controller.dart';
import 'package:app/Model/entity.dart';
import 'package:logger/logger.dart';
import 'package:app/Pages/AddEntityPage.dart'; // Import the new page

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  final Controller controller = Controller.instance;
  final Logger log = Logger();

  bool isConnected = false;
  bool isLoading = false;
  bool isFirstTime = true;
  List<TestEntity> models = [];
  //--------------------
  late WebSocketService _webSocketService;
  late StreamSubscription<String> _streamSubscription;

  @override
  void initState() {
    super.initState();
    if (isFirstTime) _loadModels();

    _webSocketService = WebSocketService(serverUrl: 'ws://192.168.1.132:3000');

    _streamSubscription = _webSocketService.messageStream.listen((message) {
      _showMessageAlert(message);
    });
  }

  void _showMessageAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Message'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  //-----------------------------


  Future<void> _loadModels() async {
    log.i('Loading models...');
    setState(() => isLoading = true);

    try {
      final connectivityResult = await controller.isOnline();
      setState(() => isConnected = connectivityResult);

      final fetchedModels = await controller.getAllEntities();
      setState(() {
        models = fetchedModels.cast<TestEntity>();
        isLoading = false;
        isFirstTime = false;
      });

      log.i('Models loaded: ${models.length}');
    } catch (e) {
      log.e('Error loading models: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _navigateToAddPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEntityPage()),
    );

    if (result == true) {
      // Reload the list if an entity was added
      _loadModels();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Models'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadModels,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPage,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : models.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isConnected
                            ? 'No models available.'
                            : 'You are offline.',
                        style: const TextStyle(fontSize: 18),
                      ),
                      if (!isConnected) ...[
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _loadModels,
                          child: const Text('Retry Connection'),
                        ),
                      ]
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: models.length,
                  itemBuilder: (context, index) {
                    final model = models[index];
                    return ListTile(
                      title: Text(model.name),
                      // Add more model details as needed
                    );
                  },
                ),
    );
  }
}
