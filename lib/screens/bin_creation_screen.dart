import 'package:flutter/material.dart';
import '../models/bin_model.dart';

class BinCreationScreen extends StatefulWidget {
  final BinItem? bin;

  const BinCreationScreen({Key? key, this.bin}) : super(key: key);
  @override
  State<BinCreationScreen> createState() => _BinCreationScreenState();
}

class _BinCreationScreenState extends State<BinCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _idCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.bin != null) {
      _idCtrl.text = widget.bin!.id;
      _locCtrl.text = widget.bin!.location;
      _nameCtrl.text = widget.bin!.contactName;
      _phoneCtrl.text = widget.bin!.contactPhone;
      _startDate = widget.bin!.startDate;
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _locCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _saveBin() {
    if (_formKey.currentState?.validate() ?? false) {
      final newBin = BinItem(
        id: _idCtrl.text,
        location: _locCtrl.text,
        contactName: _nameCtrl.text,
        contactPhone: _phoneCtrl.text,
        startDate: _startDate,
        endDate: _startDate.add(const Duration(days: 10)), // Assuming endDate is 10 days after startDate
      );

      Navigator.pop(context, newBin);
    }
  }

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
                onPressed: _saveBin,
                child: Text('Create Bin'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}