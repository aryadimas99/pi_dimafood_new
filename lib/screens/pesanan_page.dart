import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class PesananPage extends StatelessWidget {
  const PesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    print("DEBUG: UID saat ini => $userId");

    return Scaffold(
      // Hilangkan AppBar sepenuhnya untuk menghindari jarak atas
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            // Content
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('pesanan')
                        .where('userId', isEqualTo: userId)
                        .where('status', isNotEqualTo: 'Selesai')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada pesanan.'));
                  }

                  final pesananList = snapshot.data!.docs;

                  return ListView.builder(
                    // Hilangkan semua padding default
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    physics:
                        const ClampingScrollPhysics(), // Hilangkan bounce effect
                    itemCount: pesananList.length,
                    itemBuilder: (context, index) {
                      final pesanan = pesananList[index];
                      final List<dynamic> items = pesanan['items'] ?? [];
                      final status = pesanan['status'] ?? '-';
                      final timestamp = pesanan['timestamp'] as Timestamp;
                      final date = DateFormat(
                        'dd MMM yyyy – HH.mm',
                      ).format(timestamp.toDate());
                      final orderCode = pesanan['orderCode'] ?? '-';
                      final kodePembayaran = pesanan['kodePembayaran'] ?? '-';
                      final totalHarga = pesanan['totalPrice'] ?? 0;
                      final totalBayar = pesanan['totalPembayaran'] ?? 0;
                      final alamat = pesanan['alamat'] ?? '-';
                      final noTelp = pesanan['nomorTelepon'] ?? '-';

                      final statusInfo = _getStatusInfo(status);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'DimaFood',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                    fontSize: 20,
                                  ),
                                ),
                                const Spacer(),
                                SvgPicture.asset(
                                  statusInfo.iconPath,
                                  height: 18,
                                  colorFilter: ColorFilter.mode(
                                    statusInfo.color,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  status,
                                  style: GoogleFonts.inter(
                                    color: statusInfo.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              date,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              '$orderCode',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Divider(height: 24),

                            // Items
                            ...items.map(
                              (item) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${item['quantity']}x ${item['name']}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(item['price']),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 24),

                            // Summary
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Jumlah',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(totalHarga),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Kode Pembayaran',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '$kodePembayaran',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 2),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Pembayaran',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(totalBayar),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Text(
                              'Alamat Pengantaran:',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              alamat,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  'lib/assets/icons/call.svg',
                                  height: 18,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.blue,
                                    BlendMode.srcIn,
                                  ),
                                ),

                                const SizedBox(width: 6),
                                Text(
                                  noTelp,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(num value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(value);
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'Sedang Diproses':
        return _StatusInfo('lib/assets/icons/clock-red.svg', Colors.red);
      case 'Sedang Diantar':
        return _StatusInfo('lib/assets/icons/clock-blue.svg', Colors.blue);
      case 'Selesai':
        return _StatusInfo('lib/assets/icons/tick-circle.svg', Colors.green);
      default:
        return _StatusInfo('lib/assets/icons/clock.svg', Colors.black);
    }
  }
}

class _StatusInfo {
  final String iconPath;
  final Color color;

  _StatusInfo(this.iconPath, this.color);
}
