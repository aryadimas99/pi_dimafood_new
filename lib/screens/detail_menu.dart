import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pi_dimafood_new/models/cart_item.dart';
import 'package:pi_dimafood_new/controllers/cart_controller.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';

class DetailMenuPage extends StatefulWidget {
  final String menuId;

  const DetailMenuPage({super.key, required this.menuId});

  @override
  State<DetailMenuPage> createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  DocumentSnapshot? menuData;
  bool isLoading = true;

  int quantity = 0;
  String selectedSize = '';
  final TextEditingController noteController = TextEditingController();

  int basePrice = 0;
  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void incrementQuantity() => setState(() => quantity++);
  void decrementQuantity() {
    if (quantity > 0) setState(() => quantity--);
  }

  int getAdjustedPrice() {
    if (selectedSize == 'Large') return basePrice + 5000;
    if (selectedSize == 'Extra Large') return basePrice + 10000;
    return basePrice;
  }

  @override
  void initState() {
    super.initState();
    fetchMenu();
  }

  Future<void> fetchMenu() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('menu')
            .doc(widget.menuId)
            .get();
    if (mounted) {
      setState(() {
        menuData = doc;
        basePrice = (doc.data()?['harga'] ?? 0) as int;
        isLoading = false;
      });
    }
  }

  void _showFlushbar(String message, Color color) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(15),
      borderRadius: BorderRadius.circular(10),
      backgroundColor: color,
      icon: Icon(Icons.info_outline, color: Colors.white),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || menuData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = menuData!.data() as Map<String, dynamic>;
    final String title = data['nama'] ?? '';
    final String imageUrl = data['imageUrl'] ?? '';
    final String description = data['description'] ?? '';
    final String rating = data['rating'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.broken_image),
                ),
              ),
              Positioned(
                top: 36,
                left: 12,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 127, 254),
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'lib/assets/icons/arrow-circle-left.svg',
                        width: 22,
                        height: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: const Color.fromARGB(255, 0, 127, 254),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ListView(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'lib/assets/icons/star.svg',
                        width: 15,
                        height: 15,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color.fromARGB(255, 96, 96, 96),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    formatRupiah.format(getAdjustedPrice()),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Deskripsi',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pilih Ukuran',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 13,
                    children:
                        ['Regular', 'Large', 'Extra Large'].map((size) {
                          final isSelected = selectedSize == size;
                          return GestureDetector(
                            onTap: () => setState(() => selectedSize = size),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? const Color.fromARGB(255, 250, 21, 21)
                                        : Colors.white,
                                border: Border.all(
                                  color: const Color.fromARGB(255, 0, 127, 254),
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                size,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Catatan Tambahan',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan catatan untuk pesanan anda...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: const Color.fromARGB(255, 96, 96, 96),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 0, 127, 254),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 0, 127, 254),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 0, 127, 254),
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 217, 217, 217),
                            border: Border.all(
                              color: const Color.fromARGB(255, 0, 127, 254),
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: decrementQuantity,
                                icon: const Icon(Icons.remove),
                              ),
                              Text(
                                '$quantity',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                              IconButton(
                                onPressed: incrementQuantity,
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedSize.isEmpty || quantity < 1) {
                                _showFlushbar(
                                  'Pilih ukuran dan jumlah terlebih dahulu!',
                                  Colors.red,
                                );
                                return;
                              }

                              final cartItem = CartItem(
                                id: title,
                                title: title,
                                image: imageUrl,
                                price: getAdjustedPrice().toString(),
                                size: selectedSize,
                                notes: noteController.text,
                                quantity: quantity,
                              );

                              Provider.of<CartController>(
                                context,
                                listen: false,
                              ).addToCart(cartItem);

                              _showFlushbar(
                                '$title berhasil ditambahkan ke keranjang',
                                Colors.green,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                250,
                                21,
                                21,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: const BorderSide(
                                  color: Color.fromARGB(255, 0, 127, 254),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              'Tambah ke Keranjang',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
