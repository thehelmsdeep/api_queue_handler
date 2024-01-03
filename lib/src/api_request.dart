import 'dart:async';

import 'package:api_queue_handler/src/methods.dart';
import 'package:api_queue_handler/src/model.dart';

class ApiRequest {
  final Completer<ApiResponseModel> completer;
  final String endpoint;
  final ServerMethod method;
  final dynamic body;
  final Map<String, String>? customHeader;
  final String? filePath;

  ApiRequest({
    required this.completer,
    required this.endpoint,
    required this.method,
    required this.body,
    required this.customHeader,
    required this.filePath,
  });
}