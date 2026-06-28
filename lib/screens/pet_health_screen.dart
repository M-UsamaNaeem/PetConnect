import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';

class PetHealthScreen extends StatefulWidget {
  const PetHealthScreen({Key? key}) : super(key: key);

  @override
  State<PetHealthScreen> createState() => _PetHealthScreenState();
}

class _PetHealthScreenState extends State<PetHealthScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  void _addHealthEntry() {
    final titleCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String category = 'Vet Visit';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppConstants.darkSurface : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.cardRadius)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Add Health Entry 🩺',
                    style: GoogleFonts.fredoka(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppConstants.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: category,
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
                    items: ['Vet Visit', 'Vaccination', 'Medication', 'Weight']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: titleCtrl,
                    style: GoogleFonts.fredoka(color: isDark ? Colors.white : AppConstants.textPrimary, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Title',
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
                  const SizedBox(height: 15),
                  TextField(
                    controller: weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.fredoka(color: isDark ? Colors.white : AppConstants.textPrimary, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Weight (lbs/kg)',
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
                  const SizedBox(height: 15),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 3,
                    style: GoogleFonts.fredoka(color: isDark ? Colors.white : AppConstants.textPrimary, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Notes',
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
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.darkCapsule,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (titleCtrl.text.isNotEmpty) {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('health')
                              .add({
                            'category': category,
                            'title': titleCtrl.text,
                            'weight': weightCtrl.text,
                            'notes': notesCtrl.text,
                            'timestamp': DateTime.now().toIso8601String(),
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        'Save Entry',
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
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Pet Health Diary 🩺',
          style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppConstants.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_rounded, color: AppConstants.primaryColor, size: 28),
            onPressed: _addHealthEntry,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('health')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.health_and_safety_rounded,
                    size: 80,
                    color: AppConstants.primaryColor.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No health records yet 🐾',
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Keep track of vet visits, vaccines & weight!',
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          final records = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final data = records[index].data() as Map<String, dynamic>;
              final date = DateTime.parse(data['timestamp']);
              final formattedDate =
                  "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

              IconData icon;
              Color color;
              Color bgTint;
              switch (data['category']) {
                case 'Vet Visit':
                  icon = Icons.local_hospital_rounded;
                  color = const Color(0xFF4A90E2); // soft blue
                  bgTint = const Color(0xFFE8F2FF);
                  break;
                case 'Vaccination':
                  icon = Icons.vaccines_rounded;
                  color = const Color(0xFF2ECC71); // soft green
                  bgTint = const Color(0xFFEAF9EE);
                  break;
                case 'Weight':
                  icon = Icons.monitor_weight_rounded;
                  color = const Color(0xFFF39C12); // soft orange
                  bgTint = const Color(0xFFFEF5E7);
                  break;
                default:
                  icon = Icons.medication_rounded;
                  color = AppConstants.primaryColor; // coral
                  bgTint = const Color(0xFFFFEAEA);
              }

              if (isDark) {
                bgTint = color.withValues(alpha: 0.15);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.cardRadius),
                  boxShadow: isDark ? [] : AppConstants.cardShadow,
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgTint,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? 'Record',
                              style: GoogleFonts.fredoka(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppConstants.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            if (data['weight'] != null && data['weight'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.05) : AppConstants.creamLight,
                                    borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                                  ),
                                  child: Text(
                                    'Weight: ${data['weight']}',
                                    style: GoogleFonts.fredoka(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white70 : AppConstants.textWarm,
                                    ),
                                  ),
                                ),
                              ),
                            if (data['notes'] != null && data['notes'].toString().isNotEmpty)
                              Text(
                                data['notes'],
                                style: GoogleFonts.fredoka(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white70 : AppConstants.textSecondary,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              formattedDate,
                              style: GoogleFonts.fredoka(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white38 : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                        onPressed: () {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('health')
                              .doc(records[index].id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
