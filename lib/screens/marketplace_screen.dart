import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_listing_screen.dart';
import 'listing_detail_screen.dart';
import '../utils/constants.dart';

class MarketplaceScreen extends StatefulWidget {
  final String initialCategory;
  const MarketplaceScreen({Key? key, this.initialCategory = 'All'}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String currentUid = FirebaseAuth.instance.currentUser!.uid;
  late String _selectedCategory;

  final List<String> _categories = ['All', 'Food', 'Accessories', 'Adoption', 'Services'];

  final Map<String, IconData> _categoryIcons = {
    'All': Icons.grid_view_rounded,
    'Food': Icons.restaurant_rounded,
    'Accessories': Icons.checkroom_rounded,
    'Adoption': Icons.pets_rounded,
    'Services': Icons.medical_services_rounded,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Pet Marketplace', style: GoogleFonts.fredoka(fontWeight: FontWeight.w800)),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppConstants.textPrimary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateListingScreen()));
            },
            tooltip: 'Add Listing',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Browse'), Tab(text: 'My Listings')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrowseTab(isDark),
          _buildMyListingsTab(isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateListingScreen()));
        },
        backgroundColor: AppConstants.darkCapsule,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Sell', style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
    );
  }

  Widget _buildBrowseTab(bool isDark) {
    return Column(
      children: [
        // Categories
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppConstants.primaryColor : (isDark ? AppConstants.darkCard : Colors.white),
                      borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                      border: isSelected ? null : Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(_categoryIcons[category], size: 16, color: isSelected ? Colors.white : AppConstants.primaryColor),
                        const SizedBox(width: 6),
                        Text(category, style: GoogleFonts.fredoka(
                          color: isSelected ? Colors.white : (isDark ? Colors.white : AppConstants.textPrimary),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        )),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Listings
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _selectedCategory == 'All'
                ? FirebaseFirestore.instance.collection('marketplace').orderBy('timestamp', descending: true).limit(30).snapshots()
                : FirebaseFirestore.instance.collection('marketplace').where('category', isEqualTo: _selectedCategory).limit(30).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Center(child: Text('Something went wrong', style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)));
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));

              final listings = snapshot.data!.docs;
              if (listings.isEmpty) {
                return Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_rounded, size: 60, color: AppConstants.secondaryColor.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text('No listings found', style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, color: AppConstants.textSecondary)),
                  ],
                ));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final data = listings[index].data() as Map<String, dynamic>;
                  final id = listings[index].id;
                  return _buildListingCard(id, data, isDark);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMyListingsTab(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('marketplace').where('sellerId', isEqualTo: currentUid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Something went wrong', style: GoogleFonts.fredoka(fontWeight: FontWeight.w600)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));

        final listings = snapshot.data!.docs;
        if (listings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront_rounded, size: 64, color: AppConstants.textSecondary.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('You have no listings', style: GoogleFonts.fredoka(fontWeight: FontWeight.w700, color: AppConstants.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateListingScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius)),
                  ),
                  child: Text('Add Listing', style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final data = listings[index].data() as Map<String, dynamic>;
            final id = listings[index].id;
            return _buildListingCard(id, data, isDark, isMine: true);
          },
        );
      },
    );
  }

  Widget _buildListingCard(String id, Map<String, dynamic> data, bool isDark, {bool isMine = false}) {
    ImageProvider? imageProvider;
    if (data['image'] != null && data['image'].isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(data['image']));
      } catch (e) {}
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ListingDetailScreen(listingId: id, data: data)));
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          boxShadow: isDark ? [] : AppConstants.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.darkSurface : Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                ),
                child: imageProvider == null
                    ? Center(child: Icon(Icons.image, color: Colors.grey.shade300, size: 50))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? 'Item',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.pillRadius),
                    ),
                    child: Text(
                      '\$${data['price']}',
                      style: GoogleFonts.fredoka(color: AppConstants.primaryColor, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data['sellerName'] ?? 'Seller',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.fredoka(fontSize: 11, color: AppConstants.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (isMine)
                        GestureDetector(
                          onTap: () {
                            FirebaseFirestore.instance.collection('marketplace').doc(id).delete();
                          },
                          child: const Icon(Icons.delete_rounded, color: AppConstants.primaryColor, size: 18),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
