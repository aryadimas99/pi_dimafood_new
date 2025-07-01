// file: admin_home_page.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pi_dimafood_new/screens/logout_page.dart';
import 'package:pi_dimafood_new/screens/admin_pesanan_page.dart';
import 'package:pi_dimafood_new/screens/kelola_pesanan_page.dart';
import 'package:pi_dimafood_new/screens/kelola_menu_page.dart';
import 'package:pi_dimafood_new/screens/admin_dashboard_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  int? jumlahPesananBaru;
  late StreamSubscription<QuerySnapshot> _pesananSubscription;

  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const KelolaPesananPage(),
    const KelolaMenuPage(),
    const AdminPesananPage(),
    const AdminProfileLogoutPage(),
  ];

  final List<String> iconPaths = [
    'lib/assets/icons/home.svg',
    'lib/assets/icons/information.svg',
    'lib/assets/icons/menu.svg',
    'lib/assets/icons/shopping-bag.svg',
    'lib/assets/icons/frame.svg',
  ];

  @override
  void initState() {
    super.initState();
    _pesananSubscription = FirebaseFirestore.instance
        .collection('pesanan')
        .where('status', isEqualTo: 'Menunggu Konfirmasi')
        .snapshots()
        .listen((snapshot) {
          setState(() {
            jumlahPesananBaru = snapshot.docs.length;
          });
        });
  }

  @override
  void dispose() {
    _pesananSubscription.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_selectedIndex == 0) {
      return AppBar(
        title: Text(
          "DimaFood Admin",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(255, 0, 127, 254),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      );
    } else {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 0, 127, 254),
          ),
          onPressed: () => setState(() => _selectedIndex = 0),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            if (_selectedIndex == 3)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SvgPicture.asset(
                  'lib/assets/icons/shopping-bag.svg',
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color.fromARGB(255, 0, 127, 254),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            Text(
              _selectedIndex == 1
                  ? 'Kelola Pesanan'
                  : _selectedIndex == 2
                  ? 'Kelola Menu'
                  : _selectedIndex == 3
                  ? 'Pesanan'
                  : '',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(255, 0, 127, 254),
              ),
            ),
            const Spacer(),
            if (_selectedIndex == 4)
              TextButton.icon(
                onPressed: () {
                  LogOutPage.showLogoutDialog(context);
                },
                icon: SvgPicture.asset(
                  'lib/assets/icons/logout.svg',
                  width: 20,
                  height: 20,
                ),
                label: Text(
                  'Logout',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: const Color.fromARGB(255, 0, 127, 254),
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _pages[_selectedIndex],
      backgroundColor: Colors.white,
      bottomNavigationBar:
          _selectedIndex == 0
              ? Container(
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(
                    color: const Color.fromARGB(255, 0, 127, 254),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    final isMiddle = index == 2;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onItemTapped(index),
                        child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SvgPicture.asset(
                                iconPaths[index],
                                height: isMiddle ? 32 : 24,
                                colorFilter: const ColorFilter.mode(
                                  Color.fromARGB(255, 0, 127, 254),
                                  BlendMode.srcIn,
                                ),
                              ),
                              if (index == 1 && (jumlahPesananBaru ?? 0) > 0)
                                Positioned(
                                  top: 0,
                                  right: 22,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${jumlahPesananBaru ?? ''}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              )
              : null,
    );
  }
}

// ==================== PAGES =====================

class AdminProfileLogoutPage extends StatelessWidget {
  const AdminProfileLogoutPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 0, 127, 254),
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: ClipOval(
                child: Image.asset(
                  'lib/assets/images/logo_dimafood.jpeg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
