import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'model/qr_code.dart';

class QrCodeDatabase {
  static final QrCodeDatabase instance = QrCodeDatabase._init();

  static Database? _database;

  QrCodeDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('$tableQrCode.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableQrCode ( 
  ${QRcodeFields.id} $idType, 
  ${QRcodeFields.qrCodeResult} $textType,
  ${QRcodeFields.description} $textType,
  ${QRcodeFields.time} $textType
  )
''');
  }

  Future<QRCode> create(QRCode note) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    final id = await db.insert(tableQrCode, note.toJson());
    return note.copy(id: id);
  }

  Future<QRCode?> readQRCode(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableQrCode,
      columns: QRcodeFields.values,
      where: '${QRcodeFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return QRCode.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<List<QRCode>> readAllQRCode() async {
    final db = await instance.database;

    const orderBy = '${QRcodeFields.time} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableQrCode, orderBy: orderBy);

    return result.map((json) => QRCode.fromJson(json)).toList();
  }

  Future<int> update(QRCode note) async {
    final db = await instance.database;

    return db.update(
      tableQrCode,
      note.toJson(),
      where: '${QRcodeFields.id} = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableQrCode,
      where: '${QRcodeFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
