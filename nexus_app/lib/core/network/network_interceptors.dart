import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class NexusLogInterceptor extends Interceptor {
  NexusLogInterceptor(this._log);

  final Logger _log;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _log.d('[→] ${options.method} ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _log.d('[←] ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _log.e('[✗] ${err.requestOptions.path}: ${err.message}');
    handler.next(err);
  }
}

/// Transparent retry for transient failures (timeouts, rate-limits).
class NexusRetryInterceptor extends Interceptor {
  static const int _maxRetries = 2;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final attempt = (options.extra['retry_count'] as int?) ?? 0;

    final isTransient = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.response?.statusCode == 429;

    if (isTransient && attempt < _maxRetries) {
      options.extra['retry_count'] = attempt + 1;
      await Future<void>.delayed(Duration(milliseconds: 800 * (attempt + 1)));
      try {
        final retryDio = Dio(
          BaseOptions(
            baseUrl: options.baseUrl,
            headers: options.headers,
            queryParameters: options.queryParameters,
            extra: options.extra,
          ),
        );
        final response = await retryDio.fetch<dynamic>(options);
        return handler.resolve(response);
      } catch (_) {
        // fall through to next handler on nested failure
      }
    }
    handler.next(err);
  }
}
