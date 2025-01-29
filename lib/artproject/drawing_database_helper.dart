import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class DrawingDatabaseHelper {
  static final _databaseName = "DrawingDatabase.db";
  static final _databaseVersion = 1;
  static final table = 'drawings';
  static final columnId = '_id'; // 列1
  static final columnDrawing = 'drawing'; // 列2
  static final is_photo_flag = "is_photo_flag";
  // シングルトンパターン
  DrawingDatabaseHelper._privateConstructor();
  static final DrawingDatabaseHelper instance =
      DrawingDatabaseHelper._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (!(_database is Database)) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY,
        $columnDrawing BLOB NOT NULL,
        $is_photo_flag INTEGER
      )
    ''');
  }

  Future<int> insertDrawing(Uint8List drawingData, int photo_flag) async {
    Database db = await instance.database;
    return await db
        .insert(table, {'drawing': drawingData, "is_photo_flag": photo_flag});
  }

  // 他のメソッド（取得、更新、削除）を必要に応じて追加
  // 挿入
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // 全件取得
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // 更新
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // 削除
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  // 描画データを全件取得するメソッド
  Future<List<Map<String, dynamic>>> fetchDrawings() async {
    Database db = await instance.database;
    return await db.query(table);
  }
}
