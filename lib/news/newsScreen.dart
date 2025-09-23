import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_news/component/flutterToast.dart';
import 'package:flutter_news/component/utils/webViewScreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../component/api/dio.dart';
import '../component/utils/bookmarkManager.dart';
import '../component/utils/shareManager.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final TextEditingController _searchTextController = TextEditingController();
  final TextEditingController _plusTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final api = ApiService();
  final formatter = DateFormat('yyyy-MM-dd');
  final endDate = DateTime.now();
  late final DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  late final newsApiKey = dotenv.env['NEWS_API_KEY'];
  String _selectedKeyword = "경제";
  final List<String> labels = ['경제', '엔터', '스포츠', '여행', 'IT', '지식', '건강', '음식'];
  late final List<String> moreLabels = [...labels, '패션', '음악', '영화', '쇼핑'];
  List<Map<String, dynamic>> newsList = [];
  bool isLoading = false;
  List plusShowKeyword = [];
  int currentPage = 1;
  bool hasMore = true; // 데이터 호출 여부
  String currentKeyword = "";

  final smallButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
  );

  @override
  void initState() {
    super.initState();
    fetchNews(keyword: _selectedKeyword, page: currentPage, startDate: formatter.format(startDate), endDate: formatter.format(endDate));

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!isLoading && hasMore && currentKeyword.isNotEmpty) {
        fetchNews(keyword: currentKeyword, page: currentPage, startDate: formatter.format(startDate), endDate: formatter.format(endDate));
      }
    }
  }

  Future<void> fetchNews({
    required String keyword,
    required int page,
    required String startDate,
    required String endDate,
    bool reset = false,
  }) async {
    if (!reset && (isLoading || !hasMore)) return;

    if (reset) {
      newsList = [];
      currentPage = 1;
      hasMore = true;
      _scrollController.jumpTo(0);
      page = 1; // reset이면 page를 1로 강제
    }

    setState(() => isLoading = true);

    try {
      final response = await api.request(
        endpoint: '/everything',
        method: HttpMethod.GET,
        queryParams: {
          'q': keyword,
          'language': 'ko',
          'page': page, // reset 시에도 1로 호출
          'pageSize': 20,
          'from': startDate,
          'to': endDate,
          'apiKey': newsApiKey,
        },
      );

      final List articles = response.data["articles"] ?? [];
      final int totalResults = response.data["totalResults"];

      setState(() {
        currentKeyword = keyword;
        currentPage = page + 1; // 다음 호출을 위해 page 증가

        newsList.addAll(articles.map((news) => {"title": news["title"], "url": news["url"]}));

        if (newsList.length >= totalResults || newsList.length >= 100) {
          hasMore = false;
        }
      });
    } catch (e) {
      print("Error: $e");
      showToast(message: "에러가 발생했습니다.\n잠시 후 다시 시도해 주세요");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _plusTextController.dispose();
    _scrollController.dispose();
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
                page: currentPage,
                startDate: formatter.format(startDate),
                endDate: formatter.format(endDate),
                reset: true, // 기존 뉴스 초기화
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
                    await fetchNews(
                      keyword: _selectedKeyword,
                      page: currentPage,
                      startDate: formatter.format(startDate),
                      endDate: formatter.format(endDate),
                      reset: true, // 기존 뉴스 초기화
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
          child: IconButton(onPressed: () => _showFilterSheet(context), icon: Icon(Icons.tune)),
        ),
      ],
    );
  }

  Widget _buildNewsList() {
    if (newsList.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: SlidableAutoCloseBehavior(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: newsList.length + (isLoading ? 1 : 0), // 마지막에 로딩 인디케이터 추가
          itemBuilder: (context, index) {
            if (index < newsList.length) {
              final title = newsList[index]['title'];
              final url = newsList[index]['url'];
              final theme = Theme.of(context);

              final bookmarkManager = BookmarkManager(boxName: 'newsBox');
              return Slidable(
                key: ValueKey(index),

                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        shareContent("공유", subject: url);
                      },
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      icon: Icons.share,
                      label: '공유',
                    ),

                    SlidableAction(
                      onPressed: (context) {
                        bookmarkManager.addBookmark({"title": title, "url": url});
                      },
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.bookmark,
                      label: '북마크',
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        if (url != null) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => WebViewScreen(url: url)));
                        }
                      },
                      style: TextButton.styleFrom(foregroundColor: theme.textTheme.bodyMedium?.color, padding: EdgeInsets.zero),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          height: 1.0,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Center(child: CircularProgressIndicator()),
              ); // 20개의 데이터를 다시 가져올 때 로딩이 되어서 데이터를 가져오는 것을 알리기 위해 선언
            }
          },
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) async {
    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.2,
        maxChildSize: 0.6,
        expand: false,
        builder: (_, scrollController) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: theme.dialogBackgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 20.h,
                    children: [
                      // 상단 바
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: theme.dividerColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),

                      // 제목
                      Text(
                        "필터 선택",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // 입력 + 버튼
                      Row(
                        spacing: 10.w,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _plusTextController,
                              decoration: const InputDecoration(
                                hintText: '보고싶은 검색어를 입력하세요',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            style: smallButton,
                            child: Text(
                              "추가",
                              style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                            ),
                            onPressed: () {
                              final text = _plusTextController.text.trim();
                              if (text.isEmpty) {
                                return showToast(message: "검색어를 입력해주세요");
                              }
                              if (plusShowKeyword.contains(text)) {
                                showToast(message: "이미 추가된 키워드입니다");
                              } else {
                                setState(() => plusShowKeyword.add(text));
                              }
                              _plusTextController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ],
                      ),

                      // 필터칩
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 10.h,
                        children: moreLabels.map((label) {
                          final isSelected = plusShowKeyword.contains(label);
                          return FilterChip(
                            label: Text(label),
                            selected: isSelected,
                            selectedColor: Colors.blue,
                            checkmarkColor: Colors.white,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            onSelected: (_) => setState(() {
                              isSelected
                                  ? plusShowKeyword.remove(label)
                                  : plusShowKeyword.add(label);
                            }),
                          );
                        }).toList(),
                      ),

                      // 검색 버튼
                      ElevatedButton(
                        child: Text(
                          "검색",
                          style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (plusShowKeyword.isEmpty) {
                            return showToast(message: "키워드를 선택해주세요");
                          }

                          _selectedKeyword = "";

                          await fetchNews(
                            keyword: plusShowKeyword.join(" OR "),
                            page: currentPage,
                            startDate: formatter.format(startDate),
                            endDate: formatter.format(endDate),
                            reset: true,
                          );

                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
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
