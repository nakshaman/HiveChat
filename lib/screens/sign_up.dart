import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hivechat/authentication/auth.dart';
import 'package:hivechat/screens/home.dart';
import 'package:hivechat/screens/log_in.dart';
import 'package:hivechat/services/database_methods.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  InputDecoration inputStyle(
    String label,
    IconData icon,
    Color fieldColor,
    Color labelColor,
  ) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: fieldColor),
      labelText: label,
      labelStyle: TextStyle(color: labelColor),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: fieldColor, width: 1.5),
        borderRadius: BorderRadius.circular(30),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: fieldColor, width: 1.5),
        borderRadius: BorderRadius.circular(30),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(width: 1.5, color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(width: 2.0, color: Colors.redAccent),
      ),
      errorStyle: GoogleFonts.lato(fontSize: 14, color: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff703eff),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Hive Chat',
                      style: GoogleFonts.lato(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 40),
                    TextFormField(
                      style: GoogleFonts.lato(color: Colors.white),
                      controller: usernameController,
                      decoration: inputStyle(
                        "Username",
                        Icons.person,
                        Colors.white,
                        Colors.white,
                      ),
                      cursorColor: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      style: GoogleFonts.lato(color: Colors.white),
                      controller: emailController,
                      decoration: inputStyle(
                        "Email",
                        Icons.email_outlined,
                        Colors.white,
                        Colors.white,
                      ),
                      cursorColor: Colors.white,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Required";
                        if (!RegExp(r"^[^@]+@[^@]+\.[^@]+$").hasMatch(value)) {
                          return "Invalid email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      style: GoogleFonts.lato(color: Colors.white),
                      controller: passwordController,
                      obscureText: true,
                      cursorColor: Colors.white,
                      decoration: inputStyle(
                        "Password",
                        CupertinoIcons.lock,
                        Colors.white,
                        Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        TextEditingController forgotEmail =
                            TextEditingController();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Color(0xff703eff),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(30),
                              ),
                              title: Center(
                                child: Text(
                                  'Email',
                                  style: GoogleFonts.lato(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(height: 40),
                                    TextField(
                                      cursorColor: Colors.white,
                                      style: TextStyle(color: Colors.white),
                                      controller: forgotEmail,
                                      decoration: inputStyle(
                                        "Email",
                                        CupertinoIcons.mail_solid,
                                        Colors.white,
                                        Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Center(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.black45,
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (forgotEmail.text.isNotEmpty) {
                                              await DatabaseMethods()
                                                  .resetPassword(
                                                    forgotEmail.text.trim(),
                                                  );
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Center(
                                                    child: Text(
                                                      'Password Send to your Email',
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      Colors.black87,
                                                  elevation: 10,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadiusGeometry.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  duration: Duration(
                                                    seconds: 3,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Center(
                                                    child: Text(
                                                      'Please enter your email first',
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      Colors.black87,
                                                  elevation: 10,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadiusGeometry.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  duration: Duration(
                                                    seconds: 3,
                                                  ),
                                                ),
                                              );
                                            }
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Send',
                                            style: GoogleFonts.lato(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.only(right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Forgot Password',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black45,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            String? errorMessage = await AuthService()
                                .signUpWithEmailPassword(
                                  emailController.text.trim(),
                                  passwordController.text.trim(),
                                );
                            if (errorMessage == null) {
                              await DatabaseMethods().storeUserData(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                                usernameController.text.trim(),
                              );
                              emailController.clear();
                              passwordController.clear();
                              usernameController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Registration Successfull'),
                                  backgroundColor: Colors.black87,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      12,
                                    ),
                                  ),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Home()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage.toString()),
                                  backgroundColor: Colors.black87,
                                  elevation: 10,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      12,
                                    ),
                                  ),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              emailController.clear();
                              passwordController.clear();
                              usernameController.clear();
                            }
                          }
                        },
                        child: Text(
                          "Submit",
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white.withOpacity(0.4),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "Or",
                            style: GoogleFonts.lato(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withOpacity(0.4),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account ?",
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LogInScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
