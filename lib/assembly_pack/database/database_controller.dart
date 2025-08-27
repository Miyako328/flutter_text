import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseController extends GetxController {
  static const int _VERSION = 1;
  static const String _NAME = 'my.db';
  
  Rx<Database?> database = Rx<Database?>(null);
  RxBool isInitialized = false.obs;
  RxBool isConnecting = false.obs;
  RxString statusMessage = '准备就绪'.obs;
  RxString currentTable = ''.obs;
  
  final List<String> tableList = <String>[].obs;
  final List<String> operationHistory = <String>[].obs;
  final List<Map<String, dynamic>> queryResults = <Map<String, dynamic>>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeDatabase();
  }
  
  Future<void> _initializeDatabase() async {
    try {
      isConnecting.value = true;
      statusMessage.value = '正在初始化数据库...';
      
      final dataBasePath = await getDatabasesPath();
      String path = join(dataBasePath, _NAME);
      
      database.value = await openDatabase(
        path,
        version: _VERSION,
        onCreate: (Database db, int version) async {
          await _createDefaultTables(db);
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          await _upgradeDatabase(db, oldVersion, newVersion);
        },
      );
      
      isInitialized.value = true;
      statusMessage.value = '数据库初始化完成';
      _logOperation('数据库初始化完成');
      
      // 获取表列表
      await _refreshTableList();
      
    } catch (e) {
      statusMessage.value = '数据库初始化失败: $e';
      print('Database initialization error: $e');
      _logOperation('数据库初始化失败: $e');
    } finally {
      isConnecting.value = false;
    }
  }
  
  Future<void> _createDefaultTables(Database db) async {
    try {
      // 创建默认表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      
      await db.execute('''
        CREATE TABLE IF NOT EXISTS settings (
          key TEXT PRIMARY KEY,
          value TEXT,
          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
      ''');
      
      _logOperation('默认表创建完成');
    } catch (e) {
      print('Create default tables error: $e');
      _logOperation('默认表创建失败: $e');
    }
  }
  
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < 2) {
        // 版本1到版本2的升级
        await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
        _logOperation('数据库升级到版本2');
      }
    } catch (e) {
      print('Database upgrade error: $e');
      _logOperation('数据库升级失败: $e');
    }
  }
  
  Future<void> _refreshTableList() async {
    try {
      if (database.value == null) return;
      
      final result = await database.value!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
      );
      
      tableList.clear();
      for (final row in result) {
        tableList.add(row['name'] as String);
      }
      
      _logOperation('表列表刷新完成: ${tableList.length} 个表');
    } catch (e) {
      print('Refresh table list error: $e');
      _logOperation('表列表刷新失败: $e');
    }
  }
  
  Future<bool> isTableExists(String tableName) async {
    try {
      if (database.value == null) return false;
      
      final result = await database.value!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
        [tableName]
      );
      
      return result.isNotEmpty;
    } catch (e) {
      print('Check table exists error: $e');
      return false;
    }
  }
  
  Future<void> createTable(String tableName, String createSql) async {
    try {
      if (database.value == null) {
        statusMessage.value = '数据库未初始化';
        return;
      }
      
      statusMessage.value = '正在创建表: $tableName';
      
      await database.value!.execute(createSql);
      
      statusMessage.value = '表创建成功: $tableName';
      _logOperation('创建表: $tableName');
      
      await _refreshTableList();
      
    } catch (e) {
      statusMessage.value = '表创建失败: $e';
      print('Create table error: $e');
      _logOperation('表创建失败: $tableName - $e');
    }
  }
  
  Future<void> dropTable(String tableName) async {
    try {
      if (database.value == null) {
        statusMessage.value = '数据库未初始化';
        return;
      }
      
      statusMessage.value = '正在删除表: $tableName';
      
      await database.value!.execute('DROP TABLE IF EXISTS $tableName');
      
      statusMessage.value = '表删除成功: $tableName';
      _logOperation('删除表: $tableName');
      
      await _refreshTableList();
      
    } catch (e) {
      statusMessage.value = '表删除失败: $e';
      print('Drop table error: $e');
      _logOperation('表删除失败: $tableName - $e');
    }
  }
  
  Future<void> executeQuery(String sql, [List<dynamic>? arguments]) async {
    try {
      if (database.value == null) {
        statusMessage.value = '数据库未初始化';
        return;
      }
      
      statusMessage.value = '正在执行查询...';
      
      final result = await database.value!.rawQuery(sql, arguments);
      
      queryResults.clear();
      queryResults.addAll(result);
      
      statusMessage.value = '查询执行成功: ${result.length} 条结果';
      _logOperation('执行查询: $sql - ${result.length} 条结果');
      
    } catch (e) {
      statusMessage.value = '查询执行失败: $e';
      print('Execute query error: $e');
      _logOperation('查询执行失败: $sql - $e');
    }
  }
  
  Future<void> executeUpdate(String sql, [List<dynamic>? arguments]) async {
    try {
      if (database.value == null) {
        statusMessage.value = '数据库未初始化';
        return;
      }
      
      statusMessage.value = '正在执行更新...';
      
      final result = await database.value!.rawUpdate(sql, arguments);
      
      statusMessage.value = '更新执行成功: 影响 $result 行';
      _logOperation('执行更新: $sql - 影响 $result 行');
      
    } catch (e) {
      statusMessage.value = '更新执行失败: $e';
      print('Execute update error: $e');
      _logOperation('更新执行失败: $sql - $e');
    }
  }
  
  Future<void> insertData(String tableName, Map<String, dynamic> data) async {
    try {
      if (database.value == null) {
        statusMessage.value = '数据库未初始化';
        return;
      }
      
      statusMessage.value = '正在插入数据...';
      
      final id = await database.value!.insert(tableName, data);
      
      statusMessage.value = '数据插入成功: ID $id';
      _logOperation('插入数据: $tableName - ID $id');
      
    } catch (e) {
      statusMessage.value = '数据插入失败: $e';
      print('Insert data error: $e');
      _logOperation('数据插入失败: $tableName - $e');
    }
  }
  
  Future<void> updateData(String tableName, Map<String, dynamic> data, String whereClause, [List<dynamic>? whereArgs]) async {
    try {
      if (database.value == null) {
        statusMessage.value = '数据库未初始化';
        return;
      }
      
      statusMessage.value = '正在更新数据...';
      
      final count = await database.value!.update(tableName, data, where: whereClause, whereArgs: whereArgs);
      
      statusMessage.value = '数据更新成功: 影响 $count 行';
      _logOperation('更新数据: $tableName - 影响 $count 行');
      
    } catch (e) {
      statusMessage.value = '数据更新失败: $e';
      print('Update data error: $e');
      _logOperation('数据更新失败: $tableName - $e');
    }
  }
  
  Future<void> deleteData(String tableName, String whereClause, [List<dynamic>? whereArgs]) async {
    try {
      if (database.value == null) {
        statusMessage.value = '数据库未初始化';
        return;
      }
      
      statusMessage.value = '正在删除数据...';
      
      final count = await database.value!.delete(tableName, where: whereClause, whereArgs: whereArgs);
      
      statusMessage.value = '数据删除成功: 影响 $count 行';
      _logOperation('删除数据: $tableName - 影响 $count 行');
      
    } catch (e) {
      statusMessage.value = '数据删除失败: $e';
      print('Delete data error: $e');
      _logOperation('数据删除失败: $tableName - $e');
    }
  }
  
  void _logOperation(String operation) {
    final timestamp = DateTime.now().toString();
    final logEntry = '$timestamp: $operation';
    operationHistory.add(logEntry);
    
    // 保持历史记录在合理范围内
    if (operationHistory.length > 100) {
      operationHistory.removeAt(0);
    }
  }
  
  void clearQueryResults() {
    queryResults.clear();
    statusMessage.value = '查询结果已清除';
  }
  
  void clearOperationHistory() {
    operationHistory.clear();
    statusMessage.value = '操作历史已清除';
  }
  
  void setCurrentTable(String tableName) {
    currentTable.value = tableName;
    statusMessage.value = '当前表: $tableName';
  }
  
  Future<void> closeDatabase() async {
    try {
      if (database.value != null) {
        await database.value!.close();
        database.value = null;
        isInitialized.value = false;
        statusMessage.value = '数据库已关闭';
        _logOperation('数据库已关闭');
      }
    } catch (e) {
      print('Close database error: $e');
      _logOperation('数据库关闭失败: $e');
    }
  }
  
  @override
  void onClose() {
    closeDatabase();
    super.onClose();
  }
  
  bool get hasDatabase => database.value != null;
  bool get hasTables => tableList.isNotEmpty;
  bool get hasQueryResults => queryResults.isNotEmpty;
  bool get hasOperationHistory => operationHistory.isNotEmpty;
  int get tableCount => tableList.length;
  int get queryResultCount => queryResults.length;
  int get operationCount => operationHistory.length;
  String get databaseStatus => isInitialized.value ? '已连接' : '未连接';
  String get currentTableInfo => currentTable.value.isNotEmpty ? '当前表: ${currentTable.value}' : '未选择表';
}
