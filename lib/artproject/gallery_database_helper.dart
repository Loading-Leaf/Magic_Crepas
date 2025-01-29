import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

class GalleryDatabaseHelper {
  static final _databaseName = "GalleryDatabase.db"; // DB名
  static final _databaseVersion = 3; // バージョン番号

  static final table = 'arts'; // テーブル名

  static final columnId = '_id'; // 列1
  static final columnDrawing = 'drawingimage'; // 列2
  static final columnPhoto = 'photoimage'; // 列3
  static final columnSelectedPhoto = 'outputimage'; // 列4
  static final columntitle = 'title'; // 列2
  static final columnemotion = 'emotion'; // 列3
  static final columndetailemotion = 'detailemotion'; // 列4

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
    await db.execute('''
    CREATE TABLE $table (
      $columnId INTEGER PRIMARY KEY,
      $columnDrawing BLOB,
      $columnPhoto BLOB,
      $columnSelectedPhoto BLOB,
      $columntitle TEXT NOT NULL,
      $columnemotion TEXT NOT NULL,
      $columndetailemotion TEXT NOT NULL
    )
    ''');
  }

  Future<int> insertDrawing(Map<String, dynamic> drawingData) async {
    try {
      Database db = await instance.database;

      // データの存在確認
      /*
      if (drawingData['drawingimage'] == null) {
        throw Exception('Drawing image is missing');
      } else if (drawingData['outputimage'] == null) {
        throw Exception('Output image is missing');
      }*/

      // photoimageはnullableとして扱う
      Map<String, dynamic> sanitizedData = {
        columnDrawing: drawingData['drawingimage'],
        columnPhoto: drawingData['photoimage'],
        columnSelectedPhoto: drawingData['outputimage'],
        columntitle: drawingData['title'],
        columnemotion: drawingData['emotion'],
        columndetailemotion: drawingData['detailemotion'],
      };
      return await db.insert(table, sanitizedData);
    } catch (e) {
      print('Error inserting drawing: $e');
      rethrow;
    }
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
