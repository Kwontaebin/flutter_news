import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../component/utils/bookmarkManager.dart';
import '../component/utils/shareManager.dart';
import '../component/utils/webViewScreen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final bookmarkManager = BookmarkManager(boxName: 'newsBox');

  @override
  Widget build(BuildContext context) {
    final bookmarkNews = bookmarkManager.getBookmarks();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: SlidableAutoCloseBehavior(
        child: ListView.builder(
          itemCount: bookmarkNews.length,
          itemBuilder: (context, index) {
            String? title = bookmarkNews[index]["title"];
            final url = bookmarkNews[index]['url'];

            return Slidable(
              key: ValueKey(index),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      shareContent(
                        url!,
                        subject: title,
                      );
                    },
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.bookmark,
                    label: '공유',
                  ),
                  SlidableAction(
                    onPressed: (context) {
                      setState(() => bookmarkManager.removeBookmark(index));
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: '삭제',
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
                    style: TextButton.styleFrom(foregroundColor: Colors.black, padding: EdgeInsets.zero),
                    child: Text(
                      title.toString(),
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
      ),
    );
  }
}
