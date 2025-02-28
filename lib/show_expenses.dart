import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ShowExpenses extends StatefulWidget {
  @override
  _ShowExpensesState createState() => _ShowExpensesState();
}

class _ShowExpensesState extends State<ShowExpenses> {
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Gastos'),
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

                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    DateTime date = (data['timestamp'] as Timestamp).toDate();
                    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(date);

                    return Card(
                      color: Colors.blue,
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          data['description'].toUpperCase(),
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        subtitle: Text(
                          'Importe: ${data['amount']} - Tipo: ${data['person']}',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        trailing: Text(
                          formattedDate,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
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
