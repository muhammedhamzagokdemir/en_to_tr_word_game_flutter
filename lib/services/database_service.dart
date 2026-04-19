import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  // Web-compatible in-memory storage
  static final Map<String, List<Map<String, dynamic>>> _webStorage = {};
  static int _webIdCounter = 1;

  bool get _isWeb => kIsWeb;

  Future<Database> get database async {
    if (_isWeb) throw UnsupportedError('SQLite not supported on web');
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, 'ingiliz.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // ==================== WEB STORAGE HELPERS ====================

  Future<List<Map<String, dynamic>>> _webQuery(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    int? limit,
  }) async {
    final data = _webStorage[table] ?? [];
    var results = List<Map<String, dynamic>>.from(data);

    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      // Simple where parsing for common patterns
      final field = where.split('=').first.trim();
      final value = whereArgs.first;
      results = results.where((row) => row[field] == value).toList();
    }

    if (limit != null && results.length > limit) {
      results = results.take(limit).toList();
    }

    return results;
  }

  Future<int> _webInsert(String table, Map<String, dynamic> data) async {
    final newData = Map<String, dynamic>.from(data);
    newData['id'] = _webIdCounter++;

    _webStorage[table] ??= [];
    _webStorage[table]!.add(newData);
    return newData['id'] as int;
  }

  Future<int> _webUpdate(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final storage = _webStorage[table] ?? [];

    if (where != null && whereArgs != null && whereArgs.isNotEmpty) {
      final field = where.split('=').first.trim();
      final value = whereArgs.first;

      for (var i = 0; i < storage.length; i++) {
        if (storage[i][field] == value) {
          storage[i].addAll(data);
          return 1;
        }
      }
    }
    return 0;
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        token TEXT,
        created_at TEXT
      )
    ''');

    // Statistics table
    await db.execute('''
      CREATE TABLE statistics(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        total_correct INTEGER DEFAULT 0,
        total_wrong INTEGER DEFAULT 0,
        total_play_time INTEGER DEFAULT 0,
        streak INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Tasks table (daily tasks)
    await db.execute('''
      CREATE TABLE tasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        daily_question_count INTEGER DEFAULT 0,
        daily_play_time INTEGER DEFAULT 0,
        completed INTEGER DEFAULT 0,
        task_date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Words table (vocabulary)
    await db.execute('''
      CREATE TABLE words(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        english TEXT NOT NULL,
        turkish TEXT NOT NULL,
        difficulty INTEGER DEFAULT 1,
        category TEXT
      )
    ''');

    // Questions table (quiz questions)
    await db.execute('''
      CREATE TABLE questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word_id INTEGER NOT NULL,
        question TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        options TEXT NOT NULL,
        FOREIGN KEY (word_id) REFERENCES words(id)
      )
    ''');

    // Insert default words
    await _insertDefaultWords(db);
    await _insertDefaultQuestions(db);
  }

  Future<void> _insertDefaultWords(Database db) async {
    final words = [
      {
        'english': 'apple',
        'turkish': 'elma',
        'difficulty': 1,
        'category': 'food',
      },
      {
        'english': 'book',
        'turkish': 'kitap',
        'difficulty': 1,
        'category': 'objects',
      },
      {
        'english': 'car',
        'turkish': 'araba',
        'difficulty': 1,
        'category': 'transport',
      },
      {
        'english': 'house',
        'turkish': 'ev',
        'difficulty': 1,
        'category': 'places',
      },
      {
        'english': 'water',
        'turkish': 'su',
        'difficulty': 1,
        'category': 'nature',
      },
      {
        'english': 'computer',
        'turkish': 'bilgisayar',
        'difficulty': 2,
        'category': 'technology',
      },
      {
        'english': 'elephant',
        'turkish': 'fil',
        'difficulty': 2,
        'category': 'animals',
      },
      {
        'english': 'beautiful',
        'turkish': 'güzel',
        'difficulty': 2,
        'category': 'adjectives',
      },
      {
        'english': 'necessary',
        'turkish': 'gerekli',
        'difficulty': 3,
        'category': 'adjectives',
      },
      {
        'english': 'environment',
        'turkish': 'çevre',
        'difficulty': 3,
        'category': 'science',
      },
      {
        'english': 'achievement',
        'turkish': 'başarı',
        'difficulty': 3,
        'category': 'abstract',
      },
      {
        'english': 'responsibility',
        'turkish': 'sorumluluk',
        'difficulty': 3,
        'category': 'abstract',
      },
      {
        'english': 'opportunity',
        'turkish': 'fırsat',
        'difficulty': 3,
        'category': 'abstract',
      },
      {
        'english': 'experience',
        'turkish': 'deneyim',
        'difficulty': 2,
        'category': 'abstract',
      },
      {
        'english': 'knowledge',
        'turkish': 'bilgi',
        'difficulty': 2,
        'category': 'abstract',
      },
      {
        'english': 'communication',
        'turkish': 'iletişim',
        'difficulty': 3,
        'category': 'abstract',
      },
      {
        'english': 'development',
        'turkish': 'gelişim',
        'difficulty': 3,
        'category': 'abstract',
      },
      {
        'english': 'understanding',
        'turkish': 'anlayış',
        'difficulty': 3,
        'category': 'abstract',
      },
      {
        'english': 'relationship',
        'turkish': 'ilişki',
        'difficulty': 3,
        'category': 'abstract',
      },
      {
        'english': 'difference',
        'turkish': 'fark',
        'difficulty': 2,
        'category': 'abstract',
      },
    ];

    for (final word in words) {
      await db.insert('words', word);
    }
  }

  Future<void> _insertDefaultQuestions(Database db) async {
    final questions = [
      {
        'word_id': 1,
        'question': 'What is the Turkish word for "apple"?',
        'correct_answer': 'elma',
        'options': 'elma,muz,portakal,üzüm',
      },
      {
        'word_id': 2,
        'question': 'What is the Turkish word for "book"?',
        'correct_answer': 'kitap',
        'options': 'kitap,defter,kalem,silgi',
      },
      {
        'word_id': 3,
        'question': 'What is the Turkish word for "car"?',
        'correct_answer': 'araba',
        'options': 'araba,bisiklet,uçak,gemi',
      },
      {
        'word_id': 4,
        'question': 'What is the Turkish word for "house"?',
        'correct_answer': 'ev',
        'options': 'ev,okul,hastane,market',
      },
      {
        'word_id': 5,
        'question': 'What is the Turkish word for "water"?',
        'correct_answer': 'su',
        'options': 'su,ateş,hava,toprak',
      },
      {
        'word_id': 6,
        'question': 'What is the Turkish word for "computer"?',
        'correct_answer': 'bilgisayar',
        'options': 'bilgisayar,telefon,tablet,televizyon',
      },
      {
        'word_id': 7,
        'question': 'What is the Turkish word for "elephant"?',
        'correct_answer': 'fil',
        'options': 'fil,aslan,kaplan,zürafa',
      },
      {
        'word_id': 8,
        'question': 'What is the Turkish word for "beautiful"?',
        'correct_answer': 'güzel',
        'options': 'güzel,çirkin,büyük,küçük',
      },
      {
        'word_id': 9,
        'question': 'What is the Turkish word for "necessary"?',
        'correct_answer': 'gerekli',
        'options': 'gerekli,önemli,faydalı,zararlı',
      },
      {
        'word_id': 10,
        'question': 'What is the Turkish word for "environment"?',
        'correct_answer': 'çevre',
        'options': 'çevre,doğa,deniz,orman',
      },
    ];

    for (final question in questions) {
      await db.insert('questions', question);
    }
  }

  // ==================== USER OPERATIONS ====================

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    if (password != passwordConfirmation) {
      return {'success': false, 'message': 'Şifre doğrulaması eşleşmiyor'};
    }

    // Check if email already exists
    final existing = _isWeb
        ? await _webQuery('users', where: 'email = ?', whereArgs: [email])
        : await (await database).query(
            'users',
            where: 'email = ?',
            whereArgs: [email],
          );

    if (existing.isNotEmpty) {
      return {'success': false, 'message': 'E-posta zaten kayıtlı'};
    }

    // Create user
    final token = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final userData = {
      'name': name,
      'email': email,
      'password': password,
      'token': token,
      'created_at': DateTime.now().toIso8601String(),
    };

    final userId = _isWeb
        ? await _webInsert('users', userData)
        : await (await database).insert('users', userData);

    // Create default statistics
    final statsData = {
      'user_id': userId,
      'total_correct': 0,
      'total_wrong': 0,
      'total_play_time': 0,
      'streak': 0,
    };

    if (_isWeb) {
      await _webInsert('statistics', statsData);
    } else {
      await (await database).insert('statistics', statsData);
    }

    // Create today's task
    final taskData = {
      'user_id': userId,
      'daily_question_count': 0,
      'daily_play_time': 0,
      'completed': 0,
      'task_date': _todayString(),
    };

    if (_isWeb) {
      await _webInsert('tasks', taskData);
    } else {
      await (await database).insert('tasks', taskData);
    }

    return {
      'success': true,
      'message': 'Kayıt başarılı',
      'data': {'id': userId, 'name': name, 'email': email, 'token': token},
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final users = _isWeb
        ? await _webQuery('users', where: 'email = ?', whereArgs: [email])
        : await (await database).query(
            'users',
            where: 'email = ? AND password = ?',
            whereArgs: [email, password],
          );

    if (users.isEmpty) {
      return {'success': false, 'message': 'E-posta veya şifre hatalı'};
    }

    final user = users.first;

    // Verify password manually on web (since web query doesn't do AND)
    if (_isWeb && user['password'] != password) {
      return {'success': false, 'message': 'E-posta veya şifre hatalı'};
    }

    // Update token
    final newToken = 'local_${DateTime.now().millisecondsSinceEpoch}';

    if (_isWeb) {
      await _webUpdate(
        'users',
        {'token': newToken},
        where: 'id = ?',
        whereArgs: [user['id']],
      );
    } else {
      await (await database).update(
        'users',
        {'token': newToken},
        where: 'id = ?',
        whereArgs: [user['id']],
      );
    }

    return {
      'success': true,
      'message': 'Giriş başarılı',
      'data': {
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'token': newToken,
      },
    };
  }

  Future<String?> getSavedToken() async {
    final users = _isWeb
        ? await _webQuery('users', limit: 1)
        : await (await database).query('users', limit: 1);
    if (users.isNotEmpty) {
      return users.first['token'] as String?;
    }
    return null;
  }

  Future<void> saveToken(String token) async {
    // Token already saved during login/register
  }

  Future<void> clearToken() async {
    if (_isWeb) {
      final users = await _webQuery('users');
      for (final user in users) {
        await _webUpdate(
          'users',
          {'token': null},
          where: 'id = ?',
          whereArgs: [user['id']],
        );
      }
    } else {
      await (await database).update('users', {'token': null});
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final users = _isWeb
        ? await _webQuery('users', limit: 1)
        : await (await database).query('users', limit: 1);
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // ==================== STATISTICS OPERATIONS ====================

  Future<Map<String, dynamic>> getStatistics(String token) async {
    final user = await _getUserByTokenWebSafe(token);
    if (user == null) {
      return {'success': false, 'message': 'Kullanıcı bulunamadı'};
    }

    final stats = _isWeb
        ? await _webQuery(
            'statistics',
            where: 'user_id = ?',
            whereArgs: [user['id']],
          )
        : await (await database).query(
            'statistics',
            where: 'user_id = ?',
            whereArgs: [user['id']],
          );

    if (stats.isEmpty) {
      return {'success': false, 'message': 'İstatistik bulunamadı'};
    }

    return {'success': true, 'statistics': stats.first};
  }

  Future<Map<String, dynamic>> updateStatistics(
    String token,
    int totalCorrect,
    int totalWrong,
    int totalPlayTime,
    int streak,
  ) async {
    final user = await _getUserByTokenWebSafe(token);
    if (user == null) {
      return {'success': false, 'message': 'Kullanıcı bulunamadı'};
    }

    final statsData = {
      'total_correct': totalCorrect,
      'total_wrong': totalWrong,
      'total_play_time': totalPlayTime,
      'streak': streak,
    };

    if (_isWeb) {
      await _webUpdate(
        'statistics',
        statsData,
        where: 'user_id = ?',
        whereArgs: [user['id']],
      );
    } else {
      await (await database).update(
        'statistics',
        statsData,
        where: 'user_id = ?',
        whereArgs: [user['id']],
      );
    }

    return {'success': true, 'message': 'İstatistikler başarıyla güncellendi'};
  }

  // ==================== TASKS OPERATIONS ====================

  Future<Map<String, dynamic>> getTasks(String token) async {
    final user = await _getUserByTokenWebSafe(token);
    if (user == null) {
      return {'success': false, 'message': 'Kullanıcı bulunamadı'};
    }

    // Get or create today's task
    var tasks = _isWeb
        ? await _webQuery(
            'tasks',
            where: 'user_id = ?',
            whereArgs: [user['id']],
          )
        : await (await database).query(
            'tasks',
            where: 'user_id = ? AND task_date = ?',
            whereArgs: [user['id'], _todayString()],
          );

    // Filter by date on web manually
    if (_isWeb) {
      tasks = tasks.where((t) => t['task_date'] == _todayString()).toList();
    }

    if (tasks.isEmpty) {
      // Create new task for today
      final taskData = {
        'user_id': user['id'],
        'daily_question_count': 0,
        'daily_play_time': 0,
        'completed': 0,
        'task_date': _todayString(),
      };

      if (_isWeb) {
        await _webInsert('tasks', taskData);
      } else {
        await (await database).insert('tasks', taskData);
      }

      tasks = _isWeb
          ? await _webQuery(
              'tasks',
              where: 'user_id = ?',
              whereArgs: [user['id']],
            )
          : await (await database).query(
              'tasks',
              where: 'user_id = ? AND task_date = ?',
              whereArgs: [user['id'], _todayString()],
            );

      if (_isWeb) {
        tasks = tasks.where((t) => t['task_date'] == _todayString()).toList();
      }
    }

    return {'success': true, 'task': tasks.first};
  }

  Future<Map<String, dynamic>> updateTasks(
    String token,
    int dailyQuestionCount,
    int dailyPlayTime,
    bool completed,
  ) async {
    final user = await _getUserByTokenWebSafe(token);
    if (user == null) {
      return {'success': false, 'message': 'Kullanıcı bulunamadı'};
    }

    // Check if today's task exists
    var existing = _isWeb
        ? await _webQuery(
            'tasks',
            where: 'user_id = ?',
            whereArgs: [user['id']],
          )
        : await (await database).query(
            'tasks',
            where: 'user_id = ? AND task_date = ?',
            whereArgs: [user['id'], _todayString()],
          );

    if (_isWeb) {
      existing = existing
          .where((t) => t['task_date'] == _todayString())
          .toList();
    }

    final taskData = {
      'user_id': user['id'],
      'daily_question_count': dailyQuestionCount,
      'daily_play_time': dailyPlayTime,
      'completed': completed ? 1 : 0,
      'task_date': _todayString(),
    };

    if (existing.isEmpty) {
      if (_isWeb) {
        await _webInsert('tasks', taskData);
      } else {
        await (await database).insert('tasks', taskData);
      }
    } else {
      if (_isWeb) {
        await _webUpdate(
          'tasks',
          taskData,
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      } else {
        await (await database).update(
          'tasks',
          taskData,
          where: 'user_id = ? AND task_date = ?',
          whereArgs: [user['id'], _todayString()],
        );
      }
    }

    return {'success': true, 'message': 'Görevler başarıyla güncellendi'};
  }

  // ==================== WORDS OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getAllWords() async {
    if (_isWeb) return _defaultWordsForWeb();
    return await (await database).query('words');
  }

  Future<List<Map<String, dynamic>>> getWordsByDifficulty(
    int difficulty,
  ) async {
    if (_isWeb) {
      final words = await _defaultWordsForWeb();
      return words.where((w) => w['difficulty'] == difficulty).toList();
    }
    return await (await database).query(
      'words',
      where: 'difficulty = ?',
      whereArgs: [difficulty],
    );
  }

  Future<List<Map<String, dynamic>>> getRandomWords(int count) async {
    final words = _isWeb
        ? await _defaultWordsForWeb()
        : await (await database).query('words');
    words.shuffle();
    return words.take(count).toList();
  }

  // Web fallback - return default words without database
  Future<List<Map<String, dynamic>>> _defaultWordsForWeb() async {
    return [
      {
        'id': 1,
        'english': 'apple',
        'turkish': 'elma',
        'difficulty': 1,
        'category': 'food',
      },
      {
        'id': 2,
        'english': 'book',
        'turkish': 'kitap',
        'difficulty': 1,
        'category': 'objects',
      },
      {
        'id': 3,
        'english': 'car',
        'turkish': 'araba',
        'difficulty': 1,
        'category': 'transport',
      },
      {
        'id': 4,
        'english': 'house',
        'turkish': 'ev',
        'difficulty': 1,
        'category': 'places',
      },
      {
        'id': 5,
        'english': 'water',
        'turkish': 'su',
        'difficulty': 1,
        'category': 'nature',
      },
      {
        'id': 6,
        'english': 'computer',
        'turkish': 'bilgisayar',
        'difficulty': 2,
        'category': 'technology',
      },
      {
        'id': 7,
        'english': 'elephant',
        'turkish': 'fil',
        'difficulty': 2,
        'category': 'animals',
      },
      {
        'id': 8,
        'english': 'beautiful',
        'turkish': 'güzel',
        'difficulty': 2,
        'category': 'adjectives',
      },
      {
        'id': 9,
        'english': 'necessary',
        'turkish': 'gerekli',
        'difficulty': 3,
        'category': 'adjectives',
      },
      {
        'id': 10,
        'english': 'environment',
        'turkish': 'çevre',
        'difficulty': 3,
        'category': 'science',
      },
    ];
  }

  // ==================== QUESTIONS OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getAllQuestions() async {
    if (_isWeb) return _defaultQuestionsForWeb();
    return await (await database).query('questions');
  }

  Future<List<Map<String, dynamic>>> getRandomQuestions(int count) async {
    final questions = _isWeb
        ? await _defaultQuestionsForWeb()
        : await (await database).query('questions');
    questions.shuffle();
    return questions.take(count).toList();
  }

  // Web fallback - return default questions without database
  Future<List<Map<String, dynamic>>> _defaultQuestionsForWeb() async {
    return [
      {
        'id': 1,
        'word_id': 1,
        'question': 'What is the Turkish word for "apple"?',
        'correct_answer': 'elma',
        'options': 'elma,muz,portakal,üzüm',
      },
      {
        'id': 2,
        'word_id': 2,
        'question': 'What is the Turkish word for "book"?',
        'correct_answer': 'kitap',
        'options': 'kitap,defter,kalem,silgi',
      },
      {
        'id': 3,
        'word_id': 3,
        'question': 'What is the Turkish word for "car"?',
        'correct_answer': 'araba',
        'options': 'araba,bisiklet,uçak,gemi',
      },
      {
        'id': 4,
        'word_id': 4,
        'question': 'What is the Turkish word for "house"?',
        'correct_answer': 'ev',
        'options': 'ev,okul,hastane,market',
      },
      {
        'id': 5,
        'word_id': 5,
        'question': 'What is the Turkish word for "water"?',
        'correct_answer': 'su',
        'options': 'su,ateş,hava,toprak',
      },
    ];
  }

  // ==================== HELPER METHODS ====================

  Future<Map<String, dynamic>?> _getUserByToken(
    Database db,
    String token,
  ) async {
    final users = await db.query(
      'users',
      where: 'token = ?',
      whereArgs: [token],
    );
    if (users.isNotEmpty) return users.first;
    return null;
  }

  Future<Map<String, dynamic>?> _getUserByTokenWebSafe(String token) async {
    if (_isWeb) {
      final users = await _webQuery(
        'users',
        where: 'token = ?',
        whereArgs: [token],
      );
      if (users.isNotEmpty) return users.first;
      return null;
    }
    return await _getUserByToken(await database, token);
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
