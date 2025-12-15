import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dio URI resolution check', () async {
    await check("http://example.com/tautulli/api/v2", "/");
    await check("http://example.com/tautulli/api/v2/", "/");
    await check("http://example.com/tautulli/api/v2", "");
    await check("http://example.com/tautulli/api/v2/", "");
  });
}

Future<void> check(String base, String path) async {
  final dio = Dio(BaseOptions(baseUrl: base));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      print("Base: '$base', Path: '$path' -> Resolved: '${options.uri}'");
      return handler.resolve(Response(requestOptions: options, statusCode: 200));
    },
  ));
  
  try {
    await dio.get(path);
  } catch (e) {
    // Ignore errors
  }
}
