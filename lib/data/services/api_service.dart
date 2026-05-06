import 'dart:typed_data';

import 'package:ai_app/core/utils/app_constants.dart';
import 'package:ai_app/data/models/analysis_result_model.dart';
import 'package:dio/dio.dart';

class ApiService {
  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.apiBaseUrl,
            connectTimeout: AppConstants.connectTimeout,
            receiveTimeout: AppConstants.receiveTimeout,
            headers: const <String, dynamic>{'Accept': 'application/json'},
          ),
        );

  final Dio _dio;

  Future<AnalysisResultModel> analyzeDrawing({
    required String fileName,
    String? filePath,
    Uint8List? fileBytes,
    ProgressCallback? onSendProgress,
  }) async {
    if (AppConstants.apiBaseUrl.isEmpty) {
      throw Exception(
        'API base URL is missing. Run the app with --dart-define=API_BASE_URL=https://your-backend.com',
      );
    }

    final MultipartFile multipartFile;
    if (fileBytes != null) {
      multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
    } else if (filePath != null && filePath.isNotEmpty) {
      multipartFile = await MultipartFile.fromFile(filePath, filename: fileName);
    } else {
      throw Exception('The selected PDF could not be read.');
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConstants.analyzeDrawingEndpoint,
        data: FormData.fromMap(<String, dynamic>{'file': multipartFile}),
        onSendProgress: onSendProgress,
      );

      final data = response.data;
      if (data == null) {
        throw Exception('The API returned an empty response.');
      }

      return AnalysisResultModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(_mapDioError(error));
    }
  }

  String _mapDioError(DioException error) {
    final message = error.response?.data;
    if (message is Map<String, dynamic>) {
      final apiMessage =
          message['message'] ?? message['error'] ?? message['detail'];
      if (apiMessage is String && apiMessage.trim().isNotEmpty) {
        return apiMessage;
      }
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'The server took too long to respond. Please try again.';
      case DioExceptionType.connectionError:
        return 'Unable to reach the server. Check your internet or API host.';
      case DioExceptionType.badResponse:
        return 'The server returned an unexpected response.';
      default:
        return 'Drawing analysis failed. Please try again.';
    }
  }
}
