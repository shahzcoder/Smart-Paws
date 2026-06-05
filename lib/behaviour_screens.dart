import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';
import 'behaviour_model.dart';


class BehaviourInputScreen extends StatefulWidget {
  const BehaviourInputScreen({super.key});

  @override
  State<BehaviourInputScreen> createState() => _BehaviourInputScreenState();
}

class _BehaviourInputScreenState extends State<BehaviourInputScreen> {
  final _descController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  File? _selectedVideo; 
  bool _isAnalyzing = false;

  // Function to open gallery and pick a video
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedVideo = File(pickedFile.path);
      });
    }
  }

  // Real Network Call to FastAPI Server
  void _runRealAnalysis() async {
    if (_descController.text.isEmpty && _selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a description or upload a video.")),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      // Call the real API
      final result = await _apiService.analyzeBehavior(
        _descController.text,
        _selectedVideo,
      );

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      // Navigate and pass the dynamic result!
      if (result != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BehaviourResultScreen(resultData: result),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      
      // Show error banner if something fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9), 
      appBar: AppBar(
        title: const Text("AI Behaviour Checker"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isAnalyzing
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Describe the Issue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text(
                    "What unusual behaviour is your pet showing? (e.g., sudden aggression, hiding, excessive barking)",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _descController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: "Type here...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text("Upload Video (Optional)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Let our AI analyze a brief video clip of the behaviour.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 15),

                  GestureDetector(
                    onTap: _pickVideo, 
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      decoration: BoxDecoration(
                        color: _selectedVideo != null ? const Color(0xFFE8EAF6) : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _selectedVideo != null ? const Color(0xFF5B4DFF) : Colors.grey.shade400,
                          style: BorderStyle.solid,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedVideo != null ? Icons.check_circle : Icons.cloud_upload,
                            size: 50,
                            color: _selectedVideo != null ? const Color(0xFF5B4DFF) : Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _selectedVideo != null 
                              ? _selectedVideo!.path.split('/').last 
                              : "Tap to select a video clip",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedVideo != null ? const Color(0xFF5B4DFF) : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (_selectedVideo != null) ...[
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton.icon(
                        onPressed: () => setState(() => _selectedVideo = null),
                        icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                        label: const Text("Remove Video", style: TextStyle(color: Colors.redAccent)),
                      ),
                    )
                  ],

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _runRealAnalysis,
                      icon: const Icon(Icons.auto_awesome, color: Colors.white),
                      label: const Text(
                        "Analyze Behaviour",
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFF5B4DFF)),
          SizedBox(height: 20),
          Text("AI is analyzing the data...", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
          SizedBox(height: 10),
          Text("Detecting patterns and stress indicators.", style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ==========================================
// SCREEN 2: AI RESULTS & DIAGNOSIS
// ==========================================
class BehaviourResultScreen extends StatelessWidget {
  final BehaviorResponse resultData;

  const BehaviourResultScreen({super.key, required this.resultData});

  Color _parseColor(String colorStr) {
    switch (colorStr.toLowerCase()) {
      case 'orange': return Colors.orange;
      case 'red': return Colors.redAccent;
      case 'amber': return Colors.amber;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _parseIcon(String iconStr) {
    switch (iconStr.toLowerCase()) {
      case 'warning': return Icons.warning_amber_rounded;
      case 'volume': return Icons.volume_up;
      case 'run': return Icons.directions_run;
      case 'home': return Icons.home;
      case 'pets': return Icons.pets;
      case 'school': return Icons.school;
      default: return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        title: const Text("Analysis Results"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Diagnosis Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF5B4DFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Possible Diagnosis", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(resultData.diagnosis, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Confidence Score: ${resultData.confidence}", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Dynamic Indicators
            if (resultData.indicators.isNotEmpty) ...[
              const Text("Detected Indicators", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...resultData.indicators.map((ind) => _buildIndicatorChip(
                    _parseIcon(ind['icon'] ?? ''),
                    ind['text'] ?? '',
                    _parseColor(ind['color'] ?? ''),
                  )).toList(),
              const SizedBox(height: 24),
            ],

            // Dynamic Actions
            if (resultData.actions.isNotEmpty) ...[
              const Text("Recommended Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...resultData.actions.map((act) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildActionCard(
                  icon: Icons.check_circle_outline, 
                  title: act['title'] ?? '',
                  desc: act['desc'] ?? '',
                ),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }

  // UI Helper for Indicators
  Widget _buildIndicatorChip(IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  // UI Helper for Action Cards
  Widget _buildActionCard({required IconData icon, required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE0F7FA),
            child: Icon(icon, color: const Color(0xFF00BFA5)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}