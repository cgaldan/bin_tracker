import 'package:flutter/material.dart';
import '../models/bin_model.dart';

class BinCreationScreen extends StatefulWidget {
  final BinItem? bin;
  final int? binKey;

  const BinCreationScreen({Key? key, this.bin, this.binKey}) : super(key: key);

  @override
  State<BinCreationScreen> createState() => _BinCreationScreenState();
}

class _BinCreationScreenState extends State<BinCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _idCtrl = TextEditingController();
  final _locCtrl = TextEditingController();


  @override
  void initState() {
    super.initState();
    if (widget.bin != null) {
      _idCtrl.text = TextEditingController(text: widget.bin?.id ?? "").text;
      _locCtrl.text = TextEditingController(text: widget.bin?.location ?? "").text;
    }
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  void _saveBin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final idText = _idCtrl.text.trim();
    final locationText = _locCtrl.text.trim();

      BinItem result;
      if (widget.bin != null) {
        result = widget.bin!.copyWith(
          id: idText,
          location: locationText.isNotEmpty ? locationText : null,
        );
      } else {
        result = BinItem(
          id: idText,
          location: locationText.isNotEmpty ? locationText : null,
          currentRentalKey: null,
          rentalHistory: [],
        );
      }

      if (!mounted) return;
      Navigator.pop(context, result);
    }
  

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.bin != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Bin' : 'Create Bin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _idCtrl,
                decoration: InputDecoration(
                  labelText: 'Bin ID',
                  hintText: 'e.g. B123',
                  ),
                validator: (value) =>
                  (value == null || value.isEmpty) ? 'Please enter a bin ID' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _locCtrl,
                decoration: InputDecoration(
                  labelText: 'Location (Optional)',
                  hintText: 'e.g. Ikarou 88',
                  ),

              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
              ElevatedButton(
                onPressed: _saveBin,
                child: Text(isEdit ? 'Save Changes' : 'Create Bin'),
              ),

                ],
              ),  
            ],
          ),          
        ),
      ),
    );
  }
}