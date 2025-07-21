import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Adicione isso
import 'pages/home_page.dart';
import 'pages/exercicios_page.dart';
import 'pages/detalhes_page.dart';
import 'pages/resultado_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // necessário para await
  await initializeDateFormatting('pt_BR', null); // inicializa locale
  runApp(const TreinoApp());
}

class TreinoApp extends StatelessWidget {
  const TreinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treino Semanal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white, // define cor dos ícones e do título
          elevation: 2,
        ),
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
