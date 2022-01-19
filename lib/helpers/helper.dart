import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Helper {
  static logout() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
    await prefs.remove('isLoggedIn');
  }
}
