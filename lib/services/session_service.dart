import 'package:hive/hive.dart';

/// Lightweight session store backed by Hive.
///
/// Only non-sensitive identity fields are kept (id, name, email).
/// Passwords are **never** stored.
class SessionService {
  static const String _boxName = 'session';
  static const String _keyUserId = 'userId';
  static const String _keyName = 'userName';
  static const String _keyEmail = 'userEmail';

  static Box get _box => Hive.box(_boxName);

  /// Initialise the session box (call once in main before runApp).
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  // --- Getters -------------------------------------------------------------

  static bool get isLoggedIn => _box.get(_keyUserId) != null;

  static int? get userId => _box.get(_keyUserId) as int?;

  static String? get userName => _box.get(_keyName) as String?;

  static String? get userEmail => _box.get(_keyEmail) as String?;

  // --- Mutators ------------------------------------------------------------

  static Future<void> saveUser({
    required int id,
    required String name,
    required String email,
  }) async {
    await _box.put(_keyUserId, id);
    await _box.put(_keyName, name);
    await _box.put(_keyEmail, email);
  }

  static Future<void> logout() async {
    await _box.delete(_keyUserId);
    await _box.delete(_keyName);
    await _box.delete(_keyEmail);
  }
}
