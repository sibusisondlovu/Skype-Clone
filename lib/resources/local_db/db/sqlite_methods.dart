import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:skype_clone/models/log.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:skype_clone/resources/local_db/interface/log_interface.dart';

class SqliteMethods implements LogInterface {
  Database _db;

  //database name
  String dbName = 'somename';

  // table name
  String tableName = 'CallLogs';

  //columns
  String id = 'log_id';
  String callerName = 'caller_name';
  String callerPic = 'caller_pic';
  String receiverName = 'receiver_name';
  String receiverPic = 'receiver_pic';
  String callStatus = 'call_status';
  String timestamp = 'timestamp';

  Future<Database> get db async {
    if (_db != null) {
      // print("db is not null");
      return _db;
    }
    print("db was null, now awaiting it");
    _db = await init();
    return _db;
  }

  @override
  openDb(_dbName) => dbName = _dbName;

  @override
  init() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, dbName);
    var db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return db;
  }

  _onCreate(Database db, int version) async {
    String createTableQuery =
        "CREATE TABLE $tableName ($id INTEGER PRIMARY KEY, $callerName TEXT, $callerPic TEXT, $receiverName TEXT, $receiverPic TEXT, $callStatus TEXT, $timestamp TEXT)";

    await db.execute(createTableQuery);
    print("creating table");
  }

  @override
  addLogs(Log log) async {
    var dbClient = await db;
    await dbClient.insert(tableName, log.toMap(log));
  }

  updateLogs(Log log) async {
    var dbClient = await db;

    await dbClient.update(tableName, log.toMap(log),
        where: '$id = ?', whereArgs: [log.logId]);
  }

  @override
  Future<List<Log>> getLogs() async {
    try {
      var dbClient = await db;
      List<Map> maps = await dbClient.query(tableName, columns: [
        id,
        callerName,
        callerPic,
        receiverName,
        receiverPic,
        callStatus,
        timestamp,
      ]);
      //List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
      List<Log> logList = [];
      if (maps.length > 0) {
        for (int i = 0; i < maps.length; i++) {
          var logMap = maps[i];
          logList.insert(0, Log.fromMap(logMap));
        }
      }
      return logList;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  deleteLogs(int logId) async {
    var client = await db;
    return await client.delete(tableName, where: '$id = ?', whereArgs: [logId]);
  }

  @override
  close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
