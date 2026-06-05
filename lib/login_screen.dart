import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _isLoading = false;
  bool _obscureText = true;

  // --- 1. EMAIL/PASSWORD LOGIN ---
  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    String? error = await _auth.signIn(
      email: _emailController.text.trim(),
      password: _passController.text.trim(),
    );

    // Safety Check
    if (!mounted) return;
    
    setState(() => _isLoading = false);

    if (error == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  // --- 2. GOOGLE LOGIN ---
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    
    // Perform Async Login
    String? error = await _auth.signInWithGoogle();

    // Safety Check: If user closed app/screen, stop here.
    if (!mounted) return; 

    // Stop Loading (Only once)
    setState(() => _isLoading = false);
    
    // Handle Result
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  // --- 3. FORGOT PASSWORD DIALOG ---
  // --- 3. FORGOT PASSWORD DIALOG ---
  void _handleForgotPassword() {
    // Pre-fill the reset dialog if they already typed an email
    final _resetEmailController = TextEditingController(text: _emailController.text);

    showDialog(
      context: context,
      // FIX 1: Rename this to 'dialogContext' so it doesn't shadow the main screen's context
      builder: (dialogContext) { 
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your email address and we will send you a link to reset your password."),
              const SizedBox(height: 16),
              TextField(
                controller: _resetEmailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), 
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A8B82), // Teal color
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (_resetEmailController.text.isEmpty) return;
                
                // FIX 2: Save the messenger state BEFORE destroying the dialog
                final messenger = ScaffoldMessenger.of(context);
                
                // Close the dialog using its specific context
                Navigator.pop(dialogContext); 
                
                // Show loading message safely using the saved messenger
                messenger.showSnackBar(
                  const SnackBar(content: Text("Sending reset link..."))
                );

                // Call Firebase to send the email
                String? error = await _auth.resetPassword(email: _resetEmailController.text.trim());

                if (!mounted) return;

                // Show success or error popup safely using the saved messenger
                if (error == null) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text("Password reset email sent! Check your inbox."),
                      backgroundColor: Colors.green,
                    )
                  );
                } else {
                  messenger.showSnackBar(SnackBar(content: Text(error)));
                }
              }, 
              child: const Text("Send Link", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      body: SafeArea(
        // 1. Center keeps it vertically aligned when keyboard is hidden
        child: Center( 
          // 2. SingleChildScrollView allows scrolling when keyboard is visible
          child: SingleChildScrollView( 
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const Icon(Icons.pets, color: Color(0xFF00BFA5), size: 60),
                const SizedBox(height: 10),
                const Text("smart\npaws", 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 0.9)
                ),
                const SizedBox(height: 50),

                // Inputs
                _buildTextField("Email", _emailController, false),
                const SizedBox(height: 16),
                _buildTextField("Password", _passController, true),
                
                // Forget Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword, // --- TRIGGER ADDED HERE ---
                    child: const Text("Forget Password?", style: TextStyle(color: Colors.grey))
                  ),
                ),

                // Don't have account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text("Don't have any account? ", style: TextStyle(color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                      child: const Text("Register", style: TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A8B82), // Teal color
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("Log In", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                
                const SizedBox(height: 20),
                const Text("or", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),

                // Google Button
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  icon: const Icon(Icons.g_mobiledata, size: 30, color: Colors.black),
                  label: const Text("Login with google", style: TextStyle(color: Colors.black)),
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
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, bool isPass) {
    return TextField(
      controller: controller,
      obscureText: isPass ? _obscureText : false,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        suffixIcon: isPass 
          ? IconButton(
              icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
              onPressed: () => setState(() => _obscureText = !_obscureText),
            )
          : IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => controller.clear()),
      ),
    );
  }
}