import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Statistics extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas de Gastos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: _selectedMonth,
              items: _getMonthDropdownItems(),
              onChanged: (value) {
                setState(() {
                  _selectedMonth = value!;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('expenses')
                  .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(int.parse(_selectedMonth.split('-')[0]), int.parse(_selectedMonth.split('-')[1]), 1)))
                  .where('timestamp', isLessThan: Timestamp.fromDate(DateTime(int.parse(_selectedMonth.split('-')[0]), int.parse(_selectedMonth.split('-')[1]) + 1, 1)))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                double gasparTotal = 0;
                double ainaraTotal = 0;
                double ambosTotal = 0;

                // Recorre los documentos para sumar los gastos
                snapshot.data!.docs.forEach((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                  double amount = data['amount'];

                  if (data['person'] == 'Gaspar') {
                    gasparTotal += amount;
                  } else if (data['person'] == 'Ainara') {
                    ainaraTotal += amount;
                  } else if (data['person'] == 'A medias') {
                    ambosTotal += amount;
                  }
                });

                double totalGastos = gasparTotal + ainaraTotal + ambosTotal;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        color: Colors.lightBlue,
                        child: ListTile(
                          title: Text(
                            'Gastos de Gaspar',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            '\$${gasparTotal.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.pinkAccent,
                        child: ListTile(
                          title: Text(
                            'Gastos de Ainara',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            '\$${ainaraTotal.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.orangeAccent,
                        child: ListTile(
                          title: Text(
                            'Gastos a Medias',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            '\$${ambosTotal.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Card(
                        color: Colors.red,
                        child: ListTile(
                          title: Text(
                            'Total Gastado',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          subtitle: Text(
                            '\$${totalGastos.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getMonthDropdownItems() {
    List<String> months = [];
    DateTime now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      DateTime date = DateTime(now.year, now.month - i, 1);
      months.add(DateFormat('yyyy-MM').format(date));
    }
    return months.map((String month) {
      return DropdownMenuItem<String>(
        value: month,
        child: Text(month),
      );
    }).toList();
  }
}

