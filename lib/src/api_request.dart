import 'dart:async';

import 'package:api_queue_handler/src/methods.dart';
import 'package:api_queue_handler/src/model.dart';

class ApiRequest {
  final Completer<ApiResponseModel> completer;
  final String endpoint;
  final RequestMethod method;
  final Map<String,dynamic>? query;
  final Map<String, String>? customHeader;

  ApiRequest({
    required this.completer,
    required this.endpoint,
    required this.method,
    required this.query,
    required this.customHeader,
  });
}