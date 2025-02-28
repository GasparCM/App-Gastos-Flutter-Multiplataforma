import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  String _expenseType = 'Gaspar';

  void _submitExpense() {
    if (_formKey.currentState!.validate()) {
      DateTime selectedDate;
      if (_dateController.text.isEmpty) {
        selectedDate = DateTime.now();
      } else {
        selectedDate = DateFormat('yyyy-MM-dd').parse(_dateController.text);
      }

      FirebaseFirestore.instance.collection('expenses').add({
        'description': _descriptionController.text,
        'amount': double.parse(_amountController.text),
        'person': _expenseType,
        'timestamp': Timestamp.fromDate(selectedDate),
      });

      _descriptionController.clear();
      _amountController.clear();
      _dateController.clear();
      setState(() {
        _expenseType = 'Gaspar';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('GASTOS COMPARTIDOS')),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una descripción';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(labelText: 'Importe'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un importe';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: InputDecoration(
                    labelText: 'Fecha del gasto (yyyy-MM-dd)',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        _selectDate(context);
                      },
                    ),
                  ),
                  readOnly: true,
                ),
                DropdownButtonFormField<String>(
                  value: _expenseType,
                  decoration: InputDecoration(labelText: 'Quién ha pagado'),
                  items: [
                    DropdownMenuItem(
                      value: 'Gaspar',
                      child: Text('Gaspar'),
                    ),
                    DropdownMenuItem(
                      value: 'Ainara',
                      child: Text('Ainara'),
                    ),
                    DropdownMenuItem(
                      value: 'A medias',
                      child: Text('A medias'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _expenseType = value!;
                    });
                  },
                ),
                SizedBox(height: 40.0),
                _buildStyledButton('Añadir Gasto', _submitExpense),
                SizedBox(height: 30.0),
                _buildStyledButton('Ver Gastos', () {
                  Navigator.pushNamed(context, '/show_expenses');
                }),
                SizedBox(height: 30.0),
                _buildStyledButton('Ver Estadísticas', () {
                  Navigator.pushNamed(context, '/statistics');
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity, // Hace que el botón ocupe todo el ancho
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Cambia el color de fondo
          foregroundColor: Colors.white, // Color del texto
          shadowColor: Colors.black54, // Color de la sombra
          elevation: 5, // Elevación
          padding: EdgeInsets.symmetric(vertical: 15), // Espaciado interno
          textStyle: TextStyle(fontSize: 16), // Estilo del texto
        ),
        child: Text(text),
      ),
    );
  }
}

