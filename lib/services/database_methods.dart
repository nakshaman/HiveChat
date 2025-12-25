import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DatabaseMethods {
  final currentUser = FirebaseAuth.instance.currentUser;

  Future<void> storeUserData(
    String email,
    String password,
    String username,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .set({
          'username': username,
          'name': email.replaceAll("@gmail.com", ""),
          'searchKey': username.substring(0, 1).toUpperCase(),
          'email': email,
          'password': password,
          'uid': currentUser!.uid,
          'imageUrl': "",
        });
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> createChatRoom(
    String username1,
    String username2,
    String? chatRoomId,
  ) async {
    Map<String, dynamic> chatRoomData = {
      "users": [username1, username2],
      "chatRoomId": chatRoomId,
      "createdAt": DateTime.now(),
    };
    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .set(chatRoomData, SetOptions(merge: true));
  }

  Future<void> sendMessage(
    String? chatRoomId,
    String message,
    String sender,
    String type,
  ) async {
    Map<String, dynamic> messageData = {
      "message": message,
      "sender": sender,
      "time": DateTime.now(),
      "type": type,
    };
    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);
  }
}
