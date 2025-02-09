import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class DatabaseHelper {
  static final _databaseName = "MyDatabase.db"; // DB名
  static final _databaseVersion = 2; // バージョン番号

  static final table = 'generate_arts'; // テーブル名

  static final columnId = '_id'; // 列1
  static final columnDrawing = 'drawing'; // 列2
  static final columnPhoto = 'photo'; // 列3
  static final columnSelectedPhoto = 'selectedphoto'; // 列4

  // DatabaseHelperクラスをシングルトンにするためのコンストラクタ
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

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
        version: _databaseVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnDrawing TEXT NOT NULL,
            $columnPhoto TEXT NOT NULL,
            $columnSelectedPhoto BLOB
          )
          ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE $table ADD COLUMN $columnSelectedPhoto BLOB DEFAULT NULL');
    }
  }

  Future<int> insertImage(
      String imageData, String photoPath, Uint8List selectedPhotoData) async {
    Database db = await instance.database;
    try {
      return await db.insert(table, {
        columnDrawing: imageData,
        columnPhoto: photoPath,
        columnSelectedPhoto: selectedPhotoData,
      });
    } catch (e) {
      print('Error inserting image: $e');
      return -1; // エラー時には -1 を返す
    }
  }

// insert メソッドは削除するか、必要に応じて残す

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

  Future<int> clearNonIdColumns(int id) async {
    Database db = await instance.database;
    return await db.update(
      table,
      {
        columnDrawing: null,
        columnPhoto: null,
        columnSelectedPhoto: null,
      },
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
