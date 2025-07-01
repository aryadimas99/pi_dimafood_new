import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pi_dimafood_new/screens/search_page.dart';

class SearchMenu extends StatelessWidget {
  const SearchMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double fontSize =
        screenWidth < 400
            ? 12
            : screenWidth < 500
            ? 13
            : 14;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromARGB(255, 0, 127, 254)),
          color: const Color.fromARGB(255, 248, 249, 250),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/assets/icons/search-normal.svg',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "Cari makanan atau minuman...",
                style: GoogleFonts.inter(
                  textStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                ),
                overflow: TextOverflow.clip,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
