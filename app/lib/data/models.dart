import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
class EraScore with _$EraScore {
  const factory EraScore({
    required String era_name,
    required int start_year,
    required int end_year,
    required double score,
    required String reason,
    required List<String> artifacts,
    String? image_url,
  }) = _EraScore;

  factory EraScore.fromJson(Map<String, dynamic> json) => _$EraScoreFromJson(json);
}

@freezed
class AnalysisResponse with _$AnalysisResponse {
  const factory AnalysisResponse({
    required String location_name,
    required List<EraScore> peak_eras,
    required String summary_ai,
  }) = _AnalysisResponse;

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) => _$AnalysisResponseFromJson(json);
}
