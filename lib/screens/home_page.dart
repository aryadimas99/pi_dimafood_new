import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pi_dimafood_new/screens/info_page.dart';
import 'package:pi_dimafood_new/screens/logout_page.dart';
import 'package:pi_dimafood_new/screens/home_content.dart';
import 'package:pi_dimafood_new/screens/keranjang_page.dart';
import 'package:pi_dimafood_new/screens/pesanan_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    InfoPage(),
    PesananPage(),
    LogOutPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  PreferredSizeWidget? _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading:
          _selectedIndex == 0
              ? null
              : IconButton(
                icon: SvgPicture.asset(
                  'lib/assets/icons/arrow-circle-left.svg',
                  height: 32,
                  width: 32,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),

      titleSpacing: _selectedIndex == 0 ? null : 0,
      title:
          _selectedIndex == 0
              ? Text(
                "DIMAFOOD",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )
              : Row(
                children: [
                  if (_selectedIndex == 2)
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
                        ? 'Informasi'
                        : _selectedIndex == 2
                        ? 'Pesanan'
                        : '',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 0, 127, 254),
                    ),
                  ),
                  const Spacer(),
                  if (_selectedIndex == 3)
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
      foregroundColor: const Color.fromARGB(255, 0, 127, 254),
      actions:
          _selectedIndex == 0
              ? [
                IconButton(
                  icon: SvgPicture.asset(
                    'lib/assets/icons/shopping-cart.svg',
                    height: 35,
                    width: 35,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const KeranjangPage(),
                      ),
                    );
                  },
                ),
              ]
              : null,
    );
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
                height: 60,
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
                  children: List.generate(4, (index) {
                    final iconPaths = [
                      'lib/assets/icons/home.svg',
                      'lib/assets/icons/information.svg',
                      'lib/assets/icons/shopping-bag.svg',
                      'lib/assets/icons/frame.svg',
                    ];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onItemTapped(index),
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      _selectedIndex == index
                                          ? const Color.fromARGB(
                                            255,
                                            0,
                                            127,
                                            254,
                                          ).withAlpha((255 * 0.15).toInt())
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: SvgPicture.asset(
                                  iconPaths[index],
                                  height: 24,
                                  colorFilter: const ColorFilter.mode(
                                    Color.fromARGB(255, 0, 127, 254),
                                    BlendMode.srcIn,
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
