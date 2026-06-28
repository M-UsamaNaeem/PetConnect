import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/constants.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false;
  bool _isGeneratingCaption = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 65,
      maxWidth: 700,
    );

    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _generateAICaption() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pick an image first!")));
      return;
    }
    setState(() => _isGeneratingCaption = true);
    try {
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: AppConstants.geminiApiKey);
      final imageBytes = await _selectedImage!.readAsBytes();
      final prompt = TextPart("Write a short, cute Instagram caption for this pet photo with emojis.");
      final imagePart = DataPart('image/jpeg', imageBytes);
      final response = await model.generateContent([Content.multi([prompt, imagePart])]);
      if (response.text != null) setState(() => _captionController.text = response.text!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("AI Error: $e")));
    } finally {
      setState(() => _isGeneratingCaption = false);
    }
  }

  Future<void> _sharePost() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select an image")));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>;

      List<int> imageBytes = await _selectedImage!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid,
        'username': userData['username'],
        'userProfileImage': userData['profileImage'],
        'postImage': base64Image,
        'caption': _captionController.text,
        'likes': 0,
        'timestamp': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post Shared Successfully! 🐾')));
      setState(() { _selectedImage = null; _captionController.clear(); });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("New Post", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity, height: 350,
                  decoration: BoxDecoration(
                    color: isDark ? AppConstants.darkCard : Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                    image: _selectedImage != null ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover) : null,
                    border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200, width: 2),
                    boxShadow: isDark ? [] : AppConstants.cardShadow,
                  ),
                  child: _selectedImage == null
                      ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.camera_alt_rounded, size: 56, color: AppConstants.primaryColor.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text('Tap to select photo', style: GoogleFonts.fredoka(color: AppConstants.textSecondary, fontSize: 16, fontWeight: FontWeight.w600)),
                        ])
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Caption + AI button
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: TextField(
                  controller: _captionController,
                  maxLines: 3,
                  style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppConstants.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Write a caption...',
                    filled: true,
                    fillColor: isDark ? AppConstants.darkCard : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.inputRadius), borderSide: BorderSide.none),
                    hintStyle: GoogleFonts.fredoka(color: isDark ? Colors.white38 : Colors.grey.shade400, fontWeight: FontWeight.w500),
                  ),
                )),
                const SizedBox(width: 10),
                Column(children: [
                  _isGeneratingCaption
                      ? const Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2, color: AppConstants.primaryColor))
                      : Container(
                          decoration: BoxDecoration(
                            gradient: AppConstants.warmGradient,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _generateAICaption,
                            icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                            tooltip: "Generate AI Caption",
                          ),
                        ),
                  const SizedBox(height: 4),
                  Text("AI Magic", style: GoogleFonts.fredoka(fontSize: 10, color: AppConstants.primaryColor, fontWeight: FontWeight.w700)),
                ])
              ]),
              const SizedBox(height: 30),

              // Share button
              _isLoading
                  ? const CircularProgressIndicator(color: AppConstants.primaryColor)
                  : SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
                      onPressed: _sharePost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.darkCapsule,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        const Icon(Icons.send_rounded, size: 20, color: Colors.white),
                        const SizedBox(width: 10),
                        Text('Share Post', style: GoogleFonts.fredoka(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      ]),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
