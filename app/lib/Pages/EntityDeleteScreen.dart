


import 'package:flutter/material.dart';
import 'package:app/Controller/controller.dart';
import 'package:app/Model/entity.dart';

class EntitydeleteScreen extends StatefulWidget {
  final String filter;

  EntitydeleteScreen({required this.filter});

  @override
  _EntitydeleteScreenState createState() => _EntitydeleteScreenState();
}

class _EntitydeleteScreenState extends State<EntitydeleteScreen> {
  late Future<List<TestEntity>> _entities;

  @override
  void initState() {
    super.initState();
    _entities = Controller.instance.getEntityFilter(widget.filter);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entities for ${widget.filter}'),
      ),
      body: FutureBuilder<List<TestEntity>>(
        future: _entities,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final entities = snapshot.data!;
            return ListView.builder(
              itemCount: entities.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(entities[index].name),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await Controller.instance.deleteEntity(entities[index].id);
                      setState(() {
                        _entities = Controller.instance.getEntityFilter(widget.filter);
                      });
                    },
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No cabs available.'));
          }
        },
      ),
    );
  }
}
