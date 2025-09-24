import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../component/api/dio.dart';
import '../component/flutterToast.dart';
import '../models/news/newsModel.dart';

class NewsProvider extends ChangeNotifier {
  List<News> newsList = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  final api = ApiService();
  late final newsApiKey = dotenv.env['NEWS_API_KEY'];
  String selectedKeyword = "경제";

  Future<void> fetchNews({required String keyword, required String startDate, required String endDate, bool reset = false}) async {
    if (!reset && (isLoading || !hasMore)) return;

    isLoading = true;
    notifyListeners();

    if (reset) {
      newsList.clear();
      currentPage = 1;
      hasMore = true;
    }

    selectedKeyword = keyword;
    notifyListeners();

    try {
      final response = await api.request(
        endpoint: '/everything',
        method: HttpMethod.GET,
        queryParams: {
          'q': keyword,
          'language': 'ko',
          'page': currentPage,
          'pageSize': 20,
          'from': startDate,
          'to': endDate,
          'apiKey': newsApiKey,
        },
      );

      final List articles = response.data["articles"] ?? [];
      final int totalResults = response.data["totalResults"];

      newsList.addAll(articles.map((json) => News.fromJson({"title": json["title"], "url": json["url"]})));

      currentPage++;
      if (newsList.length >= totalResults || newsList.length >= 100) {
        hasMore = false;
      }
    } catch (e) {
      print("Error: $e");
      showToast(message: "에러가 발생했습니다.\n잠시 후 다시 시도해 주세요");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
