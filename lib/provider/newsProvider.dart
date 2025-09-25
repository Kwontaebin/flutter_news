import 'package:dio/dio.dart';
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

  Future<void> fetchNews({required String keyword, required String startDate, bool reset = false}) async {
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
          'to': DateTime.now(),
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
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      if (statusCode == 400) return showToast(message: "키워드 입력이 잘못되었습니다");
      if (statusCode == 429) return showToast(message: "요청 횟수를 초과했습니다. 잠시후 다시 시도해주세요");

      return;
    } catch (e) {
      print("기타 에러: $e");

      return;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
