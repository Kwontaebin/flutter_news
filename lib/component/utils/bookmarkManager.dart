import 'package:flutter_news/component/flutterToast.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BookmarkManager {
  final Box _box;

  BookmarkManager({required String boxName}) : _box = Hive.box(boxName);

  List<Map<String, String>> getBookmarks({String key = 'bookMarkNews'}) {
    final data = _box.get(key, defaultValue: []);
    return List<Map<String, String>>.from(data.map((item) => Map<String, String>.from(item)));
  }

  void addBookmark(Map<String, String> news, {String key = 'bookMarkNews'}) {
    final List<Map<String, String>> current = getBookmarks(key: key);

    final exists = current.any((item) => item['title'] == news['title'] && item['url'] == news['url']);

    if (!exists) {
      current.add(news);
      _box.put(key, current);
    } else {
      showToast(message: '이미 북마크에 추가된 데이터입니다');
    }
  }

  void removeBookmark(int index, {String key = 'bookMarkNews'}) {
    final List<Map<String, String>> current = getBookmarks(key: key);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      _box.put(key, current);
    }
  }

  // 북마크 전체 삭제
  void clearBookmarks({String key = 'bookMarkNews'}) {
    _box.put(key, []);
  }
}
