import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:api_queue_handler/src/model/request.dart';
import 'package:api_queue_handler/src/methods.dart';
import 'package:api_queue_handler/src/model/response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:io' if (dart.library.html) 'dart:html';

class ApiManager {
  final Queue<SequentialRequestModel> _requestQueue = Queue();

  bool _isProcessingQueue = false;

  late String _baseUrl;

  static final ApiManager _instance = ApiManager._internal();

  ApiManager._internal();

  factory ApiManager() {
    return _instance;
  }

  void initialize(String baseUrl) {
    _baseUrl = baseUrl;
  }

  Future<ResponseModel> request({
    required String endpoint,
    required bool runParallel,
    RequestMethod method = RequestMethod.get,
    Map<String, dynamic>? body,
    Map<String, String>? customHeader,
  }) async {
    if (runParallel) {
      return _executeRequest(
        endpoint: endpoint,
        customHeader: customHeader,
        body: body,
        method: method,
      );
    }

    final Completer<ResponseModel> completer = Completer<ResponseModel>();

    final apiRequest = SequentialRequestModel(
      completer: completer,
      endpoint: endpoint,
      method: method,
      body: body,
      customHeader: customHeader,
    );

    _requestQueue.add(apiRequest);

    if (!_isProcessingQueue) {
      debugPrint('Api is calling');
      _isProcessingQueue = true;
      _processQueue();
    }

    return completer.future;
  }

  void _processQueue() async {
    while (_requestQueue.isNotEmpty) {
      final apiRequest = _requestQueue.first;

      try {
        final result = await _executeRequest(
          endpoint: apiRequest.endpoint,
          customHeader: apiRequest.customHeader,
          body: apiRequest.body,
          method: apiRequest.method,
        );

        apiRequest.completer.complete(result);
        _requestQueue.removeFirst();
      } catch (error) {
        apiRequest.completer.completeError(error);
        _requestQueue.removeFirst();
      }
    }

    _isProcessingQueue = false;
    debugPrint('Api process completed');
  }

  Future<ResponseModel> _executeRequest({
    required String endpoint,
    RequestMethod method = RequestMethod.get,
    Map<String, dynamic>? body,
    Map<String, String>? customHeader,
  }) async {
    //  String jsonString = jsonEncode(body);

    final header = <String, String>{
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };

    if (customHeader != null) {
      header.addAll(customHeader);
    }

    try {
      final uri = _constructUri(endpoint);
      final response = await _sendRequest(
        uri,
        method,
        body,
        header,
      );

      return _handleResponse(httpResponse: response);
    } catch (e) {
      return ResponseModel(
          statusCode: HttpStatus.internalServerError,
          success: false,
          message: e.toString());
    }
  }

  Uri _constructUri(String endpoint) {
    final fullUrl = '$_baseUrl/$endpoint';
    return Uri.parse(fullUrl);
  }

  Future<http.Response> _sendRequest(
    Uri uri,
    RequestMethod method,
    Map<String, dynamic>? body,
    Map<String, String> customHeader,
  ) async {
    late http.Response response;

    switch (method) {
      case RequestMethod.post:
        response =
            await http.post(uri, headers: customHeader, body: jsonEncode(body));
        break;
      case RequestMethod.get:
        response = await http.get(uri, headers: customHeader);
        break;
      case RequestMethod.put:
        response =
            await http.put(uri, headers: customHeader, body: jsonEncode(body));
        break;
      case RequestMethod.delete:
        response = await http.delete(uri,
            headers: customHeader, body: jsonEncode(body));
        break;
    }

    return response;
  }

  ResponseModel _handleResponse({required http.Response httpResponse}) {
    final statusCode = httpResponse.statusCode;

    final Map<String, dynamic> responseData = json.decode(httpResponse.body);

    switch (statusCode) {
      case HttpStatus.ok:
        return ResponseModel.fromJson(result: responseData);

      case HttpStatus.unauthorized:
        return _handleUnauthorizedResponse(
            message: 'Unauthorized', statusCode: statusCode);

      case HttpStatus.forbidden:
        return _handleForbiddenResponse(
            message: 'Forbidden', statusCode: statusCode);

      case HttpStatus.notFound:
        return _handleNotFoundResponse(
            message: 'Not Found', statusCode: statusCode);

      case HttpStatus.internalServerError:
        return _internalServerErrorResponse(
            message: 'internal Server Error', statusCode: statusCode);

      default:
        return _handleErrorResponse(message: 'Error', statusCode: statusCode);
    }
  }

  ResponseModel _handleUnauthorizedResponse(
      {required String message, required int statusCode}) {
    //TODO
    return ResponseModel(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }

  ResponseModel _handleForbiddenResponse(
      {required String message, required int statusCode}) {
    //TODO
    return ResponseModel(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }

  ResponseModel _handleNotFoundResponse(
      {required String message, required int statusCode}) {
    //TODO
    return ResponseModel(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }

  ResponseModel _handleErrorResponse(
      {required String message, required int statusCode}) {
    //TODO
    return ResponseModel(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }

  ResponseModel _internalServerErrorResponse(
      {required String message, required int statusCode}) {
    //TODO
    return ResponseModel(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }
}
