import 'package:flutter/material.dart';
import 'vet_screens.dart';
import 'auth_service.dart';
import 'analyze_screen.dart';
import 'chat_screen.dart';
import 'vaccine_screens.dart';
import 'login_screen.dart';
import 'behaviour_screens.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get user name to display from your AuthService
    final user = AuthService().currentUser;
    final displayName = user?.displayName ?? "User";

    // 2. Color Palette matching your logo and theme
    final Color primaryTeal = const Color(0xFF00BFA5); 
    final Color bgColor = const Color(0xFFF3F5F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // ── HEADER SECTION ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, color: primaryTeal, size: 40),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("smart", style: TextStyle(fontSize: 22, height: 1.0, color: Colors.black87)),
                      Text("paws", style: TextStyle(fontSize: 22, height: 1.0, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 10),
              
              Text(
                "Welcome, $displayName",
                style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),

              // ── MODULE GRID ────────────────────────────────────────
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,           // 2 columns
                  crossAxisSpacing: 16,        // Space between columns
                  mainAxisSpacing: 16,         // Space between rows
                  childAspectRatio: 1.05,      // Slightly taller than wide
                  children: [
                    _buildModuleCard(
                      context: context,
                      title: "Symptom\nChecker",
                      icon: Icons.health_and_safety_outlined,
                      primaryTeal: primaryTeal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChatScreen()),
                        );
                      },
                    ),
                    _buildModuleCard(
                      context: context,
                      title: "Behaviour\nChecker",
                      icon: Icons.psychology_outlined,
                      primaryTeal: primaryTeal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BehaviourInputScreen()),
                        );
                      },
                    ),
                    _buildModuleCard(
                      context: context,
                      title: "Breed &\nNutrition",
                      icon: Icons.restaurant_menu_outlined,
                      primaryTeal: primaryTeal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AnalyzeScreen()),
                        );
                      },
                    ),
                    _buildModuleCard(
                      context: context,
                      title: "Vet Support\n& Booking",
                      icon: Icons.local_hospital_outlined,
                      primaryTeal: primaryTeal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VetListScreen()),
                        );
                      },
                    ),
                    _buildModuleCard(
                      context: context,
                      title: "Vaccination\nRecords",
                      icon: Icons.vaccines_outlined,
                      primaryTeal: primaryTeal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VaccineListScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      // ── LOGOUT BUTTON ──────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // 1. Show Toast
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Logged out successfully"),
              duration: Duration(seconds: 2),
            ),
          );

          // 2. Sign Out
          await AuthService().signOut();

          // 3. Force Navigation to Login
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false, // Removes all previous screens
            );
          }
        },
        backgroundColor: const Color(0xFF40E0D0),
        elevation: 2,
        icon: const Icon(Icons.logout, color: Colors.white, size: 20),
        label: const Text(
          "Log out", 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
        ),
      ),
    );
  }

  // ── CUSTOM CARD WIDGET ─────────────────────────────────────────────
  Widget _buildModuleCard({
    required BuildContext context, 
    required String title, 
    required IconData icon, 
    required Color primaryTeal,
    required VoidCallback onTap
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2, 
      shadowColor: Colors.black.withOpacity(0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryTeal.withOpacity(0.15), 
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36, color: primaryTeal),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w700, 
                  fontSize: 14, 
                  color: Colors.black87,
                  height: 1.2
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}