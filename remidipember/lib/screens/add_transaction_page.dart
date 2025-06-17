import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/transaction_model.dart';
import '../services/database_service.dart';

class AddTransactionPage extends StatefulWidget {
  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _dateController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sourceController = TextEditingController();
  File? _imageFile;
  String? _imagePath;

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _dateController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day} ${_getMonthName(picked.month)} ${picked.year}";
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Get the application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      
      // Create a new file path in the documents directory
      final fileName = path.basename(pickedFile.path);
      final savedImage = File('${appDir.path}/$fileName');
      
      // Copy the file to a new location
      await File(pickedFile.path).copy(savedImage.path);

      setState(() {
        _imageFile = savedImage;
        _imagePath = savedImage.path;
      });
    }
  }

  Future<void> _saveImagePath(String transactionId) async {
    if (_imagePath != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('transaction_image_$transactionId', _imagePath!);
    }
  }

  Future<String?> _getImagePath(String transactionId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('transaction_image_$transactionId');
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Column(
        children: [
          Image.file(
            _imageFile!,
            height: 150,
            width: 150,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() {
              _imageFile = null;
              _imagePath = null;
            }),
            child: Text('Remove Image'),
          ),
        ],
      );
    } else {
      return Container(
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Center(
          child: Text('No image selected'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = TransactionService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Data'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Preview and Selection
              Center(child: _buildImagePreview()),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text('Camera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.photo_library),
                    label: Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              // Form Fields
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Jenis',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Tanggal',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp. ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Deskripsi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _sourceController,
                decoration: InputDecoration(
                  labelText: 'Sumber',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a source';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final transaction = Transaction(
                      title: _titleController.text,
                      category: _categoryController.text,
                      date: _dateController.text,
                      amount: int.parse(_amountController.text),
                      description: _descriptionController.text,
                      source: _sourceController.text,
                    );

                    // Add transaction to database
                    final transactionId = await database.addTransaction(transaction);
                    
                    // Save image path if image was selected
                    if (_imagePath != null) {
                      await _saveImagePath(transactionId);
                    }

                    Navigator.pop(context);
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