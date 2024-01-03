import 'dart:io' if (dart.library.html) 'dart:html';

class ResponseModel {
  final bool success;
  final int statusCode;
  final Map<String, dynamic>? data;
  final String? message;

  bool get isSuccessful => success && statusCode == HttpStatus.ok;

  ResponseModel({
    this.success = false,
    this.statusCode = HttpStatus.internalServerError,
    this.data,
    this.message,
  });

  factory ResponseModel.fromJson(
      {required Map<String, dynamic>? result, String? message}) {
    return ResponseModel(
      success: true,
      statusCode: HttpStatus.ok,
      data: result,
      message: message,
    );
  }

  @override
  String toString() {
    return 'ApiModel(success: $success, data: $data, message: $message, statusCode: $statusCode)';
  }
}
