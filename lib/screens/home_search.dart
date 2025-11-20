import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeSearch extends StatefulWidget {
  const HomeSearch({super.key});

  @override
  State<HomeSearch> createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearch> {
  TextEditingController searchTextControler = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  onChanged: (value) {
                    debugPrint(value);
                  },
                  controller: searchTextControler,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.blueGrey[200],
                    ),
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey[200],
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(20),
                  // ignore: deprecated_member_use
                  shadowColor: Colors.black.withOpacity(0.05),
                  color: Colors.white,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(60),
                          child: Image.asset(
                            'images/boy.jpg',
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Naksh Aman',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Hello.. How are you ! The day is very good and what about you',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.only(bottom: 15),
                          child: Text(
                            '2:00',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
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
}
