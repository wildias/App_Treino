import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class ExerciciosPage extends StatefulWidget {
  const ExerciciosPage({super.key});

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

  Future<void> confirmarExclusao(Map<String, dynamic> exercicio) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Exercício'),
        content: Text('Tem certeza que deseja excluir "${exercicio['nome']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deletar(exercicio['id']);
      await carregarExercicios();
    }
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: adicionarExercicio,
            tooltip: 'Adicionar Exercício',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Imagem de fundo
          Opacity(
            opacity: 0.05,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 260,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Conteúdo principal
          ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: exercicios.length,
            itemBuilder: (context, index) {
              final exercicio = exercicios[index];
              final feito = exercicio['feito'] == 1;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => abrirDetalhes(exercicio),
                  onLongPress: () => confirmarExclusao(exercicio),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: feito
                          ? Colors.green.shade300
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: feito,
                          onChanged: (_) => toggleFeito(index),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            exercicio['nome'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
