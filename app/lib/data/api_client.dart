import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: unused_import
import 'package:chronoholidder/core/constants.dart';
import 'models.dart';

final apiClientProvider = Provider((ref) => ApiClient());

class ApiClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConstants.backendUrl));

  Future<AnalysisResponse> analyzeLocation(double lat, double lon) async {
    try {
      final response = await _dio.post('/api/analyze-location', data: {
        'latitude': lat,
        'longitude': lon,
      });
      return AnalysisResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to analyze location: $e');
    }
  }
}
