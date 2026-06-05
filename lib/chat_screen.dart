import 'package:flutter/material.dart';
import 'chat_model.dart';
import 'chat_api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatApiService _apiService = ChatApiService();

  // --- Chat State ---
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // --- API State ---
  String? _species; // Required by API
  final List<String> _reportedSymptoms = [];
  final Map<String, String> _followUpAnswers = {};
  String? _lastBotQuestion;

  @override
  void initState() {
    super.initState();
    // Start with a natural, conversational greeting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addBotMessage("Hello! How can I help you today? To get started, is this for a Dog or a Cat?");
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: false));
      _lastBotQuestion = text; 
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text, {bool triggerApi = true}) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
    });
    _scrollToBottom();
    
    if (triggerApi) {
      _handleUserResponse(text);
    }
  }

  // --- Handle Pet Selection ---
  void _selectSpecies(String selectedSpecies) {
    setState(() => _species = selectedSpecies);
    
    // Add the user's choice to the chat screen (no API call yet)
    _addUserMessage(selectedSpecies, triggerApi: false);
    
    // Tiny delay for realism before the bot responds
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return; // Safety check
      _addBotMessage("Great! Please describe the symptoms your $selectedSpecies is experiencing.");
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleUserResponse(String userText) async {
    // ========================================================
    // FYP EDGE CASE PROTECTION: Soft Context Correction
    // ========================================================
    final lowerText = userText.toLowerCase();
    bool hasContradiction = false;
    String oppositeSpecies = "";

    if (_species == "Dog" && (lowerText.contains(" cat ") || lowerText.contains("kitten") || lowerText.startsWith("cat "))) {
      hasContradiction = true;
      oppositeSpecies = "cat";
    } else if (_species == "Cat" && (lowerText.contains(" dog ") || lowerText.contains("puppy") || lowerText.startsWith("dog "))) {
      hasContradiction = true;
      oppositeSpecies = "dog";
    }

    if (hasContradiction) {
      // Softly correct the user, but DO NOT return/stop the execution.
      _addBotMessage("I noticed you mentioned a $oppositeSpecies, but your pet is a $_species. I'm continuing as a $_species. If it's a $oppositeSpecies, please start a new chat.");
    }
    // ========================================================

    setState(() => _isLoading = true);
    
    if (_reportedSymptoms.isEmpty) {
      _reportedSymptoms.add(userText);
    } else {
      if (_lastBotQuestion != null) {
        _followUpAnswers[_lastBotQuestion!] = userText;
      }
    }

    final request = DiagnosisRequest(
      species: _species ?? "Dog", 
      reportedSymptoms: _reportedSymptoms,
      followUpAnswers: _followUpAnswers,
      breed: null, 
      age: null,
    );

    final response = await _apiService.sendDiagnosisRequest(request);

    // ========================================================
    // ERROR FIX: Check if user left the screen before updating UI
    // ========================================================
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response != null) {
      _addBotMessage(response.recommendation);
      
      if (response.severityLevel == "SEVERE" || response.severityLevel == "CRITICAL") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("WARNING: Please consult a vet immediately!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      _addBotMessage("Sorry, I'm having trouble connecting to the server.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5B4DFF)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pets, color: Color(0xFF00BFA5)), 
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'smart\n', 
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, height: 1.0)
                  ),
                  TextSpan(
                    text: 'paws', 
                    style: TextStyle(color: Colors.black, fontSize: 14)
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40), 
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Chat Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _messages.isEmpty
                  ? const Center(child: Text("Start a conversation...", style: TextStyle(color: Colors.grey))) 
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return Align(
                          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: msg.isUser ? const Color(0xFF5B4DFF) : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isUser ? Colors.white : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Input Area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _species == null 
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _selectSpecies("Dog"),
                      icon: const Text("🐶", style: TextStyle(fontSize: 22)),
                      label: const Text("Dog", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B4DFF), 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _selectSpecies("Cat"),
                      icon: const Text("🐱", style: TextStyle(fontSize: 22)),
                      label: const Text("Cat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5), 
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Describe the symptoms...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 140,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoading 
                          ? null 
                          : () {
                              if (_controller.text.trim().isNotEmpty) {
                                _addUserMessage(_controller.text.trim());
                                _controller.clear();
                              }
                            },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B4DFF), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )
                  ],
                ),
          ),
        ],
      ),
    );
  }
}