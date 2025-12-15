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
  FocusNode focusNode = FocusNode();
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

  Future<List<String>> getMyChatUsers() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('chatRooms')
        .where('users', arrayContains: widget.myUserName)
        .get();
    Set<String> users = {};

    for (var doc in snapshot.docs) {
      List chatUsers = doc['users'];

      for (var user in chatUsers) {
        if (user != widget.myUserName) {
          users.add(user.toLowerCase());
        }
      }
    }
    return users.toList();
  }

  List<String> chatUserList = [];

  @override
  void initState() {
    super.initState();
    loadChatUsers();
    focusNode.addListener(() {
      setState(() {});
    });
  }

  void loadChatUsers() async {
    chatUserList = await getMyChatUsers();
    setState(() {});
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
                  cursorColor: Colors.blueGrey[200],
                  focusNode: focusNode,
                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase().trim();
                    });
                  },
                  controller: searchTextControler,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: focusNode.hasFocus
                          ? Colors.black
                          : Colors.blueGrey[200],
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
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    var listOfUsers = snapshot.data!.docs;
                    var filteredUsers = listOfUsers.where((doc) {
                      String username = doc['username']
                          .toString()
                          .toLowerCase();
                      String myName = widget.myUserName.toLowerCase();
                      if (username == myName) {
                        return false;
                      }
                      if (searchText.isNotEmpty) {
                        return username.contains(searchText);
                      }
                      return chatUserList.contains(username);
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
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatScreen(otherUsername: otherUsername),
                              ),
                            );
                            loadChatUsers();
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
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey[300],
                                      // backgroundImage:
                                      //     (userData['imageUrl'] != null &&
                                      //         userData['imageUrl']
                                      //             .toString()
                                      //             .isNotEmpty)
                                      //     ? NetworkImage(userData['imageUrl'])
                                      //     : null,
                                      child:
                                          (userData['imageUrl'] != null &&
                                              userData['imageUrl']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? ClipOval(
                                              child: Image.network(
                                                userData['imageUrl'],
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                loadingBuilder:
                                                    (
                                                      context,
                                                      child,
                                                      loadingProgress,
                                                    ) {
                                                      if (loadingProgress ==
                                                          null) {
                                                        return child;
                                                      }
                                                      return SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      );
                                                    },
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Text(
                                                        otherUsername[0]
                                                            .toUpperCase(),
                                                        style: GoogleFonts.lato(
                                                          fontSize: 22,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      );
                                                    },
                                              ),
                                            )
                                          : Text(
                                              otherUsername[0].toUpperCase(),
                                              style: GoogleFonts.lato(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
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
      ),
    );
  }
}
