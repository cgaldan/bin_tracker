import 'package:flutter/material.dart';
import '../models/bin_model.dart';

class BinCreationScreen extends StatefulWidget {
  @override
  _BinCreationScreenState createState() => _BinCreationScreenState();
}

class _BinCreationScreenState extends State<BinCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _idCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add A Bin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _idCtrl,
                decoration: InputDecoration(labelText: 'Bin ID'),
                validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter a bin ID' : null,
              ),
              TextFormField(
                controller: _locCtrl,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter a location' : null,
              ),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _phoneCtrl,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter a phone number' : null,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Create Bin'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newBin = BinItem(
                      id: _idCtrl.text,
                      location: _locCtrl.text,
                      contactName: _nameCtrl.text,
                      contactPhone: _phoneCtrl.text,
                      startDate: DateTime.now(),
                    );
                    Navigator.of(context).pop(newBin);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}