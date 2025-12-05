import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hivechat/screens/chat_screen.dart';

class HomeSearch extends StatefulWidget {
  final String myUserName;
  const HomeSearch({super.key, required this.myUserName});

  @override
  State<HomeSearch> createState() => _HomeSearchState();
}

class _HomeSearchState extends State<HomeSearch> {
  TextEditingController searchTextControler = TextEditingController();
  String searchText = "";
  String getChatRoomId(String a, String b) {
    a = a.toLowerCase();
    b = b.toLowerCase();
    if (a.compareTo(b) > 0) {
      return "${b}_$a";
    } else {
      return "${a}_$b";
    }
  }

  Future<String> getLastMessageTime(String otherUsername) async {
    final chatRoomId = getChatRoomId(widget.myUserName, otherUsername);
    var snapshot = await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return "";
    Timestamp timestamp = snapshot.docs.first['time'];
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value.toLowerCase().trim();
                  });
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
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  var docs = snapshot.data!.docs;
                  var filteredUsers = docs.where((doc) {
                    String username = doc['username'].toString();
                    if (username == widget.myUserName) return false;
                    if (searchText.isEmpty) return true;
                    return username.toLowerCase().contains(searchText);
                  }).toList();
                  if (filteredUsers.isEmpty) {
                    return Center(
                      child: Text(
                        'No user found',
                        style: GoogleFonts.lato(color: Colors.black87),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      var userData = filteredUsers[index];
                      String otherUsername = userData['username'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChatScreen(otherUsername: otherUsername),
                            ),
                          );
                        },
                        child: Padding(
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
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // ClipRRect(
                                  //   borderRadius:
                                  //       BorderRadiusGeometry.circular(60),
                                  //   child: Image.asset(
                                  //     'images/boy.jpg',
                                  //     height: 60,
                                  //     width: 60,
                                  //     fit: BoxFit.cover,
                                  //   ),
                                  // ),
                                  CircleAvatar(
                                    radius: 30,
                                    child: Text(otherUsername[0].toUpperCase()),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          otherUsername,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Tap to chat',
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
                                  FutureBuilder(
                                    future: getLastMessageTime(otherUsername),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData ||
                                          snapshot.data == "") {
                                        return Text(
                                          "",
                                          style: GoogleFonts.lato(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        );
                                      }
                                      return Text(
                                        snapshot.data.toString(),
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
