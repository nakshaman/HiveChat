import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hivechat/authentication/auth.dart';
import 'package:hivechat/authentication/auth_wrapper.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isUploading = false;
  final ImagePicker picker = ImagePicker();
  Future<void> pickAndUploadImage(String uid) async {
    try {
      setState(() {
        isUploading = true;
      });
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (pickedFile == null) return;
      File file = File(pickedFile.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('profilepics')
          .child('$uid.jpg');
      await ref.putFile(file);
      final photoUrl = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'imageUrl': photoUrl,
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // When user logs out → authSnapshot.data becomes null
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Color(0xff703eff),
            body: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        if (!authSnapshot.hasData) {
          // Redirect to AuthWrapper
          Future.microtask(() {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthWrapper()),
              (route) => false,
            );
          });

          return Scaffold(
            backgroundColor: Color(0xff703eff),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = authSnapshot.data!;

        return Scaffold(
          backgroundColor: const Color(0xff703eff),
          body: SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                String username = snapshot.data!['username'];

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => pickAndUploadImage(user.uid),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.deepPurple[100],
                          foregroundImage:
                              (snapshot.data!['imageUrl'] != null &&
                                  snapshot.data!['imageUrl']
                                      .toString()
                                      .isNotEmpty)
                              ? NetworkImage(snapshot.data!['imageUrl'])
                              : null,
                          child: isUploading
                              ? CircularProgressIndicator(color: Colors.purple)
                              : (snapshot.data!['imageUrl'] != null &&
                                    snapshot.data!['imageUrl']
                                        .toString()
                                        .isNotEmpty)
                              ? null
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.deepPurple[700],
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        username,
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 25,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text(
                                    'Are you sure you want to log out?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(dialogContext);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(dialogContext);
                                        await AuthService().signOut();
                                      },
                                      child: const Text(
                                        "Logout",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text(
                            'Log out',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
