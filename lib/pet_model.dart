
class PetAnalysisResponse {
  final String breedName;
  final String confidenceScore;
  final NutritionPlan nutritionPlan;

  PetAnalysisResponse({
    required this.breedName,
    required this.confidenceScore,
    required this.nutritionPlan,
  });

  factory PetAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return PetAnalysisResponse(
      breedName: json['breed_name'] ?? 'Unknown',
      confidenceScore: json['confidence_score'] ?? '0%',
      nutritionPlan: NutritionPlan.fromJson(json['nutrition_plan'] ?? {}),
    );
  }
}

class NutritionPlan {
  final String dailyCalories;
  final String proteinRequirements;
  final String recommendedFood;
  final String feedingSchedule;

  NutritionPlan({
    required this.dailyCalories,
    required this.proteinRequirements,
    required this.recommendedFood,
    required this.feedingSchedule,
  });

  factory NutritionPlan.fromJson(Map<String, dynamic> json) {
    return NutritionPlan(
      dailyCalories: json['daily_calories'] ?? 'N/A',
      proteinRequirements: json['protein_requirements'] ?? 'N/A',
      recommendedFood: json['recommended_food'] ?? 'N/A',
      feedingSchedule: json['feeding_schedule'] ?? 'N/A',
    );
  }
}