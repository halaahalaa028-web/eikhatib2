class ErrorModel {
  final int status;
  final String errorMessage;
  final String? errorCode;

  ErrorModel({
    required this.status,
    required this.errorMessage,
    this.errorCode,
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) {
    return ErrorModel(
      status: json['status'] ?? 0,
      errorMessage: json['message'] ?? 'An unknown error occurred',
      errorCode: json['errorCode'] as String?,
    );
  }
}
