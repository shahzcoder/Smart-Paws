
class DiagnosisRequest {
  final String species;
  final String? breed;
  final String? age;
  final List<String> reportedSymptoms;
  final Map<String, String> followUpAnswers;

  DiagnosisRequest({
    required this.species,
    this.breed,
    this.age,
    required this.reportedSymptoms,
    required this.followUpAnswers,
  });

  Map<String, dynamic> toJson() {
    return {
      "species": species,
      "breed": breed,
      "age": age,
      "reported_symptoms": reportedSymptoms,
      "follow_up_answers": followUpAnswers,
    };
  }
}

class DiagnosisResponse {
  final bool diagnosisFound;
  final String recommendation;
  final String severityLevel;
  final String? probableCondition;

  DiagnosisResponse({
    required this.diagnosisFound,
    required this.recommendation,
    required this.severityLevel,
    this.probableCondition,
  });

  factory DiagnosisResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosisResponse(
      diagnosisFound: json['diagnosis_found'] ?? false,
      recommendation: json['recommendation'] ?? "I couldn't process that. Please try again.",
      severityLevel: json['severity_level'] ?? "UNKNOWN",
      probableCondition: json['probable_condition'],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}