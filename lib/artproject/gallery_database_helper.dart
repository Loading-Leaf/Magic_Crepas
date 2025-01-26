import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class GalleryDatabaseHelper {
  static final _databaseName = "MyDatabase.db"; // DB名
  static final _databaseVersion = 2; // バージョン番号

  static final table = 'drawings'; // テーブル名

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
    if (_database != null) return _database!;
    _database = await _initDatabase();
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
    const blobType = 'BLOB';

    await db.execute('''
    CREATE TABLE $table (
      $columnId $idType,
      $columnDrawing $blobType,
      $columnPhoto $blobType,
      $columnSelectedPhoto $blobType
    )
    ''');
  }

  Future<int> insertDrawing(Map<String, dynamic> drawingData) async {
    final db = await instance.database;
    return await db.insert(table, drawingData);
  }

  Future<List<Map<String, dynamic>>> fetchDrawings() async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
