import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final TextEditingController _textController = TextEditingController();
  String _selectedKeyword = "경제";
  late final newsApiKey;
  final List<String> labels = ['경제', '엔터', '스포츠', '쇼핑', '상식', '개발', '지식', '건강'];

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        newsApiKey = dotenv.env['NEWS_API_KEY'];
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 20.h,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: Row(
            spacing: 10.w,
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: '검색어를 입력하세요', // placeholder
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  // print(_textController.text);
                  // print(newsApiKey);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text("검색", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),

        Row(
          children: [
            Expanded(
              flex: 7,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Row(
                    spacing: 15.w,
                    children: labels.map((label) {
                      bool isSelected = label == _selectedKeyword;
                      return InkWell(
                        onTap: () {
                          setState(() => _selectedKeyword = label);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
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
            ),

            Expanded(
              flex: 2,
              child: IconButton(onPressed: () {}, icon: Icon(Icons.tune)),
            ),
          ],
        ),
      ],
    );
  }
}
