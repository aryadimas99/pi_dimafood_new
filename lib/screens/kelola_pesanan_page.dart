import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class KelolaPesananPage extends StatelessWidget {
  const KelolaPesananPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 400;

        return StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('pesanan')
                  .where('status', isNotEqualTo: 'Selesai')
                  .orderBy('status')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Tidak ada pesanan.'));
            }

            final pesananList = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: pesananList.length,
              itemBuilder: (context, index) {
                final pesanan = pesananList[index];
                final items = pesanan['items'] as List<dynamic>;
                final status = pesanan['status'];
                final timestamp = pesanan['timestamp'] as Timestamp;
                final date = DateFormat(
                  'dd MMM yyyy – HH.mm',
                ).format(timestamp.toDate());
                final orderCode = pesanan['orderCode'];
                final totalHarga = pesanan['totalPrice'];
                final totalBayar = pesanan['totalPembayaran'];
                final kodePembayaran = pesanan['kodePembayaran'];
                final alamat = pesanan['alamat'];
                final noTelp = pesanan['nomorTelepon'];
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
                      Row(
                        children: [
                          Text(
                            'DimaFood',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                              fontSize: isSmallScreen ? 16 : 20,
                            ),
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            statusInfo.iconPath!,
                            height: isSmallScreen ? 16 : 18,
                            colorFilter: ColorFilter.mode(
                              statusInfo.color,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            status,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w500,
                              fontSize: isSmallScreen ? 10 : 12,
                              color: statusInfo.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      Text(
                        'ORDER - $orderCode',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      const Divider(height: 24),
                      ...items.map(
                        (item) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item['quantity']}x ${item['name']}',
                                style: GoogleFonts.inter(
                                  fontSize: isSmallScreen ? 10 : 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatCurrency(item['price']),
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24),
                      _buildRow(
                        'Jumlah',
                        _formatCurrency(totalHarga),
                        isSmallScreen,
                      ),
                      _buildRow(
                        'Kode Pembayaran',
                        '$kodePembayaran',
                        isSmallScreen,
                      ),
                      _buildRow(
                        'Total Pembayaran',
                        _formatCurrency(totalBayar),
                        isSmallScreen,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Alamat Pengantaran:',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      Text(
                        alamat,
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'lib/assets/icons/call.svg',
                            height: isSmallScreen ? 16 : 18,
                            colorFilter: const ColorFilter.mode(
                              Colors.blue,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            noTelp,
                            style: GoogleFonts.inter(
                              fontSize: isSmallScreen ? 10 : 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            visualDensity: VisualDensity.compact,
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            childrenPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            iconColor: Colors.black54,
                            collapsedIconColor: Colors.black54,
                            title: Text(
                              'Update Status',
                              style: GoogleFonts.inter(
                                fontSize: isSmallScreen ? 11 : 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            children: [
                              _statusOption(
                                context,
                                pesanan.id,
                                'Sedang Diproses',
                                isSmallScreen,
                              ),
                              _statusOption(
                                context,
                                pesanan.id,
                                'Sedang Diantar',
                                isSmallScreen,
                              ),
                              _statusOption(
                                context,
                                pesanan.id,
                                'Selesai',
                                isSmallScreen,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRow(String label, String value, bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isSmall ? 10 : 12,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _statusOption(
    BuildContext context,
    String docId,
    String newStatus,
    bool isSmall,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () async {
          try {
            await FirebaseFirestore.instance
                .collection('pesanan')
                .doc(docId)
                .update({'status': newStatus});
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status berhasil diperbarui')),
              );
            }
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gagal update status')),
              );
            }
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Text(
            newStatus,
            style: GoogleFonts.inter(
              fontSize: isSmall ? 11 : 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
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

  String _formatCurrency(num value) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(value);
  }
}

class _StatusInfo {
  final String? iconPath;
  final Color color;
  _StatusInfo(this.iconPath, this.color);
}
