import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hivechat/services/database_methods.dart';

class ChatScreen extends StatefulWidget {
  final String otherUsername;
  const ChatScreen({super.key, required this.otherUsername});

  @override
  State<ChatScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ChatScreen> {
  TextEditingController messageController = TextEditingController();
  String? chatRoomId;
  String currentUsername = "";

  String getChatRoomId(String user1, String user2) {
    user1 = user1.toLowerCase();
    user2 = user2.toLowerCase();
    if (user1.compareTo(user2) > 0) {
      return "${user2}_$user1";
    } else {
      return "${user1}_$user2";
    }
  }

  Future<String> getCurrentUsername() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();
    return doc['username'];
  }

  Future<void> setUpChat() async {
    currentUsername = await getCurrentUsername();
    chatRoomId = getChatRoomId(widget.otherUsername, currentUsername);
    DatabaseMethods().createChatRoom(
      widget.otherUsername,
      currentUsername,
      chatRoomId,
    );
    setState(() {});
  }

  @override
  void initState() {
    setUpChat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xff703eff),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Color(0xff703eff),
        body: chatRoomId == null || currentUsername.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: (Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 30,
                            )),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.otherUsername,
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                    SizedBox(height: 15),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('chatRooms')
                                    .doc(chatRoomId)
                                    .collection('messages')
                                    .orderBy("time", descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(child: Text('Send Message'));
                                  }
                                  return ListView.builder(
                                    reverse: true,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      var data = snapshot.data!.docs[index];
                                      bool isMe =
                                          data['sender'] == currentUsername;
                                      return Align(
                                        alignment: isMe
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            color: isMe
                                                ? Colors.blueGrey
                                                : Colors.blue,
                                          ),
                                          child: Text(
                                            data['message'],
                                            style: GoogleFonts.lato(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            // Last Row mic/textfield/sendButton
                            Container(
                              decoration: BoxDecoration(color: Colors.white),
                              margin: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 14,
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      debugPrint('Mic tapped');
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        color: Color(0xff703eff),
                                      ),
                                      child: Icon(
                                        Icons.mic,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (value) {},
                                      controller: messageController,
                                      decoration: InputDecoration(
                                        hintText: 'Write a message...',
                                        hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blueGrey[200],
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                            width: 1.5,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                      shape: CircleBorder(),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    onPressed: () async {
                                      if (messageController.text
                                          .trim()
                                          .isNotEmpty) {
                                        await DatabaseMethods().sendMessage(
                                          chatRoomId,
                                          messageController.text,
                                          currentUsername,
                                        );
                                      }
                                      messageController.clear();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Color(0xff703eff),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Icon(
                                        Icons.send,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
