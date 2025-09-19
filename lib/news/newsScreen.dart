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
  final TextEditingController _searchTextController = TextEditingController();
  final TextEditingController _plusTextController = TextEditingController();
  final api = ApiService();
  final formatter = DateFormat('yyyy-MM-dd');
  final endDate = DateTime.now();
  late final DateTime startDate = DateTime.now().subtract(const Duration(days: 3));
  late final newsApiKey = dotenv.env['NEWS_API_KEY'];
  String _selectedKeyword = "경제";
  final List<String> labels = ['경제', '엔터', '스포츠', '여행', 'IT', '지식', '건강', '음식'];
  late final List<String> moreLabels = [...labels, '패션', '음악', '영화', '쇼핑'];
  List<Map<String, dynamic>> newsList = [];
  bool isLoading = false;
  List plusShowKeyword = [];

  final smallButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
  );

  @override
  void initState() {
    super.initState();
    fetchNews(keyword: _selectedKeyword, startDate: formatter.format(startDate), endDate: formatter.format(endDate));
  }

  Future<void> fetchNews({required String keyword, required String startDate, required String endDate}) async {
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
  void dispose() {
    _searchTextController.dispose();
    _plusTextController.dispose();
    super.dispose();
  }

  Widget _buildSearchBar() {
    return Row(
      spacing: 10.w,
      children: [
        Expanded(
          child: TextField(
            controller: _searchTextController,
            decoration: InputDecoration(hintText: '검색어를 입력하세요', border: OutlineInputBorder()),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_searchTextController.text.isNotEmpty) {
              _selectedKeyword = "";
              await fetchNews(
                keyword: _searchTextController.text,
                startDate: formatter.format(startDate),
                endDate: formatter.format(endDate),
              );
              _searchTextController.clear();
              FocusScope.of(context).unfocus();
            } else {
              showToast(message: "검색어를 입력해주세요");
            }
          },
          style: smallButton,
          child: Text("검색", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildKeywordList() {
    return Row(
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
                    await fetchNews(keyword: _selectedKeyword, startDate: formatter.format(startDate), endDate: formatter.format(endDate));
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
          child: IconButton(onPressed: () => _showFilterSheet(context), icon: Icon(Icons.tune)),
        ),
      ],
    );
  }

  Widget _buildNewsList() {
    return isLoading
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
                            Navigator.push(context, MaterialPageRoute(builder: (_) => WebViewScreen(url: url)));
                          }
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.black, padding: EdgeInsets.zero),
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
        : Center(child: Text("등록된 기사가 없습니다"));
  }

  void _showFilterSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.2,
            maxChildSize: 0.6,
            expand: false,
            builder: (context, scrollController) {
              return StatefulBuilder(
                builder: (context, modalSetState) {
                  return Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    ),
                    child: Column(
                      spacing: 20.h,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: SizedBox(
                            width: 40.w,
                            height: 5.h,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(10.r))),
                            ),
                          ),
                        ),
                        Text(
                          "필터 선택",
                          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          spacing: 10.w,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _plusTextController,
                                decoration: InputDecoration(hintText: '보고싶은 검색어를 입력하세요', border: OutlineInputBorder()),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (_plusTextController.text.isEmpty) {
                                  showToast(message: "검색어를 입력해주세요");
                                  return;
                                }
                                if (!plusShowKeyword.contains(_plusTextController.text)) {
                                  modalSetState(() => plusShowKeyword.add(_plusTextController.text));
                                } else {
                                  showToast(message: "이미 추가된 키워드입니다");
                                }
                                _plusTextController.clear();
                                FocusScope.of(context).unfocus();
                              },
                              style: smallButton,
                              child: Text("추가", style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: moreLabels.map((label) {
                            return StatefulBuilder(
                              builder: (context, chipSetState) {
                                final isSelected = plusShowKeyword.contains(label);
                                return FilterChip(
                                  label: Text(label),
                                  selected: isSelected,
                                  selectedColor: Colors.blue,
                                  checkmarkColor: Colors.white,
                                  backgroundColor: Colors.grey[200],
                                  onSelected: (selected) {
                                    chipSetState(() {
                                      if (isSelected) {
                                        plusShowKeyword.remove(label);
                                      } else {
                                        plusShowKeyword.add(label);
                                      }
                                    });
                                  },
                                );
                              },
                            );
                          }).toList(),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (plusShowKeyword.isEmpty) {
                              showToast(message: "키워드를 선택해주세요");
                              return;
                            }
                            _selectedKeyword = "";
                            await fetchNews(
                              keyword: plusShowKeyword.join(" OR "),
                              startDate: formatter.format(startDate),
                              endDate: formatter.format(endDate),
                            );
                            Navigator.pop(context);
                          },
                          child: const Text("검색"),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
    plusShowKeyword.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Column(
        spacing: 20.h,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildSearchBar(),
          _buildKeywordList(),
          Expanded(child: _buildNewsList()),
        ],
      ),
    );
  }
}
