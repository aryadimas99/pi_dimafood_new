import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import '../models/cart_item.dart';
import 'informasi_pembayaran.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  String? selectedPayment;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cartController = Provider.of<CartController>(context);
    if (cartController.items.isEmpty) {
      phoneController.clear();
      addressController.clear();
      setState(() => selectedPayment = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Provider.of<CartController>(context);
    final items = cartController.items;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('lib/assets/icons/arrow-circle-left.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            SvgPicture.asset(
              'lib/assets/icons/shopping-cart.svg',
              height: 26,
              colorFilter: const ColorFilter.mode(
                Color.fromARGB(255, 0, 127, 254),
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Keranjang',
              style: GoogleFonts.inter(
                color: const Color.fromARGB(255, 0, 127, 254),
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: screenWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...items.map((item) => _buildCartItem(item, cartController)),
              const SizedBox(height: 24),
              _buildInputCard(
                iconPath: 'lib/assets/icons/call.svg',
                title: 'Nomor Telepon',
                child: TextField(
                  controller: phoneController,
                  decoration: _inputDecoration('+6288818882888'),
                ),
              ),
              const SizedBox(height: 16),
              _buildInputCard(
                iconPath: 'lib/assets/icons/location.svg',
                title: 'Alamat Pengantaran',
                child: TextField(
                  controller: addressController,
                  onChanged: (value) {
                    Provider.of<CartController>(
                      context,
                      listen: false,
                    ).setAlamat(value);
                  },
                  decoration: _inputDecoration('Masukkan alamat lengkap'),
                ),
              ),
              const SizedBox(height: 16),
              _buildPaymentMethod(),
              const SizedBox(height: 16),
              _buildSummary(items, cartController.totalPrice),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => InformasiPembayaranPage(
                              metodePembayaran: selectedPayment ?? 'DANA',
                              nomorTelepon: phoneController.text,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 127, 254),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Lanjut Pembayaran',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w300),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color.fromARGB(255, 0, 127, 254)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 0, 127, 254)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Size: ${item.size}',
                  style: GoogleFonts.inter(fontSize: 10),
                ),
                Text(
                  'Notes: ${item.notes}',
                  style: GoogleFonts.inter(fontSize: 10),
                ),
                Text(
                  item.price,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'lib/assets/icons/trash.svg',
                  width: 18,
                  colorFilter: const ColorFilter.mode(
                    Colors.red,
                    BlendMode.srcIn,
                  ),
                ),
                onPressed: () => controller.removeFromCart(item.id),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => controller.decrementQuantity(item.id),
                    icon: SvgPicture.asset(
                      'lib/assets/icons/minus-square.svg',
                      width: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '${item.quantity}',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.incrementQuantity(item.id),
                    icon: SvgPicture.asset(
                      'lib/assets/icons/add-square.svg',
                      width: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required String iconPath,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 0, 127, 254)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(iconPath, width: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    final methods = ['DANA', 'GoPay', 'OVO', 'Cash On Delivery'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 0, 127, 254)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset('lib/assets/icons/wallet.svg', width: 20),
              const SizedBox(width: 8),
              Text(
                'Metode Pembayaran',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          ...methods.map(
            (method) => RadioListTile(
              title: Text(
                method,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: method,
              groupValue: selectedPayment,
              onChanged:
                  (value) => setState(() => selectedPayment = value.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(List<CartItem> items, double total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromARGB(255, 0, 127, 254)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Pembayaran',
            style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 15),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${item.quantity}x ${item.title}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Text(item.price),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              ),
              Text(
                'Rp ${total.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
