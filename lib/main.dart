import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/exercicios_page.dart';
import 'pages/detalhes_page.dart';
import 'pages/resultado_page.dart';

void main() {
  runApp(TreinoApp());
}

class TreinoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treino Semanal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/resultado': (context) => ResultadoPage(),
        '/exercicios': (context) => ExerciciosPage(),
        '/detalhes': (context) => DetalhesPage(),
      },
    );
  }
}
