import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pi_dimafood_new/screens/detail_menu.dart';
import 'package:pi_dimafood_new/widgets/search_menu.dart';
import 'package:pi_dimafood_new/models/menu_model.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _selectedCategory = 'Semua';

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _onChipTap(String label) {
    setState(() => _selectedCategory = label);
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => _onChipTap(label),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color.fromARGB(255, 255, 0, 0)
                  : Colors.transparent,
          border: Border.all(color: const Color.fromARGB(255, 0, 127, 254)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 0, 127, 254)),
            color: const Color.fromARGB(255, 40, 188, 221),
          ),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: const Center(child: SearchMenu()),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Kategori",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip("Semua"),
                const SizedBox(width: 8),
                _buildCategoryChip("Makanan"),
                const SizedBox(width: 8),
                _buildCategoryChip("Minuman"),
                const SizedBox(width: 8),
                _buildCategoryChip("Dessert"),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(255, 0, 127, 254)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('menu').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Tidak ada menu'));
                }

                final allMenus =
                    snapshot.data!.docs
                        .map(
                          (doc) => MenuModel.fromFirestore(
                            doc.id,
                            doc.data() as Map<String, dynamic>,
                          ),
                        )
                        .toList();

                final filtered =
                    allMenus.where((menu) {
                      if (_selectedCategory == 'Semua') return menu.isPopuler;
                      return menu.kategori == _selectedCategory;
                    }).toList();

                // Grid responsif: jika lebar <600, 2 kolom, jika >=600, 3 kolom
                int crossAxisCount = screenWidth < 600 ? 2 : 3;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                      child: Text(
                        _selectedCategory == 'Semua'
                            ? "Populer Hari Ini"
                            : _selectedCategory,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        itemCount: filtered.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 3 / 3.3,
                        ),
                        itemBuilder: (context, index) {
                          final menu = filtered[index];
                          return GestureDetector(
                            onTap:
                                menu.status == 'Habis'
                                    ? null
                                    : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                DetailMenuPage(menuId: menu.id),
                                      ),
                                    ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      menu.status == 'Habis'
                                          ? Colors.red
                                          : const Color.fromARGB(
                                            255,
                                            0,
                                            127,
                                            254,
                                          ),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                              ),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: Opacity(
                                          opacity:
                                              menu.status == 'Habis' ? 0.5 : 1,
                                          child: Image.network(
                                            menu.imageUrl,
                                            height: screenWidth * 0.25,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(
                                                      Icons.broken_image,
                                                    ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              menu.nama,
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              menu.jenis,
                                              style: GoogleFonts.inter(
                                                fontSize: 10,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              formatRupiah.format(menu.harga),
                                              style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (menu.status == 'Habis')
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          'Habis',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
