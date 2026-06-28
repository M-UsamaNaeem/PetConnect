import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../services/notification_service.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({Key? key}) : super(key: key);

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  String _selectedCategory = 'Food';

  final List<String> _categories = [
    'Food',
    'Accessories',
    'Adoption',
    'Services',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 65,
      maxWidth: 700,
    );

    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _postListing() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all fields and add an image.', style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() as Map<String, dynamic>;

      List<int> imageBytes = await _image!.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      await FirebaseFirestore.instance.collection('marketplace').add({
        'sellerId': user.uid,
        'sellerName': userData['username'],
        'sellerImage': userData['profileImage'],
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'category': _selectedCategory,
        'image': base64Image,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Get all other users to notify them about the new product
      final usersSnap = await FirebaseFirestore.instance.collection('users').limit(50).get();
      for (var doc in usersSnap.docs) {
        if (doc.id != user.uid) {
          await NotificationService.sendNotification(
            targetUserId: doc.id,
            type: 'marketplace_new',
            fromUsername: userData['username'] ?? 'Seller',
            fromUserId: user.uid,
            userImage: userData['profileImage'],
            message: "posted a new item: ${_titleController.text.trim()} 🛍️",
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Listing created successfully!', style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e', style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Listing',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppConstants.textPrimary),
        ),
        leading: BackButton(color: isDark ? Colors.white : AppConstants.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.darkCard : AppConstants.creamLight,
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  image: _image != null
                      ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover)
                      : null,
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: _image == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_rounded,
                            size: 48,
                            color: AppConstants.primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Add Product Image',
                            style: GoogleFonts.fredoka(
                              color: isDark ? Colors.white70 : AppConstants.textWarm,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              style: GoogleFonts.fredoka(color: isDark ? Colors.white : AppConstants.textPrimary, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Listing Title',
                labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppConstants.textSecondary),
                filled: true,
                fillColor: isDark ? AppConstants.darkCard : AppConstants.creamLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.inputRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.fredoka(color: isDark ? Colors.white : AppConstants.textPrimary, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Price (\$)',
                      labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppConstants.textSecondary),
                      filled: true,
                      fillColor: isDark ? AppConstants.darkCard : AppConstants.creamLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppConstants.textSecondary),
                      filled: true,
                      fillColor: isDark ? AppConstants.darkCard : AppConstants.creamLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    dropdownColor: isDark ? AppConstants.darkSurface : Colors.white,
                    style: GoogleFonts.fredoka(
                      color: isDark ? Colors.white : AppConstants.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 4,
              style: GoogleFonts.fredoka(color: isDark ? Colors.white : AppConstants.textPrimary, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : AppConstants.textSecondary),
                filled: true,
                fillColor: isDark ? AppConstants.darkCard : AppConstants.creamLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.inputRadius),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                : SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _postListing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.darkCapsule,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Post Listing',
                        style: GoogleFonts.fredoka(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
