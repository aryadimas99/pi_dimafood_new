import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/cart_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';

class InformasiPembayaranPage extends StatefulWidget {
  final String metodePembayaran;
  final String nomorTelepon;

  const InformasiPembayaranPage({
    super.key,
    required this.metodePembayaran,
    required this.nomorTelepon,
  });

  @override
  State<InformasiPembayaranPage> createState() =>
      _InformasiPembayaranPageState();
}

class _InformasiPembayaranPageState extends State<InformasiPembayaranPage> {
  final String rekeningAdmin = '082189989090';
  late int kodePembayaran;
  late String kodeOrder;
  late double nominal;
  late double totalPembayaran;

  @override
  void initState() {
    super.initState();
    _generateKode();
  }

  void _generateKode() {
    final cartController = Provider.of<CartController>(context, listen: false);
    nominal = cartController.totalPrice;

    final now = DateTime.now();
    final dateString = DateFormat('yyyyMMdd').format(now);
    final timeString = DateFormat('HHmmss').format(now);
    kodePembayaran = 100 + now.millisecond % 900;
    kodeOrder = "ORDER-$dateString-$timeString";
    totalPembayaran = nominal + kodePembayaran;
  }

  Future<void> _prosesPesanan() async {
    final cartController = Provider.of<CartController>(context, listen: false);

    if (cartController.alamat.isEmpty) {
      _showFlushbar("Alamat tidak boleh kosong.", Colors.red);
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;

    final List<Map<String, dynamic>> items =
        cartController.items.map((item) {
          final cleanPrice =
              item.price.replaceAll("Rp", "").replaceAll(".", "").trim();
          return {
            'name': item.title,
            'price': int.parse(cleanPrice),
            'quantity': item.quantity,
          };
        }).toList();

    await FirebaseFirestore.instance.collection('pesanan').add({
      'userId': userId,
      'items': items,
      'status': 'Menunggu Konfirmasi',
      'timestamp': Timestamp.now(),
      'orderCode': kodeOrder,
      'alamat': cartController.alamat,
      'nomorTelepon': widget.nomorTelepon,
      'metodePembayaran': widget.metodePembayaran,
      'kodePembayaran': kodePembayaran,
      'totalPrice': cartController.totalPrice,
      'totalPembayaran': totalPembayaran,
    });

    if (!mounted) return;

    cartController.clearCart();
    cartController.setAlamat('');

    _showFlushbar("Pesanan berhasil dibuat!", Colors.green);

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    });
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: ListView(
          children: [
            Text(
              'DIMAFOOD',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer ${widget.metodePembayaran}',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Silahkan transfer sesuai nominal yang tertera',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (widget.metodePembayaran != 'Cash On Delivery')
              _buildInfoField('Nomor Rekening Admin', rekeningAdmin),
            _buildInfoField('Nomor Telepon', widget.nomorTelepon),
            _buildInfoField('Nominal Pesanan', _formatCurrency(nominal)),
            _buildInfoField('Kode Order', kodeOrder),
            _buildInfoField('Kode Pembayaran', kodePembayaran.toString()),
            _buildInfoField(
              'Total Pembayaran',
              _formatCurrency(totalPembayaran),
            ),
            const SizedBox(height: 70),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 0, 127, 254),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Kembali',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _prosesPesanan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 0, 127, 254),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Pesan Sekarang',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(value);
  }
}
