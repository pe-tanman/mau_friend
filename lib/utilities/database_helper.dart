import 'package:flutter/services.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fast_csv/fast_csv.dart' as fast_csv;
import 'dart:math' as math;
import 'package:path/path.dart';

class MyLocationDatabaseHelper {
  static final MyLocationDatabaseHelper _instance =
      MyLocationDatabaseHelper._internal();

  factory MyLocationDatabaseHelper() {
    return _instance;
  }

  MyLocationDatabaseHelper._internal();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initMyLocationDatabase();

    return _database;
  }

  Future<Database> initMyLocationDatabase() async {
    String path = join(await getDatabasesPath(), "my_location_database.db");
    var db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE my_location_table (
            name TEXT,
            icon TEXT,
            latitude REAL,
            longitude REAL,
            radius INTEGER,
            PRIMARY KEY(name)
          )
        ''');
      },
    );
    return db;
  }

  Future<void> insertData(
    String name,
    String? icon,
    LatLng? coordinates,
    int? radius,
  ) async {
    final Database? db = await database;

    final prevData = await getData(name);

    final _icon = icon ?? prevData!['icon'];
    final _coordinates = coordinates ?? LatLng(
      prevData!['latitude'],
      prevData!['longitude']
    );
    final _radius = radius ?? prevData!['radius'];

    Map<String, dynamic> data = {
      'name': name,
      'icon': _icon,
      'latitude': _coordinates.latitude,
      'longitude': _coordinates.longitude,
      'radius': _radius,
    };

    await db!.insert(
      'my_location_table',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getData(String name) async {
    final Database? db = await database;
    List<Map<String, dynamic>> maps = await db!.query(
      'my_location_table',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    final Database? db = await database;
    return await db!.query('my_location_table');
  }

  Future<int> deleteData(String name) async {
    final Database? db = await database;
    return await db!.delete('my_location_table', where: 'name = ?', whereArgs: [name]);
  }

  Future<void> deleteAllData() async {
    final Database? db = await database;
    db!.delete('question_table');
    db!.execute('DROP TABLE question_table');
  }
}

class NotificationDatabaseHelper {
  static final NotificationDatabaseHelper _instance =
      NotificationDatabaseHelper._internal();

  factory NotificationDatabaseHelper() {
    return _instance;
  }

  NotificationDatabaseHelper._internal();

  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await initNotificationDatabase();

    return _database;
  }

  Future<Database> initNotificationDatabase() async {
    String path = join(await getDatabasesPath(), "notification_database.db");
    var db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE notification_table (
            timestamp TEXT,
            message TEXT,
            iconLink TEXT,
            PRIMARY KEY(timestamp)
          )
        ''');
      },
    );
    return db;
  }

  Future<void> insertData(
    String timestamp,
    String message,
    String iconLink,
  ) async {
    final Database? db = await database;

    Map<String, dynamic> data = {
      'timestamp': timestamp,
      'message': message,
      'iconLink': iconLink,
    };

    // Check if the data already exists
    await db!.insert(
      'notification_table',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    final Database? db = await database;
    return await db!.query('notification_table');
  }
}
