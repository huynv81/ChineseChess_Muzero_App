import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToastMessage(String msg) {
  Fluttertoast.showToast(
      msg: "This is Center Short Toast",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0);
  // Fluttertoast.showToast(
  //     msg: msg,
  //     toastLength: Toast.LENGTH_SHORT,
  //     gravity: ToastGravity.CENTER,
  //     timeInSecForIosWeb: 1,
  //     backgroundColor: const Color.fromARGB(255, 29, 131, 182),
  //     textColor: Colors.white,
  //     fontSize: 16.0);
}
