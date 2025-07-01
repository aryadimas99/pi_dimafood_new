// search_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pi_dimafood_new/models/menu_model.dart';
import 'package:pi_dimafood_new/screens/detail_menu.dart';
import 'package:intl/intl.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser?.uid;

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  List<MenuModel> searchResults = [];
  bool isSearching = false;

  void _performSearch(String query) async {
    if (query.isEmpty || uid == null) return;

    setState(() => isSearching = true);

    final snapshot = await FirebaseFirestore.instance.collection('menu').get();

    final results =
        snapshot.docs
            .where((doc) {
              final data = doc.data();
              final name = (data['nama'] as String).toLowerCase();
              return name.contains(query.toLowerCase());
            })
            .map((doc) => MenuModel.fromFirestore(doc.id, doc.data()))
            .toList();

    setState(() {
      searchResults = results;
      isSearching = false;
    });

    final userDoc = FirebaseFirestore.instance
        .collection('pencarian_terakhir')
        .doc(uid);
    final userSnapshot = await userDoc.get();
    List<dynamic> keywords = userSnapshot.data()?['keywords'] ?? [];
    if (!keywords.contains(query)) {
      keywords.insert(0, query);
      if (keywords.length > 5) keywords = keywords.sublist(0, 5);
      await userDoc.set({'keywords': keywords});
    }

    final popularDoc = FirebaseFirestore.instance
        .collection('pencarian_populer')
        .doc(query);
    final popularSnapshot = await popularDoc.get();
    if (popularSnapshot.exists) {
      popularDoc.update({'jumlah': FieldValue.increment(1)});
    } else {
      popularDoc.set({'nama': query, 'jumlah': 1});
    }
  }

  void _removeRecentSearch(String keyword) async {
    if (uid == null) return;
    final ref = FirebaseFirestore.instance
        .collection('pencarian_terakhir')
        .doc(uid);
    final snapshot = await ref.get();
    List<dynamic> keywords = snapshot.data()?['keywords'] ?? [];
    keywords.remove(keyword);
    await ref.set({'keywords': keywords});
  }

  Widget _buildSearchResultCard(MenuModel menu) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailMenuPage(menuId: menu.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 245, 245, 245),
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                menu.imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu.nama,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatRupiah.format(menu.harga),
                    style: GoogleFonts.poppins(fontSize: 12),
                  ),
                  Text(
                    menu.status,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color:
                          menu.status.toLowerCase() == 'habis'
                              ? Colors.red
                              : Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset('lib/assets/icons/arrow-circle-left.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari makanan atau minuman...',
            hintStyle: GoogleFonts.inter(fontSize: 14),
            border: InputBorder.none,
          ),
          onSubmitted: _performSearch,
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body:
          isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchController.text.isNotEmpty
              ? ListView(
                children: searchResults.map(_buildSearchResultCard).toList(),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: Text(
                        'Pencarian Terakhir',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('pencarian_terakhir')
                              .doc(uid)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData ||
                            snapshot.data!.data() == null) {
                          return const SizedBox();
                        }

                        final rawData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        List<dynamic> data = rawData['keywords'] ?? [];
                        return Column(
                          children:
                              data.map<Widget>((item) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 3,
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 17,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        item,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      IconButton(
                                        icon: SvgPicture.asset(
                                          'lib/assets/icons/close-circle.svg',
                                          width: 22,
                                        ),
                                        onPressed:
                                            () => _removeRecentSearch(item),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: Text(
                        'Pencarian Populer',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('pencarian_populer')
                              .orderBy('jumlah', descending: true)
                              .limit(10)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 17,
                            vertical: 10,
                          ),
                          child: Wrap(
                            spacing: 10,
                            children:
                                snapshot.data!.docs.map((doc) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final keyword = data['nama'];
                                  return ActionChip(
                                    label: Text(
                                      keyword,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.black),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    onPressed: () {
                                      _searchController.text = keyword;
                                      _performSearch(keyword);
                                    },
                                  );
                                }).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}
