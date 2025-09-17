import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_news/component/flutterToast.dart';
import 'package:flutter_news/news/webViewScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../component/api/dio.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final TextEditingController _textController = TextEditingController();
  final api = ApiService();
  final formatter = DateFormat('yyyy-MM-dd');
  final endDate = DateTime.now();
  late final startDate = endDate.subtract(const Duration(days: 3));
  String _selectedKeyword = "경제";
  late final newsApiKey = dotenv.env['NEWS_API_KEY'];
  final List<String> labels = ['경제', '엔터', '스포츠', '쇼핑', '여행', 'IT', '지식', '건강'];
  List<Map<String, dynamic>> newsList = [];
  bool isLoading = true;

  Future<void> requestNews({required String keyword, required String startDate, required String endDate}) async {
    setState(() => isLoading = true);

    try {
      final response = await api.request(
        endpoint: '/everything',
        method: HttpMethod.GET,
        queryParams: {'q': keyword, 'language': 'ko', "from": startDate, "to": endDate, 'apiKey': newsApiKey},
      );

      setState(() {
        newsList = (response.data["articles"] as List).map((news) => {"title": news["title"], "url": news["url"]}).toList();
      });
    } catch (e) {
      print("Error $e");
      showToast(message: "에러가 발생했습니다.\n잠시 후 다시 시도해 주세요");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    requestNews(keyword: _selectedKeyword, startDate: formatter.format(startDate), endDate: formatter.format(endDate));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        spacing: 20.h,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            spacing: 10.w,
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(hintText: '검색어를 입력하세요', border: OutlineInputBorder()),
                ),
              ),

              ElevatedButton(
                onPressed: () async {
                  if (_textController.text != "") {
                    _selectedKeyword = "";

                    await requestNews(
                      keyword: _textController.text,
                      startDate: formatter.format(startDate),
                      endDate: formatter.format(endDate),
                    );

                    _textController.clear();
                  } else {
                    showToast(message: "검색어를 입력해주세요");
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text("검색", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                flex: 7,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 15.w,
                    children: labels.map((label) {
                      bool isSelected = label == _selectedKeyword;
                      return InkWell(
                        onTap: () async {
                          setState(() => _selectedKeyword = label);

                          await requestNews(
                            keyword: _selectedKeyword,
                            startDate: formatter.format(startDate),
                            endDate: formatter.format(endDate),
                          );
                        },
                        child: Container(
                          width: 50.w,
                          height: 50.h,
                          decoration: BoxDecoration(color: isSelected ? Colors.blue : Colors.grey, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Expanded(
                flex: 2,
                child: IconButton(onPressed: () {}, icon: Icon(Icons.tune)),
              ),
            ],
          ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : newsList.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: ListView.builder(
                      itemCount: newsList.length,
                      itemBuilder: (context, index) {
                        final title = newsList[index]['title'];
                        final url = newsList[index]['url'];
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 5.h),
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (url != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => WebViewScreen(url: url)),
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  padding: EdgeInsets.zero,
                                ),
                                child: Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, height: 1.0),
                                ),
                              ),
                              Divider(height: 1, color: Colors.grey),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                : Center(child: Text("등록된 기사가 없습니다")),
          ),
        ],
      ),
    );
  }
}
