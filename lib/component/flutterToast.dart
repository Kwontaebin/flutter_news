import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast({
  required String message,
  Color bgColor = Colors.red,
  Color textColor = Colors.white,
  double? textSize, // nullable
}) {
  Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    backgroundColor: bgColor,
    textColor: textColor,
    fontSize: textSize ?? 16.sp, // 여기서 처리
  );
}
