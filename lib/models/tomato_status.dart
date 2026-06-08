class TomatoStatus {
  final String diseaseName;
  final String diseaseStatus;
  final String harvestRecommendation;
  final String imageUrl;
  final int lastUpdate;
  final String ripenessLevel;
  final String ripenessStage;
  final String treatmentStepByStep;

  TomatoStatus({
    required this.diseaseName,
    required this.diseaseStatus,
    required this.harvestRecommendation,
    required this.imageUrl,
    required this.lastUpdate,
    required this.ripenessLevel,
    required this.ripenessStage,
    required this.treatmentStepByStep,
  });

  factory TomatoStatus.fromMap(Map<dynamic, dynamic> map) {
    return TomatoStatus(
      diseaseName: map['disease_name']?.toString() ?? 'None',
      diseaseStatus: map['disease_status']?.toString() ?? 'None',
      harvestRecommendation: map['harvest_recommendation']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? '',
      lastUpdate: map['last_update'] is int
          ? map['last_update']
          : int.tryParse(map['last_update']?.toString() ?? '0') ?? 0,
      ripenessLevel: map['ripeness_level']?.toString() ?? 'Unknown',
      ripenessStage: map['ripeness_stage']?.toString() ?? 'Unknown',
      treatmentStepByStep: map['treatment_step_by_step']?.toString() ?? '',
    );
  }

  factory TomatoStatus.initial() {
    return TomatoStatus(
      diseaseName: 'None',
      diseaseStatus: 'None',
      harvestRecommendation: 'No recommendation available.',
      imageUrl: '',
      lastUpdate: 0,
      ripenessLevel: 'Unknown',
      ripenessStage: 'Unknown',
      treatmentStepByStep: 'No treatment steps.',
    );
  }
}
