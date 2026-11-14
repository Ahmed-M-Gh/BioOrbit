class ApiResponse {
  final bool isSuccess;
  final int statusCode;
  final Map<String, dynamic> data;
  final String? errorMessage;
  final String? generatedImageUrl;

  const ApiResponse({
    required this.isSuccess,
    this.statusCode = 200,
    this.data = const {},
    this.errorMessage,
    this.generatedImageUrl,
  });

  ApiResponse copyWith({
    bool? isSuccess,
    int? statusCode,
    Map<String, dynamic>? data,
    String? errorMessage,
    String? generatedImageUrl,
  }) {
    return ApiResponse(
      isSuccess: isSuccess ?? this.isSuccess,
      statusCode: statusCode ?? this.statusCode,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
      generatedImageUrl: generatedImageUrl ?? this.generatedImageUrl,
    );
  }
}
