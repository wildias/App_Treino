import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/dia_card.dart';
import '../db/database_helper.dart';

class HomePage extends StatefulWidget {
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
    for (final dia in diasSemana) {
      temp[dia] = await DatabaseHelper.instance.todosFeitos(dia);
    }
    setState(() {
      progresso.clear();
      progresso.addAll(temp);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String diaAtual =
        DateFormat('EEEE', 'pt_BR').format(DateTime.now()).toLowerCase();

    if (diaAtual == 'sábado') {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/resultado');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Treinos da Semana'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: diasSemana.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final dia = diasSemana[index];
            final feito = progresso[dia] ?? false;

            final diaHoje =
                DateFormat('EEEE', 'pt_BR').format(DateTime.now()).toLowerCase();
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

            return DiaCard(
              nome: dia,
              cor: corFundo,
              onTap: () async {
                await Navigator.pushNamed(context, '/exercicios', arguments: dia);
                await carregarProgresso();
              },
            );
          },
        ),
      ),
    );
  }
}
