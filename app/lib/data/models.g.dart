// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EraScore _$EraScoreFromJson(Map<String, dynamic> json) => _EraScore(
  era_name: json['era_name'] as String,
  start_year: (json['start_year'] as num).toInt(),
  end_year: (json['end_year'] as num).toInt(),
  score: (json['score'] as num).toDouble(),
  reason: json['reason'] as String,
  artifacts:
      (json['artifacts'] as List<dynamic>).map((e) => e as String).toList(),
  image_url: json['image_url'] as String?,
);

Map<String, dynamic> _$EraScoreToJson(_EraScore instance) => <String, dynamic>{
  'era_name': instance.era_name,
  'start_year': instance.start_year,
  'end_year': instance.end_year,
  'score': instance.score,
  'reason': instance.reason,
  'artifacts': instance.artifacts,
  'image_url': instance.image_url,
};

_AnalysisResponse _$AnalysisResponseFromJson(Map<String, dynamic> json) =>
    _AnalysisResponse(
      location_name: json['location_name'] as String,
      peak_eras:
          (json['peak_eras'] as List<dynamic>)
              .map((e) => EraScore.fromJson(e as Map<String, dynamic>))
              .toList(),
      summary_ai: json['summary_ai'] as String,
    );

Map<String, dynamic> _$AnalysisResponseToJson(_AnalysisResponse instance) =>
    <String, dynamic>{
      'location_name': instance.location_name,
      'peak_eras': instance.peak_eras,
      'summary_ai': instance.summary_ai,
    };
