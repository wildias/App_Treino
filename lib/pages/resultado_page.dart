import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ResultadoPage extends StatefulWidget {
  const ResultadoPage({super.key});

  @override
  State<ResultadoPage> createState() => _ResultadoPageState();
}

class _ResultadoPageState extends State<ResultadoPage> {
  final List<String> diasSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
  ];
  int diasCompletos = 0;
  String mensagem = '';

  @override
  void initState() {
    super.initState();
    calcularResultado();
  }

  Future<void> calcularResultado() async {
    int completados = 0;

    for (String dia in diasSemana) {
      bool feito = await DatabaseHelper.instance.todosFeitos(dia);
      if (feito) completados++;
    }

    setState(() {
      diasCompletos = completados;
      mensagem = gerarMensagem(completados);
    });
  }

  String gerarMensagem(int total) {
    switch (total) {
      case 5:
        return '🎉 Parabéns! Sua semana foi perfeita (5/5)';
      case 4:
        return '👏 Quase lá! Faltou pouco (4/5)';
      case 3:
        return '👍 Metade da semana foi feita! Continue assim.';
      case 2:
        return '⚠️ Você treinou pouco essa semana (2/5). Vamos melhorar!';
      case 1:
        return '😅 Só um dia? Você consegue mais!';
      default:
        return '😔 Nenhum treino completado. Bora começar de novo na próxima!';
    }
  }

  void voltarParaHome() {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resumo da Semana'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: diasCompletos == 0 && mensagem.isEmpty
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mensagem,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: voltarParaHome,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
