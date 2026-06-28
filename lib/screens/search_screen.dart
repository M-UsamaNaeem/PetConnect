import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petconnect/utils/constants.dart';
import 'profile_screen.dart';

const _petKeywords = ['cat', 'dog', 'bird', 'rabbit', 'fish', 'hamster', 'turtle', 'parrot', 'guinea pig', 'other'];

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _recentSearches = [];
  bool _showResults = false;
  bool _isPetTypeSearch = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _recentSearches = prefs.getStringList('recent_searches') ?? []);
  }

  Future<void> _saveSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) _recentSearches = _recentSearches.sublist(0, 8);
    await prefs.setStringList('recent_searches', _recentSearches);
    setState(() {});
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() => _recentSearches = []);
  }

  void _onSearchChanged(String val) {
    final lower = val.toLowerCase().trim();
    final isPet = _petKeywords.contains(lower);
    setState(() {
      _showResults = val.isNotEmpty;
      _isPetTypeSearch = isPet;
    });
  }

  void _selectRecent(String term) {
    _searchController.text = term;
    _onSearchChanged(term);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppConstants.darkCard : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                  boxShadow: isDark ? [] : AppConstants.cardShadow,
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: GoogleFonts.fredoka(color: isDark ? Colors.white : AppConstants.textPrimary, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Search users, or type "cat", "dog"...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppConstants.primaryColor),
                    suffixIcon: _showResults
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    hintStyle: GoogleFonts.fredoka(color: isDark ? Colors.white38 : Colors.grey.shade400, fontWeight: FontWeight.w500),
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: (val) => _saveSearch(val),
                ),
              ),
            ),

            // Pet type chip hint
            if (_isPetTypeSearch)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppConstants.warmGradient,
                      borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                    ),
                    child: Text(
                      '🐾 Showing profiles with ${_searchController.text} pets',
                      style: GoogleFonts.fredoka(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ]),
              ),

            Expanded(
              child: _showResults
                  ? _buildSearchResults()
                  : _buildRecentSearches(isDark, cardColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(bool isDark, Color cardColor) {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_rounded, size: 72, color: AppConstants.secondaryColor.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text("Search for friends or pets! 🐾",
                style: GoogleFonts.fredoka(fontSize: 16, color: AppConstants.textSecondary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Try "cat" or "dog" to find pet profiles',
                style: GoogleFonts.fredoka(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
          child: Row(children: [
            Text("Recent Searches", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, fontSize: 15, color: isDark ? Colors.white70 : AppConstants.textPrimary)),
            const Spacer(),
            TextButton(
              onPressed: _clearRecentSearches,
              child: Text("Clear all", style: GoogleFonts.fredoka(color: AppConstants.primaryColor, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        ..._recentSearches.map((term) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppConstants.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.history_rounded, color: AppConstants.primaryColor, size: 18),
          ),
          title: Text(term, style: GoogleFonts.fredoka(fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppConstants.textPrimary)),
          trailing: IconButton(
            icon: Icon(Icons.north_west_rounded, size: 16, color: Colors.grey.shade400),
            onPressed: () => _selectRecent(term),
          ),
          onTap: () => _selectRecent(term),
        )),
      ],
    );
  }

  Widget _buildSearchResults() {
    final query = _searchController.text.trim();

    if (_isPetTypeSearch) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('petType', isEqualTo: query[0].toUpperCase() + query.substring(1))
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No ${query} profiles found yet 🐾",
                style: GoogleFonts.fredoka(color: AppConstants.textSecondary, fontWeight: FontWeight.w600)));
          }
          return _buildUserList(snapshot.data!.docs, saveSearch: false);
        },
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThan: '${query}z')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No users found for \"$query\"",
              style: GoogleFonts.fredoka(color: AppConstants.textSecondary, fontWeight: FontWeight.w600)));
        }
        return _buildUserList(snapshot.data!.docs, saveSearch: true);
      },
    );
  }

  Widget _buildUserList(List<QueryDocumentSnapshot> docs, {bool saveSearch = true}) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final data = docs[index].data() as Map<String, dynamic>;
        Uint8List? imageBytes;
        try { if (data['profileImage'] != null) imageBytes = base64Decode(data['profileImage']); } catch (e) {}

        final petType = data['petType'] as String?;
        final petName = data['petName'] as String?;

        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + index * 50),
          tween: Tween(begin: 0, end: 1),
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            leading: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppConstants.storyRingGradient),
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[200],
                backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                child: imageBytes == null ? const Icon(Icons.person) : null,
              ),
            ),
            title: Text(data['username'] ?? "Unknown", style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((data['bio'] ?? "").isNotEmpty)
                  Text(data['bio'], maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.w500)),
                if (petName != null || petType != null)
                  Text(
                    [if (petName != null && petName.isNotEmpty) '🐾 $petName', if (petType != null && petType.isNotEmpty) petType].join(' • '),
                    style: GoogleFonts.fredoka(fontSize: 11, color: AppConstants.primaryColor.withOpacity(0.8), fontWeight: FontWeight.w700),
                  ),
              ],
            ),
            onTap: () {
              if (saveSearch) _saveSearch(_searchController.text.trim());
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen(userId: docs[index].id)));
            },
          ),
        );
      },
    );
  }
}
