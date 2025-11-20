import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Image.asset(
                'images/onboard.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Text(
                    'Enjoy the new expeience of chatting with Global Friends',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Come Let\'s Connect with the world',
                    style: GoogleFonts.montserrat(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      debugPrint("Goolge Sign in Button");
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Color(0xff703eff),
                        borderRadius: BorderRadius.circular(60),
                      ),
                      padding: EdgeInsets.all(7),
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Image.asset(
                            'images/google.jpg',
                            height: MediaQuery.of(context).size.height * 0.07,
                            width: MediaQuery.of(context).size.height * 0.07,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.height * 0.015,
                          ),
                          Text(
                            'Sign in with Google',
                            style: GoogleFonts.montserrat(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.06,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
