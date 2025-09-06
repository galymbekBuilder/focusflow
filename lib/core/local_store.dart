import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class LocalStore {
  LocalStore(this._prefs);
  final SharedPreferences _prefs;
  static Future<LocalStore> create() async => LocalStore(await SharedPreferences.getInstance());
  Future<List<dynamic>> getList(String key) async { final s = _prefs.getString(key); if (s == null) return []; try { return jsonDecode(s) as List<dynamic>; } catch (_) { return []; } }
  Future<void> setList(String key, List<Object> value) async => _prefs.setString(key, jsonEncode(value));
}
