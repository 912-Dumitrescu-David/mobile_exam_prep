import 'package:flutter/material.dart';
import 'package:app/Controller/controller.dart';
import 'package:app/Model/entity.dart';
import 'package:logger/logger.dart';

class AddEntityPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddEntityPageState();
}

class _AddEntityPageState extends State<AddEntityPage> {
  final Controller controller = Controller.instance;
  final Logger log = Logger();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveEntity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final newEntity = TestEntity(
        name: _nameController.text, id: 0,
        // Add other required fields for your TestEntity
      );

      await controller.addEntity(newEntity);
      log.i('Entity saved successfully');

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      log.e('Error saving entity: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Entity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveEntity,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}