import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ExerciciosPage extends StatefulWidget {
  @override
  State<ExerciciosPage> createState() => _ExerciciosPageState();
}

class _ExerciciosPageState extends State<ExerciciosPage> {
  late String nomeDia;
  List<Map<String, dynamic>> exercicios = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    nomeDia = ModalRoute.of(context)?.settings.arguments as String? ?? '';
    carregarExercicios();
  }

  Future<void> carregarExercicios() async {
    final lista = await DatabaseHelper.instance.buscarPorDia(nomeDia);
    setState(() {
      exercicios = lista;
    });
  }

  Future<void> adicionarExercicio() async {
    String nomeNovo = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Novo Exercício'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nome do exercício'),
            onChanged: (value) => nomeNovo = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeNovo.trim().isNotEmpty) {
                  await DatabaseHelper.instance.inserir({
                    'nome': nomeNovo.trim(),
                    'dia': nomeDia,
                    'feito': 0,
                  });
                  Navigator.pop(context);
                  await carregarExercicios();
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> toggleFeito(int index) async {
    final exercicio = exercicios[index];
    final id = exercicio['id'] as int;
    final feito = exercicio['feito'] == 1;
    await DatabaseHelper.instance.marcarFeito(id, !feito);
    await carregarExercicios();
  }

  void abrirDetalhes(Map<String, dynamic> exercicio) {
    Navigator.pushNamed(
      context,
      '/detalhes',
      arguments: exercicio,
    ).then((_) => carregarExercicios());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Treinos da $nomeDia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: adicionarExercicio,
            tooltip: 'Adicionar Exercício',
          )
        ],
      ),
      body: ListView.builder(
        itemCount: exercicios.length,
        itemBuilder: (context, index) {
          final exercicio = exercicios[index];
          return ListTile(
            title: Text(exercicio['nome']),
            leading: Checkbox(
              value: exercicio['feito'] == 1,
              onChanged: (_) => toggleFeito(index),
            ),
            onTap: () => abrirDetalhes(exercicio),
          );
        },
      ),
    );
  }
}
