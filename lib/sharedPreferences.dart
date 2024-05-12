import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {
  static Future<void> saveLoginStatus(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true); // Lưu trạng thái đăng nhập
    prefs.setString('email', email); // Lưu email của người dùng
    // Bạn có thể lưu thêm thông tin khác nếu cần
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ??
        false; // Trả về giá trị mặc định là false nếu không có giá trị
  }
}
