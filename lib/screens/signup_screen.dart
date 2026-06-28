import 'dart:convert'; // For Base64
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

const _petTypes = ['Dog', 'Cat', 'Bird', 'Rabbit', 'Fish', 'Hamster', 'Turtle', 'Parrot', 'Guinea Pig', 'Other'];

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _petNameController = TextEditingController();
  final _breedController = TextEditingController();

  String? _selectedPetType;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isObscured = true;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 65,
      maxWidth: 700,
    );
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _signUp() async {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      String? base64Image;
      if (_selectedImage != null) {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'uid': userCred.user!.uid,
        'profileImage': base64Image,
        'bio': 'New to PetConnect! 🐾',
        'followers': 0,
        'following': 0,
        'posts': 0,
        'petName': _petNameController.text.trim(),
        'petType': _selectedPetType ?? '',
        'breed': _breedController.text.trim(),
      });

      final welcomeMessages = [
        "Welcome! Remember: you don't own your pet, they own you. Tap here to accept your fate. 🐾",
        "Welcome to PetConnect! Your pet already likes this app more than they like you. 🐾",
        "Welcome! We're here to help you connect, because let's face it: your pet is the only reason you have friends. 🐾"
      ];
      final welcomeMsg = welcomeMessages[DateTime.now().millisecond % welcomeMessages.length];

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCred.user!.uid)
          .collection('notifications')
          .add({
        'type': 'welcome',
        'fromId': 'system',
        'username': 'PetConnect Team',
        'userImage': '',
        'message': welcomeMsg,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Account Created! Please Login.")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.modernBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppConstants.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53), Color(0xFFF8BBD0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Paw prints
                    Positioned(top: 50, right: 30, child: Opacity(opacity: 0.08, child: Transform.rotate(angle: 0.3, child: const Icon(Icons.pets, size: 60, color: Colors.white)))),
                    Positioned(bottom: 30, left: 20, child: Opacity(opacity: 0.06, child: Transform.rotate(angle: -0.4, child: const Icon(Icons.pets, size: 50, color: Colors.white)))),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 16, spreadRadius: 2)],
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: Colors.white24,
                              backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
                              child: _selectedImage == null
                                  ? const Icon(Icons.add_a_photo_rounded, size: 36, color: Colors.white)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text("Tap to add photo", style: GoogleFonts.fredoka(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text("Create Account", style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("Account Info"),
                  const SizedBox(height: 10),
                  _buildTextField(_usernameController, "Username *", Icons.person_rounded),
                  const SizedBox(height: 12),
                  _buildTextField(_emailController, "Email *", Icons.email_rounded),
                  const SizedBox(height: 12),
                  _buildTextField(_passwordController, "Password *", Icons.lock_rounded, isPassword: true),

                  const SizedBox(height: 28),
                  _sectionLabel("Your Pet Info 🐾"),
                  const SizedBox(height: 10),
                  _buildTextField(_petNameController, "Pet Name (e.g. Luna)", Icons.pets_rounded),
                  const SizedBox(height: 12),

                  // Pet Type Dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppConstants.inputRadius),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedPetType,
                        hint: Row(children: [
                          const Icon(Icons.category_rounded, color: AppConstants.primaryColor, size: 22),
                          const SizedBox(width: 12),
                          Text("Pet Type", style: GoogleFonts.fredoka(color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
                        ]),
                        items: _petTypes.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type, style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
                        )).toList(),
                        onChanged: (val) => setState(() => _selectedPetType = val),
                        dropdownColor: Colors.white,
                        icon: const Icon(Icons.expand_more_rounded, color: AppConstants.primaryColor),
                        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  _buildTextField(_breedController, "Breed (e.g. Golden Retriever)", Icons.info_outline_rounded),

                  const SizedBox(height: 36),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                      : SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConstants.darkCapsule,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.pets_rounded, size: 20, color: Colors.white),
                                const SizedBox(width: 10),
                                Text("Create Account", style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, fontSize: 16, color: AppConstants.textPrimary, letterSpacing: 0.3),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isPassword = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isObscured : false,
        style: GoogleFonts.fredoka(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.fredoka(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          prefixIcon: Icon(icon, color: AppConstants.primaryColor, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _isObscured = !_isObscured),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
