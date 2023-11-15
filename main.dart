import 'package:flutter/material.dart';
import 'page.dart';
import 'driver.dart';
import 'transaksi.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  sqfliteFfiInit();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => MainPage(),
        '/addDriver': (context) => AddDriverPage(),
        '/addTransaction': (context) => AddTransactionPage(),
      },
    );
  }
}