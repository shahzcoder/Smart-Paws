import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  
  final AuthService _auth = AuthService();
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  void _handleRegister() async {
    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);
    String? error = await _auth.signUp(
      email: _emailController.text.trim(),
      password: _passController.text.trim(),
      name: _nameController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (error == null) {
      // Navigate to Home and remove back stack
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (_) => const HomeScreen()), 
          (route) => false
        );
      }
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              const Icon(Icons.pets, color: Color(0xFF00BFA5), size: 50),
              const SizedBox(height: 8),
              const Text("smart\npaws", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 0.9)),
              const SizedBox(height: 30),
              
              const Text("Create your account", style: TextStyle(fontSize: 18, color: Colors.black54)),
              const SizedBox(height: 20),

              _buildTextField("Name", _nameController, false),
              const SizedBox(height: 12),
              _buildTextField("Email", _emailController, false),
              const SizedBox(height: 12),
              _buildTextField("Password", _passController, true, _obscurePass, (val) => setState(() => _obscurePass = val)),
              const SizedBox(height: 12),
              _buildTextField("Confirm Password", _confirmPassController, true, _obscureConfirm, (val) => setState(() => _obscureConfirm = val)),

              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerRight,
                child: Text("Already have an account?", style: TextStyle(color: Colors.grey)),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A8B82),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("Register", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),

              const SizedBox(height: 20),
              const Text("or", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              OutlinedButton.icon(
                onPressed: () {}, // Reuse logic from Login if needed
                icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.black),
                label: const Text("Sign up with google", style: TextStyle(color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  side: const BorderSide(color: Colors.black12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, bool isPass, [bool obscure = false, Function(bool)? onToggle]) {
    return TextField(
      controller: controller,
      obscureText: isPass ? obscure : false,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.black12)),
        suffixIcon: isPass 
          ? IconButton(
              icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => onToggle!(!obscure),
            )
          : IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => controller.clear()),
      ),
    );
  }
}