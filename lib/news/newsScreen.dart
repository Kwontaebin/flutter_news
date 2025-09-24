import 'package:flutter/material.dart';
import 'package:flutter_news/component/flutterToast.dart';
import 'package:flutter_news/component/utils/webView.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../component/utils/bookmarkManager.dart';
import '../component/utils/shareManager.dart';
import '../provider/newsProvider.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final TextEditingController _searchTextController = TextEditingController();
  final TextEditingController _plusTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final formatter = DateFormat('yyyy-MM-dd');
  final endDate = DateTime.now();
  late final DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  String _selectedKeyword = "경제";
  final List<String> labels = ['경제', '엔터', '스포츠', '여행', 'IT', '지식', '건강', '음식'];
  late final List<String> moreLabels = [...labels, '패션', '음악', '영화', '쇼핑'];
  List<String> plusShowKeyword = [];
  late final NewsProvider provider;

  final smallButton = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
  );

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider = context.read<NewsProvider>();

      provider.fetchNews(
        keyword: _selectedKeyword,
        startDate: formatter.format(startDate),
        endDate: formatter.format(endDate),
        reset: true,
      );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !provider.isLoading && provider.hasMore) {
      provider.fetchNews(
        keyword: _selectedKeyword,
        startDate: formatter.format(startDate),
        endDate: formatter.format(endDate),
        reset: false,
      );
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
            final keyword = _searchTextController.text.trim();
            if (keyword.isEmpty) {
              showToast(message: "검색어를 입력해주세요");
              return;
            }

            _selectedKeyword = "";
            await context.read<NewsProvider>().fetchNews(
              keyword: keyword,
              startDate: formatter.format(startDate),
              endDate: formatter.format(endDate),
              reset: true,
            );
            _searchTextController.clear();
            FocusScope.of(context).unfocus();
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
                    _searchTextController.clear();
                    FocusScope.of(context).unfocus();
                    setState(() => _selectedKeyword = label);
                    await context.read<NewsProvider>().fetchNews(
                      keyword: label,
                      startDate: formatter.format(startDate),
                      endDate: formatter.format(endDate),
                      reset: true,
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
          child: IconButton(
            onPressed: () {
              _searchTextController.clear();
              FocusScope.of(context).requestFocus(FocusNode());
              _showFilterSheet(context);
            },
            icon: Icon(Icons.tune),
          ),
        ),
      ],
    );
  }

  Widget _buildNewsList() {
    return Consumer<NewsProvider>(
      builder: (context, provider, child) {
        if (provider.newsList.isEmpty && provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: SlidableAutoCloseBehavior(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: provider.newsList.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < provider.newsList.length) {
                  final news = provider.newsList[index];
                  final bookmarkManager = BookmarkManager(boxName: 'newsBox');
                  return Slidable(
                    key: ValueKey(index),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            shareContent(news.url, subject: news.title);
                          },
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          icon: Icons.share,
                          label: '공유',
                        ),
                        SlidableAction(
                          onPressed: (context) {
                            bookmarkManager.addBookmark({"title": news.title, "url": news.url});

                            showToast(message: "북마크에 추가되었습니다", bgColor: Colors.blue);
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
                            if (news.url != null) {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => WebViewScreen(url: news.url)));
                            }
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                            padding: EdgeInsets.zero,
                          ),
                          child: Text(
                            news.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              height: 1.0,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
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
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }

  // void _showFilterSheet(BuildContext context) async {
  //   final theme = Theme.of(context);
  //
  //   await showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     useSafeArea: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => DraggableScrollableSheet(
  //       initialChildSize: 0.5,
  //       minChildSize: 0.2,
  //       maxChildSize: 0.6,
  //       expand: false,
  //       builder: (_, scrollController) {
  //         return StatefulBuilder(
  //           builder: (context, setState) {
  //             return Container(
  //               padding: EdgeInsets.all(16.r),
  //               decoration: BoxDecoration(
  //                 color: theme.dialogBackgroundColor,
  //                 borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
  //               ),
  //               child: SingleChildScrollView(
  //                 controller: scrollController,
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   spacing: 20.h,
  //                   children: [
  //                     Center(
  //                       child: Container(
  //                         width: 40.w,
  //                         height: 5.h,
  //                         decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(10.r)),
  //                       ),
  //                     ),
  //                     Text(
  //                       "필터 선택",
  //                       style: theme.textTheme.titleLarge?.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold),
  //                     ),
  //                     Row(
  //                       spacing: 10.w,
  //                       children: [
  //                         Expanded(
  //                           child: TextField(
  //                             controller: _plusTextController,
  //                             decoration: const InputDecoration(hintText: '보고싶은 검색어를 입력하세요', border: OutlineInputBorder()),
  //                           ),
  //                         ),
  //                         ElevatedButton(
  //                           style: smallButton,
  //                           child: Text("추가", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
  //                           onPressed: () {
  //                             final text = _plusTextController.text.trim();
  //                             if (text.isEmpty) {
  //                               return showToast(message: "검색어를 입력해주세요");
  //                             }
  //                             if (plusShowKeyword.contains(text)) {
  //                               showToast(message: "이미 추가된 키워드입니다");
  //                             } else {
  //                               setState(() => plusShowKeyword.add(text));
  //                             }
  //                             _plusTextController.clear();
  //                             FocusScope.of(context).unfocus();
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                     Wrap(
  //                       spacing: 10.w,
  //                       runSpacing: 10.h,
  //                       children: moreLabels.map((label) {
  //                         final isSelected = plusShowKeyword.contains(label);
  //                         return FilterChip(
  //                           label: Text(label),
  //                           selected: isSelected,
  //                           selectedColor: Colors.blue,
  //                           checkmarkColor: Colors.white,
  //                           backgroundColor: theme.colorScheme.surfaceContainerHighest,
  //                           onSelected: (_) => setState(() {
  //                             isSelected ? plusShowKeyword.remove(label) : plusShowKeyword.add(label);
  //                           }),
  //                         );
  //                       }).toList(),
  //                     ),
  //                     ElevatedButton(
  //                       child: Text("검색", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
  //                       onPressed: () async {
  //                         if (plusShowKeyword.isEmpty) {
  //                           return showToast(message: "키워드를 선택해주세요");
  //                         }
  //
  //                         _selectedKeyword = "";
  //
  //                         await context.read<NewsProvider>().fetchNews(
  //                           keyword: plusShowKeyword.join(" OR "),
  //                           startDate: formatter.format(startDate),
  //                           endDate: formatter.format(endDate),
  //                           reset: true,
  //                         );
  //
  //                         Navigator.pop(context);
  //                       },
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       },
  //     ),
  //   );
  //
  //   // FocusScope.of(context).unfocus();
  //   _plusTextController.clear();
  //   plusShowKeyword.clear();
  // }

  void _showFilterSheet(BuildContext context) async {
    final theme = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ 키보드 올라오면 모달도 위로
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.2,
        maxChildSize: 0.9, // 최대 높이를 높여서 키보드와 충돌 방지
        expand: false,
        builder: (_, scrollController) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                // ✅ 키보드 높이만큼 padding 추가
                padding: EdgeInsets.only(left: 16.r, right: 16.r, top: 16.r, bottom: 16.r + MediaQuery.of(context).viewInsets.bottom),
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
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 5.h,
                          decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(10.r)),
                        ),
                      ),
                      Text(
                        "필터 선택",
                        style: theme.textTheme.titleLarge?.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        spacing: 10.w,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _plusTextController,
                              decoration: const InputDecoration(hintText: '보고싶은 검색어를 입력하세요', border: OutlineInputBorder()),
                            ),
                          ),
                          ElevatedButton(
                            style: smallButton,
                            child: Text("추가", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
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
                              // ✅ 입력 완료 후 키보드 내리기
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ],
                      ),
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
                              isSelected ? plusShowKeyword.remove(label) : plusShowKeyword.add(label);
                            }),
                          );
                        }).toList(),
                      ),
                      ElevatedButton(
                        child: Text("검색", style: theme.textTheme.labelLarge?.copyWith(color: Colors.white)),
                        onPressed: () async {
                          if (plusShowKeyword.isEmpty) {
                            return showToast(message: "키워드를 선택해주세요");
                          }

                          _selectedKeyword = "";

                          await context.read<NewsProvider>().fetchNews(
                            keyword: plusShowKeyword.join(" OR "),
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

    // ✅ 모달 닫힌 후 포커스 제거
    FocusScope.of(context).requestFocus(FocusNode());
    _plusTextController.clear();
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
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent, // 빈 공간도 터치 가능
              onTap: () {
                Slidable.of(context)?.close();
              },
              child: _buildNewsList(),
            ),
          ),
        ],
      ),
    );
  }
}
