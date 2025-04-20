import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _dbName = 'history.db';
  static const _dbVersion = 1;
  static const _tableName = 'News';

  // Column names
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnPublishedTime = 'publishedTime';
  static const columnImageUrl = 'imageUrl';
  static const columnWebUrl = 'webUrl';
  static const columnDescription = 'description';
  static const columnAuthorName = 'authorName';

  // Singleton instance
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(path,
        version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnTitle TEXT NOT NULL UNIQUE,
        $columnPublishedTime TEXT NOT NULL,
        $columnImageUrl TEXT,
        $columnWebUrl TEXT NOT NULL,
        $columnDescription TEXT,
        $columnAuthorName TEXT
      )
    ''');
  }
Future<bool> toggleBookmark(Map<String, dynamic> newsArticle) async {
  Database db = await instance.database;

  // Check if the article is already bookmarked
  List<Map> existingNews = await db.query(
    _tableName,
    where: 'title = ?',
    whereArgs: [newsArticle['title']]
  );

  if (existingNews.isNotEmpty) {
    // If the article is already bookmarked, remove it
    await db.delete(
      _tableName,
      where: 'title = ?',
      whereArgs: [newsArticle['title']]
    );
    return false;
  } else {
    // If the article isn't bookmarked, add it
    await db.insert(_tableName, newsArticle);
    return true;
  }
}
Future<List<Map<String, dynamic>>> fetchAllNews() async {
    final db = await database;
    return await db.query(_tableName);
}

Future<bool>    isBookmarked(String title) async {
  Database db = await instance.database;

  List<Map> existingNews = await db.query(
    _tableName,
    where: 'title = ?',
    whereArgs: [title]
  );

  return existingNews.isNotEmpty;
}


  // Add other CRUD operations (insert, update, delete, retrieve)
}
