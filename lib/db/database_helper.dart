import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _dbName = 'treino.db';
  static const _dbVersion = 2;

  static const table = 'exercicios';

  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Verifica se a coluna já existe antes de adicionar (opcional, mas seguro)
      final result = await db.rawQuery("PRAGMA table_info($table)");
      final exists = result.any((row) => row['name'] == 'repeticoes');

      if (!exists) {
        await db.execute(
          'ALTER TABLE $table ADD COLUMN repeticoes INTEGER DEFAULT 10',
        );
      }
    }
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        dia TEXT NOT NULL,
        sessoes INTEGER DEFAULT 3,
        repeticoes INTEGER DEFAULT 10,
        peso REAL DEFAULT 0.0,
        imagem TEXT,
        feito INTEGER DEFAULT 0
      )
    ''');
  }

  // Inserir exercício
  Future<int> inserir(Map<String, dynamic> exercicio) async {
    final db = await database;
    return await db.insert(table, exercicio);
  }

  // Buscar exercícios por dia
  Future<List<Map<String, dynamic>>> buscarPorDia(String dia) async {
    final db = await database;
    return await db.query(table, where: 'dia = ?', whereArgs: [dia]);
  }

  // Atualizar exercício
  Future<int> atualizar(Map<String, dynamic> exercicio) async {
    final db = await database;
    return await db.update(
      table,
      exercicio,
      where: 'id = ?',
      whereArgs: [exercicio['id']],
    );
  }

  // Marcar como feito/não feito
  Future<int> marcarFeito(int id, bool feito) async {
    final db = await database;
    return await db.update(
      table,
      {'feito': feito ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Remover exercício (opcional)
  Future<int> deletar(int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  // Verificar se todos estão feitos no dia
  Future<bool> todosFeitos(String dia) async {
    final db = await database;
    final result = await db.query(
      table,
      where: 'dia = ? AND feito = 0',
      whereArgs: [dia],
    );
    return result.isEmpty;
  }

  // Resetar todos os treinos (feito = 0)
  Future<void> resetarSemana() async {
    final db = await database;
    await db.update(table, {'feito': 0});
  }
}
