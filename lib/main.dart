import 'package:app_gastos/statics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'show_expenses.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gastos App',
      home: MyHomePage(), // Aquí colocas tu página de entrada
      routes: {
        '/show_expenses': (context) => ShowExpenses(),
        '/statistics': (context) => Statistics(), // Nueva ruta para estadísticas
      },
    );
  }
}
