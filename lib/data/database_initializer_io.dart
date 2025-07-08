import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

Future<void> initializeDatabase() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
