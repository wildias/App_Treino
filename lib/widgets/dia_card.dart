import 'package:flutter/material.dart';

class DiaCard extends StatelessWidget {
  final String nome;
  final Color cor;
  final VoidCallback onTap;

  const DiaCard({
    required this.nome,
    required this.cor,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Center(
          child: Text(
            nome,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
