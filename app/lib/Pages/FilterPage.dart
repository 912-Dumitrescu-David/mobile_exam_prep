import 'package:flutter/material.dart';
import 'package:app/Model/entityfilter.dart';
import 'package:app/Controller/controller.dart';

import 'EntityDeleteScreen.dart';

class FilterPage extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _FilterPageState();

}

class _FilterPageState extends State<FilterPage>{
  late Future<List<String?>> _filters;
  final Controller controller = Controller.instance;

  @override
  void initState() {
    super.initState();
    _filters = initFilters();
  }

  Future<List<String?>> initFilters() async {
    return  await controller.getAllFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Available Colors"),
      ),
      body: FutureBuilder<List<String?>>(
        future: _filters,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final filters = snapshot.data!;
            return ListView.builder(
              itemCount: filters.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filters[index]!),
                  onTap: () {
                    // Navigate to next screen to view cabs of selected color
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EntitydeleteScreen(filter: filters[index]!),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(child: Text('No colors available.'));
          }
        },
      ),
    );
  }
}
