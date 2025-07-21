import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/dia_card.dart';
import '../db/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> diasSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
  ];
  final Map<String, bool> progresso = {};
  int diasConcluidos = 0;

  @override
  void initState() {
    super.initState();
    verificarResetSemanal();
    carregarProgresso();
  }

  void verificarResetSemanal() async {
    final hoje = DateTime.now();
    if (hoje.weekday == DateTime.monday) {
      await DatabaseHelper.instance.resetarSemana();
    }
  }

  Future<void> carregarProgresso() async {
    final Map<String, bool> temp = {};
    int contagem = 0;

    for (final dia in diasSemana) {
      bool feito = await DatabaseHelper.instance.todosFeitos(dia);
      temp[dia] = feito;
      if (feito) contagem++;
    }

    setState(() {
      progresso.clear();
      progresso.addAll(temp);
      diasConcluidos = contagem;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String diaAtual = DateFormat(
      'EEEE',
      'pt_BR',
    ).format(DateTime.now()).toLowerCase();

    if (diaAtual == 'sábado') {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/resultado');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Treinos da Semana'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Logo opaca no fundo
          Opacity(
            opacity: 0.04,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 280,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Conteúdo principal
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: diasSemana.length,
                    itemBuilder: (context, index) {
                      final dia = diasSemana[index];
                      final feito = progresso[dia] ?? false;

                      final diaHoje = DateFormat(
                        'EEEE',
                        'pt_BR',
                      ).format(DateTime.now()).toLowerCase();
                      final indexHoje = diasSemana.indexWhere(
                        (d) => d.toLowerCase() == diaHoje,
                      );

                      Color corFundo;
                      if (feito) {
                        corFundo = Colors.green;
                      } else if (index < indexHoje) {
                        corFundo = Colors.red;
                      } else {
                        corFundo = Colors.grey.shade300;
                      }

                      return GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            '/exercicios',
                            arguments: dia,
                          );
                          await carregarProgresso();
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            color: corFundo,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dia,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Icon(
                                feito
                                    ? Icons.check_circle
                                    : Icons.fitness_center,
                                color: feito ? Colors.white : Colors.black54,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$diasConcluidos/5 dias concluídos',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
