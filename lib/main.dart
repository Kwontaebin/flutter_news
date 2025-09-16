import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'component/scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "/Users/kwonteabin/Documents/GitHub/flutter_news/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "flutterNews",
          theme: ThemeData(
            textTheme: Typography.englishLike2018.apply(
              bodyColor: Colors.black,
            ),
          ),
          home: child,
        );
      },
      child: const ScaffoldComponent(),
    );
  }
}