import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class GalleryDatabaseHelper {
  static final _databaseName = "MyDatabase.db"; // DB名
  static final _databaseVersion = 2; // バージョン番号

  static final table = 'generate_arts'; // テーブル名

  static final columnId = '_id'; // 列1
  static final columnDrawing = 'drawing'; // 列2
  static final columnPhoto = 'photo'; // 列3
  static final columnSelectedPhoto = 'selectedphoto'; // 列4

  // DatabaseHelperクラスをシングルトンにするためのコンストラクタ
  GalleryDatabaseHelper._privateConstructor();
  static final GalleryDatabaseHelper instance =
      GalleryDatabaseHelper._privateConstructor();

  Database? _database;

  // DBにアクセスするためのメソッド
  Future<Database> get database async {
    // データベースが未初期化の場合、初期化
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
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    const blobType = 'BLOB';

    await db.execute('''
    CREATE TABLE drawings (
      id $idType,
      drawing $blobType,
      image $blobType,
      outputImage $blobType
    )
    ''');
  } // 挿入関数

  Future<int> insertDrawing(Map<String, dynamic> drawingData) async {
    final db = await instance.database;
    return await db.insert('drawings', drawingData);
  }

  // すべての絵を取得する関数
  Future<List<Map<String, dynamic>>> getDrawings() async {
    final db = await instance.database;
    return await db.query('drawings');
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
