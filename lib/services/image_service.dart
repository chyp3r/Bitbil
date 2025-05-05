import 'package:shared_preferences/shared_preferences.dart';

class ImageStorageService {
  static const String _key = 'saved_images';

  static Future<void> addImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> images = prefs.getStringList(_key) ?? [];
    images.add(path);
    await prefs.setStringList(_key, images);
  }

  static Future<List<String>> getImagePaths() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> removeImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> images = prefs.getStringList(_key) ?? [];
    images.remove(path);
    await prefs.setStringList(_key, images);
  }
}
