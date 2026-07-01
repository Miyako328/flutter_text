import 'package:dio/dio.dart';
import 'package:flutter_text/api/retrofit_clients.dart';
import 'package:flutter_text/model/scan_book.dart';

class ScanBookApi {
  final BaseOptions baseOptions = BaseOptions();
  final String appCode = '853da7ee8c334ac0b293bbd812473b42';
  late final Dio _dio = Dio(baseOptions);
  late final ScanBookPrivateRestClient _privateClient =
      ScanBookPrivateRestClient(_dio);
  late final ScanBookAliRestClient _aliClient = ScanBookAliRestClient(_dio);

  Future<ScanBookPModel> isbnGetBookDetailP(String isbn) async {
    try {
      ScanBookPModel _scanBook;
      final dynamic data =
          await _privateClient.isbnGetBookDetail({'isbn': isbn});
      _scanBook = ScanBookPModel.fromJson(data['data'][0]);
      return _scanBook;
    } catch (e) {
      print('IsbnGetBookDetailP error = $e');
      rethrow;
    }
  }

  Future<ScanBookAModel> isbnGetBookDetailA(String isbn) async {
    try {
      ScanBookAModel _scanABook;
      final dynamic data = await _aliClient.isbnGetBookDetail(
        'APPCODE $appCode',
        {'isbn': isbn},
      );
      print(data['result']);
      _scanABook = ScanBookAModel.fromJson(data['result']);
      return _scanABook;
    } catch (e) {
      print('IsbnGetBookDetailP error = ${e}');
      rethrow;
    }
  }
}
