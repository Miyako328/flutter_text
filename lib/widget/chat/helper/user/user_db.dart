import 'package:flutter_text/widget/chat/helper/global/event.dart';
import 'package:flutter_text/widget/chat/helper/user/user.dart';
import 'package:mysql1/mysql1.dart';
import 'package:self_utils/utils/datetime_utils.dart';
import 'package:self_utils/utils/log_utils.dart';

class PostgresUser {
  /// 表名
  static String name = 'user_db';

  static String columnId = 'id';
  static String columnName = 'name';
  static String columnImage = 'image';
  static String columnCreateTime = 'createTime';
  static String columnUpdateTime = 'updateTime';
  static String columnPasswordHash = 'passwordHash';

  static MySqlConnection? connection;
  static bool _isOpen = false;

  static Future<void> init() async {
    if (_isOpen && connection != null) {
      return;
    }

    final ConnectionSettings settings = ConnectionSettings(
      host: DbGlobal.ip,
      port: DbGlobal.port,
      user: DbGlobal.username,
      password: DbGlobal.password,
      db: DbGlobal.database,
      timeout: const Duration(seconds: 5),
    );

    connection = await MySqlConnection.connect(settings);
    _isOpen = true;
    Log.info('连接 MySQL 数据库');

    try {
      await connection!.query('''
        CREATE TABLE IF NOT EXISTS `$name` (
          `$columnId` INT AUTO_INCREMENT PRIMARY KEY,
          `$columnName` TEXT NOT NULL,
          `$columnCreateTime` BIGINT NOT NULL,
          `$columnUpdateTime` BIGINT NOT NULL,
          `$columnImage` TEXT NOT NULL,
          `$columnPasswordHash` TEXT
        ) DEFAULT CHARSET=utf8mb4;
      ''');
      await _ensureColumn(columnPasswordHash, 'TEXT');
    } catch (e, s) {
      _isOpen = false;
      Log.error(e, stackTrace: s);
      rethrow;
    }
  }

  static Future<void> _ensureColumn(String column, String type) async {
    final Results result = await connection!.query(
      '''
      SELECT COUNT(*)
      FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = ?
        AND TABLE_NAME = ?
        AND COLUMN_NAME = ?
      ''',
      <Object?>[DbGlobal.database, name, column],
    );
    if (result.first[0] == 0) {
      await connection!.query('ALTER TABLE `$name` ADD COLUMN `$column` $type');
    }
  }

  static Future<MySqlConnection> _ensureConnection() async {
    if (!_isOpen || connection == null) {
      await init();
    }
    return connection!;
  }

  static Future<int> getMapList() async {
    final MySqlConnection db = await _ensureConnection();
    final Results result = await db.query('SELECT COUNT(*) FROM `$name`');
    return result.first[0] as int;
  }

  // 添加数据
  static Future<int> addUser(User user) async {
    final MySqlConnection db = await _ensureConnection();
    final Results result = await db.query(
      '''
      INSERT INTO `$name`
      (`$columnName`, `$columnCreateTime`, `$columnUpdateTime`,
       `$columnImage`, `$columnPasswordHash`)
      VALUES (?, ?, ?, ?, ?)
      ''',
      <Object?>[
        user.name,
        user.createTime,
        user.updateTime,
        user.image,
        user.passwordHash,
      ],
    );
    return result.insertId ?? 0;
  }

  static Future<User?> findByName(String nameValue) async {
    final MySqlConnection db = await _ensureConnection();
    final Results result = await db.query(
      _selectUserSql('WHERE `$columnName` = ? LIMIT 1'),
      <Object?>[nameValue],
    );
    if (result.isEmpty) {
      return null;
    }
    return _userFromRow(result.first);
  }

  static Future<User?> loginWithPassword({
    required String nameValue,
    required String passwordHash,
  }) async {
    final User? user = await findByName(nameValue);
    if (user == null || user.passwordHash != passwordHash) {
      return null;
    }
    user.updateTime = DateTimeHelper.getLocalTimeStamp() ~/ 1000;
    await updateUser(user);
    return user;
  }

  static Future<User?> checkUser(User user) async {
    final MySqlConnection db = await _ensureConnection();
    final Results result = await db.query(
      _selectUserSql('WHERE `$columnId` = ? LIMIT 1'),
      <Object?>[user.id],
    );

    if (result.isEmpty) {
      return null;
    }

    final User hasUser = _userFromRow(result.first);
    final bool passwordMatches = user.passwordHash != null &&
        user.passwordHash!.isNotEmpty &&
        user.passwordHash == hasUser.passwordHash;
    final bool legacyNameMatches =
        user.passwordHash == null && hasUser.name == user.name;
    if (passwordMatches || legacyNameMatches) {
      hasUser.updateTime = DateTimeHelper.getLocalTimeStamp() ~/ 1000;
      await updateUser(hasUser);
      return hasUser;
    }
    return null;
  }

  // 通过 id 查找 user
  static Future<User?> getOneWithId(int id) async {
    final MySqlConnection db = await _ensureConnection();
    final Results result = await db.query(
      _selectUserSql('WHERE `$columnId` = ? LIMIT 1'),
      <Object?>[id],
    );

    if (result.isEmpty) {
      return null;
    }
    return _userFromRow(result.first);
  }

  // 更新数据
  static Future<int> updateUser(User user) async {
    final MySqlConnection db = await _ensureConnection();
    final Results result = await db.query(
      '''
      UPDATE `$name`
      SET `$columnName` = ?,
          `$columnImage` = ?,
          `$columnCreateTime` = ?,
          `$columnUpdateTime` = ?,
          `$columnPasswordHash` = ?
      WHERE `$columnId` = ?
      ''',
      <Object?>[
        user.name,
        user.image,
        user.createTime,
        user.updateTime,
        user.passwordHash,
        user.id,
      ],
    );
    return result.affectedRows ?? 0;
  }

  static String _selectUserSql(String whereSql) {
    return '''
      SELECT `$columnId`, `$columnName`, `$columnImage`,
             `$columnCreateTime`, `$columnUpdateTime`, `$columnPasswordHash`
      FROM `$name`
      $whereSql
    ''';
  }

  static User _userFromRow(ResultRow row) {
    return User(
      id: row[0] as int?,
      name: row[1] as String?,
      image: row[2] as String?,
      createTime: row[3] as int?,
      updateTime: row[4] as int?,
      passwordHash: row[5] as String?,
    );
  }
}
