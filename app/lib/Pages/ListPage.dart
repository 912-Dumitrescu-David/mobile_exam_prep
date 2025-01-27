import 'package:flutter/material.dart';
import 'package:app/Controller/controller.dart';
import 'package:app/model/entity.dart';

class ListPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ListPageState();
}

class ListPageState extends State<ListPage> {
  Controller controller = Controller.instance;
  bool isConnected = false;
  bool isInitialCheckDone = false;
  List<TestEntity> items = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  // Method to check network connection
  Future<void> _checkConnection() async {
    final connectivityResult = controller.isOnline();
    setState(() {
      isConnected = connectivityResult;
      isInitialCheckDone = true;
    });

    if (isConnected) {
      _fetchItems();
    }
  }

  // Method to fetch items if online
  Future<void> _fetchItems() async {
    setState(() {
      isLoading = true;
    });

    try {
      items = (await controller.getAllEntities()).cast<TestEntity>();
    } catch (error) {
      // Handle error (optional: display a toast or snackbar)
      items = [];
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Page'),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : isInitialCheckDone || isConnected
          ? items.isEmpty
          ? const Center(
        child: Text(
          'No items available.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('List'),
          );
        },
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'You are offline.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkConnection,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
