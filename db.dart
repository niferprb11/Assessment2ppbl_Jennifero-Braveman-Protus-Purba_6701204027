import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static DatabaseFactory? _databaseFactory;
  static Database? _database;
  static const String dbName = 'opangatimin.db';

  // Initialize the databaseFactory
  static void initDatabaseFactory() {
    if (_databaseFactory == null) {
      _databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> get database async {
    // Ensure databaseFactory is initialized
    initDatabaseFactory();

    if (_database == null) {
      _database = await initDatabase();
    }

    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), dbName);

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tukang_ojek (
        id INTEGER PRIMARY KEY,
        nama TEXT,
        nopol TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE transaksi (
        id INTEGER PRIMARY KEY,
        tukang_ojek_id INTEGER,
        harga INTEGER,
        timestamp TEXT,
        FOREIGN KEY (tukang_ojek_id) REFERENCES tukang_ojek (id)
      )
    ''');
  }

  Future<int> insertTukangOjek(String nama, String nopol) async {
    try {
      Database db = await database;
      return await db.insert('tukang_ojek', {'nama': nama, 'nopol': nopol});
    } catch (e) {
      print('Error inserting Tukang Ojek: $e');
      rethrow; // Rethrow the error after logging
    }
  }

  Future<int> insertTransaksi(int tukangOjekId, int harga) async {
    try {
      Database db = await database;
      DateTime timestamp = DateTime.now();
      String timestampString = timestamp.toIso8601String();

      return await db.insert('transaksi', {'tukang_ojek_id': tukangOjekId, 'harga': harga, 'timestamp': timestampString});
    } catch (e) {
      print('Error inserting Transaksi: $e');
      rethrow; // Rethrow the error after logging
    }
  }

  Future<List<Map<String, dynamic>>> getTukangOjekStats({String sortField = 'nama'}) async {
    try {
      Database db = await database;

      String orderBy;
      if (sortField == 'orderCount') {
        orderBy = 'jumlahOrder DESC';
      } else {
        orderBy = sortField;
      }

      return await db.rawQuery('''
        SELECT tukang_ojek.id, tukang_ojek.nama, tukang_ojek.nopol, 
        COUNT(transaksi.id) AS jumlahOrder, 
        SUM(transaksi.harga) AS omzet
        FROM tukang_ojek
        LEFT JOIN transaksi ON tukang_ojek.id = transaksi.tukang_ojek_id
        GROUP BY tukang_ojek.id
        ORDER BY $orderBy
      ''');
    } catch (e) {
      print('Error fetching Tukang Ojek stats: $e');
      rethrow; // Rethrow the error after logging
    }
  }
}