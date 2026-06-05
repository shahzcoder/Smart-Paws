class BehaviorResponse {
  final String diagnosis;
  final String confidence;
  final List<dynamic> indicators;
  final List<dynamic> actions;

  BehaviorResponse({
    required this.diagnosis,
    required this.confidence,
    required this.indicators,
    required this.actions,
  });

  factory BehaviorResponse.fromJson(Map<String, dynamic> json) {
    // 1. Safely handle diagnosis (if AI returns empty string or null)
    String parsedDiagnosis = json['diagnosis']?.toString() ?? 'Behavior Analyzed';
    if (parsedDiagnosis.trim().isEmpty) {
      parsedDiagnosis = 'Behavior Analyzed';
    }

    // 2. Safely handle confidence
    String parsedConfidence = json['confidence']?.toString() ?? 'N/A';

    // 3. Bulletproof List Parsing (prevents crashes if AI returns a String instead of a List)
    List<dynamic> parsedIndicators = [];
    if (json['indicators'] is List) {
      parsedIndicators = json['indicators'];
    }

    List<dynamic> parsedActions = [];
    if (json['actions'] is List) {
      parsedActions = json['actions'];
    }

    // 4. Fallback if AI gave us absolutely no actions
    if (parsedActions.isEmpty) {
      parsedActions.add({
        "title": "General Advice",
        "desc": "Please consult with a local veterinarian for a professional assessment."
      });
    }

    return BehaviorResponse(
      diagnosis: parsedDiagnosis,
      confidence: parsedConfidence,
      indicators: parsedIndicators,
      actions: parsedActions,
    );
  }
}