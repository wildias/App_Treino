import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../db/database_helper.dart';

class DetalhesPage extends StatefulWidget {
  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  late Map<String, dynamic> exercicio;
  late int id;
  late TextEditingController sessoesController;
  late TextEditingController pesoController;
  String? imagemPath;

  @override
  void initState() {
    super.initState();
    sessoesController = TextEditingController();
    pesoController = TextEditingController();
  }

  @override
  void dispose() {
    sessoesController.dispose();
    pesoController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    exercicio = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    id = exercicio['id'];
    sessoesController.text = (exercicio['sessoes'] ?? 3).toString();
    pesoController.text = (exercicio['peso'] ?? 0.0).toString();
    imagemPath = exercicio['imagem'];
  }

  Future<void> escolherImagem() async {
    final picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      final dir = await getApplicationDocumentsDirectory();
      final String nomeArquivo = basename(imagem.path);
      final String novoPath = join(dir.path, nomeArquivo);

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
    exercicio['peso'] = double.tryParse(pesoController.text.replaceAll(',', '.')) ?? 0.0;
    exercicio['imagem'] = imagemPath;

    await DatabaseHelper.instance.atualizar(exercicio);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = imagemPath != null
        ? Image.file(File(imagemPath!), height: 180, width: double.infinity, fit: BoxFit.cover)
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
        actions: [
          IconButton(
            onPressed: salvarEdicao,
            icon: const Icon(Icons.save),
            tooltip: 'Salvar',
          )
        ],
      ),
      body: SingleChildScrollView(
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
              controller: pesoController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
