import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hivechat/screens/home_search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xff703eff),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Color(0xff703eff),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 5.0,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_2_outlined,
                          color: Color(0xff703eff),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Sahil Singh',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 5.0,
                ),
                child: Row(
                  children: [
                    Text(
                      'Chats',
                      style: GoogleFonts.montserrat(
                        fontSize: 40,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              HomeSearch(),
            ],
          ),
        ),
      ),
    );
  }
}
