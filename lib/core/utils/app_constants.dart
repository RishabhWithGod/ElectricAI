abstract final class AppConstants {
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static const String analyzeDrawingEndpoint = '/analyze-drawing';
  static const String historyStorageKey = 'drawing_analysis_history';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const int maxHistoryItems = 20;
}
