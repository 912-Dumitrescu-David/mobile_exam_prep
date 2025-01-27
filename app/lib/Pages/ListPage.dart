import 'package:flutter/material.dart';
import 'package:app/Controller/controller.dart';
import 'package:app/Model/entity.dart';
import 'package:logger/logger.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  final Controller controller = Controller.instance;
  final Logger log = Logger();

  bool isConnected = false;
  bool isLoading = false;
  List<TestEntity> models = [];

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    log.i('Loading models...');
    setState(() => isLoading = true);

    try {
      final connectivityResult = await controller.isOnline();
      setState(() => isConnected = connectivityResult);

      // Controller handles switching between local and server automatically
      final fetchedModels = await controller.getAllEntities();
      setState(() {
        models = fetchedModels.cast<TestEntity>();
        isLoading = false;
      });

      log.i('Models loaded: ${models.length}');
    } catch (e) {
      log.e('Error loading models: $e');
      setState(() => isLoading = false);
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
            title: Text(model.name)
            // Add more model details as needed
          );
        },
      ),
    );
  }
}