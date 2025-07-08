import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sekilas informasi aplikasi ini:',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'DIMAFOOD adalah aplikasi pemesanan makanan dan minuman yang memudahkan pengguna untuk melihat menu, memesan secara langsung, dan menerima konfirmasi pesanan, serta memungkinkan admin mengelola data menu dan melihat laporan pemesanan dengan praktis.',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 20),
          Text(
            'Aplikasi ini dibuat oleh:',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Dimas Arya Sauki Alaudin\n50422428',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 20),
          Text(
            'Dengan Bimbingan:',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Octarina Budi Lestari, S.T., MMSI',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
