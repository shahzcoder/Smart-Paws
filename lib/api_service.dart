import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'pet_model.dart';
import 'behaviour_model.dart';

class ApiService {
  // 1. Breed & Nutrition Analyzer URL
  static const String _baseUrl = 'https://breednnutrition-production-fcd4.up.railway.app';
  
  // 2. AI Behavior Checker URL (NEW)
  static const String _behaviorUrl = 'https://petbehavior-production-15b3.up.railway.app';

  // ==========================================
  // MODULE 1: BREED & NUTRITION ANALYZER
  // ==========================================
  Future<PetAnalysisResponse?> analyzePet(File imageFile, String age, String weight) async {
    var uri = Uri.parse('$_baseUrl/analyze-pet');

    var request = http.MultipartRequest('POST', uri);

    // Add the Image File
    var stream = http.ByteStream(imageFile.openRead());
    var length = await imageFile.length();
    
    var multipartFile = http.MultipartFile(
      'file',
      stream,
      length,
      filename: imageFile.path.split('/').last,
    );
    request.files.add(multipartFile);

    // Add Fields (Age and Weight)
    request.fields['age_months'] = age;
    request.fields['weight_kg'] = weight;

    // Send the request
    var response = await request.send();
    
    // Read the response stream into a string ONCE
    var responseData = await response.stream.bytesToString();

    // Handle the different status codes
    if (response.statusCode == 200) {
      // SUCCESS: Parse and return the Pet Model
      var jsonMap = json.decode(responseData);
      return PetAnalysisResponse.fromJson(jsonMap);
      
    } else if (response.statusCode == 400) {
      // GATEKEEPER REJECTION: Not a pet
      var jsonMap = json.decode(responseData);
      // This throws the exact custom message you wrote in main.py
      throw Exception(jsonMap['message']);
      
    } else {
      // ANY OTHER SERVER ERROR
      throw Exception('Server Error: ${response.statusCode}');
    }
  }
  // ==========================================
  // MODULE 2: AI BEHAVIOR CHECKER (NEW)
  // ==========================================
  Future<BehaviorResponse?> analyzeBehavior(String description, File? videoFile) async {
    var uri = Uri.parse('$_behaviorUrl/behavior/analyze');
    var request = http.MultipartRequest('POST', uri);

    // 1. Add Text Description
    request.fields['description'] = description;

    // 2. Add Video File (If provided)
    if (videoFile != null) {
      var stream = http.ByteStream(videoFile.openRead());
      var length = await videoFile.length();
      var multipartFile = http.MultipartFile(
        'video',
        stream,
        length,
        filename: videoFile.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    // 3. Send Request WITH A TIMEOUT (45 Seconds)
    var response = await request.send().timeout(
      const Duration(seconds: 45),
      onTimeout: () {
        throw Exception("The server took too long to respond. Please try again.");
      },
    );
    
    var responseData = await response.stream.bytesToString();
    
    // --- DEBUGGING: See exactly what the AI sent back ---
    print("=== RAW AI RESPONSE ===");
    print(responseData);
    print("=======================");

    // 4. Handle Response safely
    if (response.statusCode == 200) {
      try {
        var jsonMap = json.decode(responseData);
        return BehaviorResponse.fromJson(jsonMap);
      } catch (e) {
        throw Exception("AI output format error. Please try again.");
      }
    } else {
      // If the server fails (e.g. 503, 500, 400), show the ACTUAL error from Python
      try {
        var jsonMap = json.decode(responseData);
        throw Exception(jsonMap['detail'] ?? 'Server Error: ${response.statusCode}');
      } catch (e) {
        throw Exception('Server Error: ${response.statusCode}');
      }
    }
  }
}