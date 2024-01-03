import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:api_queue_handler/src/api_request.dart';
import 'package:api_queue_handler/src/methods.dart';
import 'package:api_queue_handler/src/model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// How to use
/// ApiManager().initialize('your_base_url');
/// ApiManager().connect(endpoint: 'a/b');


class ApiManager {
  final Queue<ApiRequest> _requestQueue = Queue();

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

  Future<ApiResponseModel> connect({
    required String endpoint,
    ServerMethod method = ServerMethod.get,
    dynamic body,
    Map<String, String>? customHeader,
    String? filePath,
  }) async {
    final Completer<ApiResponseModel> completer = Completer<ApiResponseModel>();

    final apiRequest = ApiRequest(
      completer: completer,
      endpoint: endpoint,
      method: method,
      body: body,
      customHeader: customHeader,
      filePath: filePath,
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
          filePath: apiRequest.filePath,
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

  Future<ApiResponseModel> _executeRequest({
    required String endpoint,
    ServerMethod method = ServerMethod.get,
    dynamic body,
    Map<String, String>? customHeader,
    String? filePath,
  }) async {
    String jsonString = jsonEncode(body);

    final header = <String, String>{
      'Content-Type': 'application/json',
      'Accept': '*/*',
    };

    if (customHeader != null) {
      header.addAll(customHeader);
    }

    try {
      final uri = _constructUri(endpoint);
      final response = await _sendRequest(uri, method, body, header, filePath);

      return _handleResponse(httpResponse: response);
    } catch (e) {
      return ApiResponseModel(
          statusCode: HttpStatus.internalServerError,
          success: false,
          message: e.toString());
    }
  }

  Uri _constructUri(String endpoint) {
    final fullUrl = '$_baseUrl$endpoint';
    return Uri.parse(fullUrl);
  }

  Future<http.Response> _sendRequest(Uri uri, ServerMethod method, dynamic body,
      Map<String, String> customHeader, String? filePath) async {
    late http.Response response;

    switch (method) {
      case ServerMethod.post:
        response =
            await http.post(uri, headers: customHeader, body: jsonEncode(body));
        break;
      case ServerMethod.get:
        response = await http.get(uri, headers: customHeader);
        break;
      case ServerMethod.put:
        response =
            await http.put(uri, headers: customHeader, body: jsonEncode(body));
        break;
      case ServerMethod.delete:
        response = await http.delete(uri,
            headers: customHeader, body: jsonEncode(body));
        break;
      case ServerMethod.upload:
        if (filePath != null) {
          var request = http.MultipartRequest('POST', uri)
            ..headers.addAll(customHeader)
            ..fields['body'] = jsonEncode(body);

          var file = await http.MultipartFile.fromPath('file', filePath);
          request.files.add(file);

          var streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
        } else {
          throw ArgumentError("File path is required for upload");
        }
        break;
    }

    return response;
  }

  ApiResponseModel _handleResponse({required http.Response httpResponse}) {
    final statusCode = httpResponse.statusCode;

    final Map<String, dynamic> responseData = json.decode(httpResponse.body);

    switch (statusCode) {
      case HttpStatus.ok:
        return ApiResponseModel.fromJson(result: responseData);

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

  ApiResponseModel _handleUnauthorizedResponse(
      {required String message, required int statusCode}) {
    //TODO
    return ApiResponseModel(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }

  ApiResponseModel _handleForbiddenResponse(
      {required String message, required int statusCode}) {
    //TODO
    return ApiResponseModel(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }

  ApiResponseModel _handleNotFoundResponse(
      {required String message, required int statusCode}) {
    //TODO
    return ApiResponseModel(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }

  ApiResponseModel _handleErrorResponse(
      {required String message, required int statusCode}) {
    //TODO
    return ApiResponseModel(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }

  ApiResponseModel _internalServerErrorResponse(
      {required String message, required int statusCode}) {
    //TODO
    return ApiResponseModel(
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }
}
