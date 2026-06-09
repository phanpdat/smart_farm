class DiagnosticRecord {
  final String diseaseName;
  final String diseaseStatus;
  final String imageUrl;
  final int lastUpdate;
  final String treatmentStepByStep;
  final String ripenessLevel;
  final String ripenessStage;
  final String harvestRecommendation;

  DiagnosticRecord({
    required this.diseaseName,
    required this.diseaseStatus,
    required this.imageUrl,
    required this.lastUpdate,
    required this.treatmentStepByStep,
    required this.ripenessLevel,
    required this.ripenessStage,
    required this.harvestRecommendation,
  });

  Map<String, dynamic> toJson() => {
        'disease_name': diseaseName,
        'disease_status': diseaseStatus,
        'image_url': imageUrl,
        'last_update': lastUpdate,
        'treatment_step_by_step': treatmentStepByStep,
        'ripeness_level': ripenessLevel,
        'ripeness_stage': ripenessStage,
        'harvest_recommendation': harvestRecommendation,
      };

  factory DiagnosticRecord.fromJson(Map<String, dynamic> json) =>
      DiagnosticRecord(
        diseaseName: json['disease_name']?.toString() ?? 'None',
        diseaseStatus: json['disease_status']?.toString() ?? 'None',
        imageUrl: json['image_url']?.toString() ?? '',
        lastUpdate: json['last_update'] is int
            ? json['last_update']
            : int.tryParse(json['last_update']?.toString() ?? '0') ?? 0,
        treatmentStepByStep: json['treatment_step_by_step']?.toString() ?? '',
        ripenessLevel: json['ripeness_level']?.toString() ?? 'Unknown',
        ripenessStage: json['ripeness_stage']?.toString() ?? 'Unknown',
        harvestRecommendation: json['harvest_recommendation']?.toString() ?? '',
      );
}
