import 'dart:io';
import 'package:app_treino/utils/fullscreen_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../db/database_helper.dart';

class DetalhesPage extends StatefulWidget {
  const DetalhesPage({super.key});

  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  late Map<String, dynamic> exercicio;
  late int id;
  late TextEditingController sessoesController;
  late TextEditingController pesoController;
  late TextEditingController repeticoesController;
  String? imagemPath;

  @override
  void initState() {
    super.initState();
    sessoesController = TextEditingController();
    pesoController = TextEditingController();
    repeticoesController = TextEditingController();
    ativarModoFullscreen();
  }

  @override
  void dispose() {
    sessoesController.dispose();
    pesoController.dispose();
    repeticoesController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    exercicio = Map<String, dynamic>.from(args); // cria uma cópia mutável
    id = exercicio['id'];
    sessoesController.text = (exercicio['sessoes'] ?? 3).toString();
    pesoController.text = (exercicio['peso'] ?? 0.0).toString();
    repeticoesController.text = (exercicio['repeticoes'] ?? 10).toString();
    imagemPath = exercicio['imagem'];
  }

  Future<void> escolherImagem() async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      final dir = await getApplicationDocumentsDirectory();
      final String nomeArquivo = p.basename(imagem.path);
      final String novoPath = p.join(dir.path, nomeArquivo);

      final File novaImagem = await File(imagem.path).copy(novoPath);

      setState(() {
        imagemPath = novaImagem.path;
      });

      exercicio['imagem'] = imagemPath;
      await DatabaseHelper.instance.atualizar(exercicio);
    }
  }

  Future<void> salvarEdicao() async {
    exercicio['sessoes'] = int.tryParse(sessoesController.text) ?? 3;
    exercicio['peso'] =
        double.tryParse(pesoController.text.replaceAll(',', '.')) ?? 0.0;
    exercicio['repeticoes'] = int.tryParse(repeticoesController.text) ?? 10;
    exercicio['imagem'] = imagemPath;

    await DatabaseHelper.instance.atualizar(exercicio);

    // Mostrar mensagem de sucesso
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercício salvo com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Aguardar o SnackBar antes de voltar
      await Future.delayed(const Duration(seconds: 2));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = imagemPath != null
        ? Image.file(
            File(imagemPath!),
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          )
        : Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.image, size: 80, color: Colors.grey),
          );

    return Scaffold(
      appBar: AppBar(
        title: Text(exercicio['nome']),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: salvarEdicao,
            icon: const Icon(Icons.save),
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Marca d'água da logo ao fundo
          Opacity(
            opacity: 0.05,
            child: Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 280,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Conteúdo principal
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: escolherImagem,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageWidget,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: sessoesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Sessões (séries)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: repeticoesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Repetições',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: pesoController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    border: OutlineInputBorder(),
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
