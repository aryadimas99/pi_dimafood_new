import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int totalPesanan = 0;
  int totalPendapatan = 0;
  int totalMenuHariIni = 0;
  int totalPelangganHariIni = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  void fetchDashboardData() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final pesananSnapshot =
        await FirebaseFirestore.instance
            .collection('pesanan')
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThan: endOfDay)
            .get();

    int pendapatanHariIni = 0;
    int totalItemHariIni = 0;
    final Set<String> pelangganHariIni = {};

    for (var doc in pesananSnapshot.docs) {
      pendapatanHariIni += (doc['totalPembayaran'] as num).toInt();

      final List items = doc['items'] ?? [];
      totalItemHariIni += items.length;

      final userId = doc['userId'];
      if (userId != null) {
        pelangganHariIni.add(userId);
      }
    }

    setState(() {
      totalPesanan = pesananSnapshot.docs.length;
      totalPendapatan = pendapatanHariIni;
      totalMenuHariIni = totalItemHariIni;
      totalPelangganHariIni = pelangganHariIni.length;
    });
  }

  Widget _buildInfoCard(String title, String value, String iconPath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF007FFE)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SvgPicture.asset(iconPath, width: 35, height: 35),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Total Pesanan Hari Ini',
            '$totalPesanan',
            'lib/assets/icons/shopping-bag.svg',
          ),
          _buildInfoCard(
            'Pendapatan Hari Ini',
            'Rp ${NumberFormat('#,###').format(totalPendapatan)}',
            'lib/assets/icons/money.svg',
          ),
          _buildInfoCard(
            'Total Menu',
            '$totalMenuHariIni',
            'lib/assets/icons/shop.svg',
          ),
          _buildInfoCard(
            'Total Pelanggan',
            '$totalPelangganHariIni',
            'lib/assets/icons/profile-2user.svg',
          ),
        ],
      ),
    );
  }
}
