import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart'; 
import 'api_service.dart';
import 'pet_model.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  File? _selectedImage;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  bool _isLoading = false;
  PetAnalysisResponse? _result;
  final ApiService _apiService = ApiService();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = null; // Reset results on new image
      });
    }
  }

  Future<void> _analyzePet() async {
    if (_selectedImage == null || _ageController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image and fill in details')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null; // Clear previous results before starting
    });

    try {
      // Call your API Service
      final result = await _apiService.analyzePet(
        _selectedImage!,
        _ageController.text,
        _weightController.text,
      );

      // If successful, show the results
      if (!mounted) return;
      setState(() {
        _result = result;
        _isLoading = false;
      });

    } catch (e) {
      // IF THE GATEKEEPER FAILS, IT LANDS HERE!
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      // Show the red warning banner with the specific message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''), // Cleans up the text
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating, // Makes it float above the bottom slightly
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Smart Paws Analyzer"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- IMAGE UPLOAD SECTION ---
            GestureDetector(
              onTap: _pickImage,
              child: DottedBorder(
                color: Colors.grey.shade400,
                strokeWidth: 1,
                dashPattern: const [8, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B4DFF).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Color(0xFF5B4DFF), size: 30),
                            ),
                            const SizedBox(height: 12),
                            const Text("Upload Pet Photo", style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- INPUT FIELDS ---
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Age (Months)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Weight (kg)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- ANALYZE BUTTON ---
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _analyzePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B4DFF), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Analyze Breed & Diet", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(height: 24),

            // --- RESULTS SECTION ---
            if (_result != null) ...[
              const Text("Results", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              
              // Breed Result Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_result!.breedName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _result!.confidenceScore,
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 24),
                    const Text("Nutrition Plan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _buildNutritionItem(Icons.local_fire_department, "Daily Calories", _result!.nutritionPlan.dailyCalories),
                    _buildNutritionItem(Icons.fitness_center, "Protein", _result!.nutritionPlan.proteinRequirements),
                    _buildNutritionItem(Icons.restaurant, "Recommended Food", _result!.nutritionPlan.recommendedFood),
                    _buildNutritionItem(Icons.schedule, "Schedule", _result!.nutritionPlan.feedingSchedule),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF5B4DFF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}