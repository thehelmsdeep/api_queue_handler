import 'dart:async';
import 'package:api_queue_handler/src/methods.dart';
import 'package:api_queue_handler/src/model/response.dart';

class SequentialRequestModel {
  final Completer<ResponseModel> completer;
  final String endpoint;
  final RequestMethod method;
  final Map<String, dynamic>? body;
  final Map<String, String>? customHeader;

  SequentialRequestModel({
    required this.completer,
    required this.endpoint,
    required this.method,
    required this.body,
    required this.customHeader,
  });
}
