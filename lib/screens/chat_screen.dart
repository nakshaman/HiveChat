import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hivechat/screens/image_upload_service.dart';
import 'package:hivechat/services/database_methods.dart';

class ChatScreen extends StatefulWidget {
  final String otherUsername;
  const ChatScreen({super.key, required this.otherUsername});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  // ---------------- CONTROLLERS & SERVICES ----------------
  final TextEditingController messageController = TextEditingController();
  final ImageUploadService imageUploadService = ImageUploadService();

  // ---------------- STATE ----------------
  String? chatRoomId;
  String currentUsername = "";
  bool isUploadingImage = false;

  // ---------------- HELPERS ----------------
  String getChatRoomId(String a, String b) {
    a = a.toLowerCase();
    b = b.toLowerCase();
    return a.compareTo(b) > 0 ? "${b}_$a" : "${a}_$b";
  }

  Future<void> setupChat() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    currentUsername = userDoc['username'];
    chatRoomId = getChatRoomId(widget.otherUsername, currentUsername);

    await DatabaseMethods().createChatRoom(
      widget.otherUsername,
      currentUsername,
      chatRoomId,
    );
    setState(() {});
  }

  // ---------------- SEND IMAGE ----------------
  Future<void> sendImage() async {
    setState(() => isUploadingImage = true);

    try {
      final imageUrl = await imageUploadService.pickAndUploadImage(
        folderName: 'chatImages',
      );

      if (imageUrl != null) {
        await DatabaseMethods().sendMessage(
          chatRoomId!,
          imageUrl,
          currentUsername,
          "image",
        );
      }
    } finally {
      if (mounted) {
        setState(() => isUploadingImage = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    setupChat();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xff703eff),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xff703eff),
        body: chatRoomId == null
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    buildHeader(),
                    const SizedBox(height: 15),
                    buildChatBody(),
                  ],
                ),
              ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        Expanded(
          child: Center(
            child: Text(
              widget.otherUsername,
              style: GoogleFonts.montserrat(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  // ---------------- CHAT BODY ----------------
  Widget buildChatBody() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Expanded(child: buildMessages()),
            buildInputRow(),
          ],
        ),
      ),
    );
  }

  // ---------------- MESSAGE LIST ----------------
  Widget buildMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy("time", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Text("Send a message"));
        }
        final docs = snapshot.data!.docs;
        final totalItems = docs.length + (isUploadingImage ? 1 : 0);
        return ListView.builder(
          reverse: true,
          itemCount: totalItems,
          itemBuilder: (context, index) {
            //  TEMP IMAGE LOADER BUBBLE
            if (isUploadingImage && index == 0) {
              return uploadingBubble();
            }

            final realIndex = isUploadingImage ? index - 1 : index;
            final data = docs[realIndex];
            final isMe = data['sender'] == currentUsername;
            final type =
                (data.data() as Map<String, dynamic>)['type'] ?? 'text';

            return type == "text"
                ? textBubble(data['message'], isMe)
                : imageBubble(data['message'], isMe);
          },
        );
      },
    );
  }

  // ---------------- BUBBLES ----------------
  Widget uploadingBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(8),
        height: 120,
        width: MediaQuery.of(context).size.width * 0.32,
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xff703eff),
          ),
        ),
      ),
    );
  }

  Widget textBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueGrey : Colors.blue,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget imageBubble(String url, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            width: MediaQuery.of(context).size.width * 0.32,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  // ---------------- INPUT ROW ----------------
  Widget buildInputRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 14),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.image_rounded,
              color: isUploadingImage ? Colors.grey : const Color(0xff703eff),
            ),
            onPressed: isUploadingImage ? null : sendImage,
          ),
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: "Write a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xff703eff)),
            onPressed: () async {
              if (messageController.text.trim().isEmpty) return;

              await DatabaseMethods().sendMessage(
                chatRoomId!,
                messageController.text.trim(),
                currentUsername,
                "text",
              );
              messageController.clear();
            },
          ),
        ],
      ),
    );
  }
}
