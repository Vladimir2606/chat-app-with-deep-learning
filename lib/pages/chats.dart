import 'dart:async';
import 'dart:io';
import 'package:chatapp/components/button.dart';
import 'package:chatapp/components/globals.dart';
import 'package:chatapp/components/pin.dart';
import 'package:chatapp/pages/chat_room.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ChatPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), topLeft: Radius.circular(20)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFFFFB703),
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/chats-icon.svg",
                  // ignore: deprecated_member_use
                  color: _selectedIndex == 0
                      ? Colors.white
                      : const Color.fromARGB(128, 255, 255, 255),
                ),
                label: 'Chats',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  "assets/profile-icon.svg",
                  // ignore: deprecated_member_use
                  color: _selectedIndex == 1
                      ? Colors.white
                      : const Color.fromARGB(128, 255, 255, 255),
                ),
                label: 'Profile',
              ),
            ],
            unselectedItemColor: const Color.fromARGB(128, 255, 255, 255),
            selectedItemColor: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController addSearchController = TextEditingController();
  late StreamController<QuerySnapshot> _searchStreamController;
  List<DocumentSnapshot> searchResults = [];
  late String username = "";

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _searchStreamController = StreamController<QuerySnapshot>.broadcast();
    getOwnUser();
  }

  @override
  void dispose() {
    _searchStreamController.close();
    super.dispose();
  }

  void _showPINModal(BuildContext context) {
    String enteredPin = "";
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFFFB703),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please enter your PIN:',
                  style: TextStyle(
                    fontFamily: "IBM Plex Mono",
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Pin(
                  onPinEntered: (pin) {
                    if (pin == '222222') {
                      enteredPin = pin;
                    } else {}
                  },
                ),
                const SizedBox(height: 150),
                Button(
                    onTap: () {
                      if (enteredPin == "222222") {
                        _showaddContactModal(context);
                      }
                    },
                    text: "Submit"),
                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showaddContactModal(BuildContext context) async {
    List<String> contactUserIds =
        await getContactUserIds(_firebaseAuth.currentUser!.uid);
    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          color: Colors.grey[200],
          child: FractionallySizedBox(
            heightFactor: 1,
            child: Column(
              children: [
                Container(
                  height: 205,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFB703),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        spreadRadius: 0,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 30),
                              Text(
                                'Add a new contact',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "IBM Plex Mono",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Done",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "IBM Plex Mono",
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 40,
                        child: TextField(
                          controller: addSearchController,
                          onChanged: (value) {
                            searchUsers(value);
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 1),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.white),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Search",
                            hintStyle: const TextStyle(
                              color: Colors.black,
                              fontFamily: "IBM Plex Mono",
                              fontSize: 18,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: SvgPicture.asset("assets/search-icon.svg"),
                            ),
                          ),
                          cursorColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your username:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  username,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/info-icon.svg",
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'With the username your friends can find you!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _searchStreamController.stream,
                    builder: (context, snapshot) {
                      var searchResults = snapshot.data?.docs ?? [];
                      return ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          var user = searchResults[index].data()
                              as Map<String, dynamic>;
                          var contactUserId = searchResults[index].id;
                          bool isContact =
                              contactUserIds.contains(contactUserId);
                          return buildContactListItem(
                              user, contactUserId, isContact);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildContactListItem(
      Map<String, dynamic> user, String contactUserId, bool isContact) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4.0, left: 12.0, right: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(100, 100, 111, 0.2),
                    blurRadius: 29,
                    spreadRadius: 0,
                    offset: Offset(
                      0,
                      7,
                    ),
                  ),
                ],
              ),
              child: Card(
                elevation: 0,
                color: Colors.white,
                child: ListTile(
                  title: Text(user['childsName']),
                  subtitle: Text('${user['username']}'),
                  trailing: GestureDetector(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB703),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.16),
                            blurRadius: 4,
                            spreadRadius: 0,
                            offset: Offset(
                              0,
                              1,
                            ),
                          ),
                        ],
                      ),
                      child: Center(
                        child: isContact
                            ? SvgPicture.asset("assets/added-Icon.svg")
                            : SvgPicture.asset("assets/plus-icon.svg"),
                      ),
                    ),
                    onTap: () {
                      if (!isContact) {
                        _addContact(
                            _firebaseAuth.currentUser!.uid, contactUserId);
                        addSearchController.clear();
                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addContact(String currentUserId, String contactId) {
    _firestore
        .collection('contacts')
        .doc(currentUserId)
        .collection('userContacts')
        .doc(contactId)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> getContactUserIds(String currentUserId) async {
    QuerySnapshot contactsSnapshot = await FirebaseFirestore.instance
        .collection('contacts')
        .doc(currentUserId)
        .collection('userContacts')
        .get();

    List<String> contactUserIds =
        contactsSnapshot.docs.map((doc) => doc.id).toList();

    return contactUserIds;
  }

  Future<void> searchUsers(String searchTerm) async {
    searchTerm = searchTerm.trim().toLowerCase();

    if (searchTerm.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: searchTerm)
          .where('username', isLessThan: '${searchTerm}z')
          .snapshots()
          .listen((QuerySnapshot result) {
        _searchStreamController.add(result);
      });
    } else {
      _searchStreamController.addError("");
    }
  }

  void getOwnUser() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userSnapshot = await userDocRef.get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      setState(() {
        username = userData['username'];
      });
    } else {
      setState(() {
        username = "user not found";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFB703),
          toolbarHeight: Platform.isAndroid ? 176 : 140,
          automaticallyImplyLeading: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Platform.isAndroid
                  ? const SizedBox(height: 36)
                  : const SizedBox(height: 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Chats',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "IBM Plex Mono",
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                  IconButton(
                    icon: SvgPicture.asset("assets/addContact-icon.svg"),
                    tooltip: 'Show Snackbar',
                    onPressed: () {
                      _showPINModal(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 40,
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 1),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "Search",
                    hintStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: SvgPicture.asset("assets/search-icon.svg"),
                    ),
                  ),
                  cursorColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getContactsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  var contacts = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<Map<String, dynamic>?>(
                        future: _getUserData(contacts[index].id),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.hasData) {
                            var contactData = userSnapshot.data!;
                            return Container(
                              margin: const EdgeInsets.only(
                                  bottom: 4.0, left: 14.0, right: 14.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [globalShadow],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Card(
                                        elevation: 0,
                                        color: Colors.white,
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ChatRoom(
                                                          receiverChildsName:
                                                              contactData[
                                                                  'childsName'],
                                                          receiverUserId:
                                                              contactData[
                                                                  'uid'],
                                                        )));
                                          },
                                          leading: const CircleAvatar(
                                            radius: 25,
                                            backgroundImage: AssetImage(
                                                'assets/profile_picture_placeholder.png'),
                                          ),
                                          title:
                                              Text(contactData['childsName']),
                                          subtitle: Text(
                                              '${contactData['username']}'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ));
  }

  Stream<QuerySnapshot> getContactsStream() {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('contacts')
        .doc(currentUserId)
        .collection('userContacts')
        .snapshots();
  }

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return userDoc.data();
    } catch (e) {
      Text("Error: $e");
      return null;
    }
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String fullName = "";
  String username = "";
  String email = "";
  String parentsName = "";

  @override
  void initState() {
    super.initState();
    getOwnUser();
  }

  void signOut() {
    final authService = Get.find<AuthService>();
    authService.signOut();
  }

  void getOwnUser() async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    DocumentSnapshot userSnapshot = await userDocRef.get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      setState(() {
        fullName = userData['childsName'];
        username = userData['username'];
        email = userData['email'];
        parentsName = userData['parentsName'];
      });
    } else {
      setState(() {
        fullName = "user not found";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> data = [
      {
        'title': 'Username:',
        'info': username,
      },
      {
        'title': 'Name of the parent:',
        'info': parentsName,
      },
      {
        'title': 'Email of the parent:',
        'info': email,
      },
    ];
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFB703),
        toolbarHeight: Platform.isAndroid ? 276 : 240,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
          ),
        ),
        title: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 65,
                  backgroundImage:
                      AssetImage('assets/profile_picture_placeholder.png'),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white),
                )
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              boxShadow: [globalShadow],
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.only(bottom: 4.0, left: 14.0, right: 14.0),
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: data.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  var item = data[index];
                  return ListTile(
                    title: Text(item['title']!),
                    subtitle: Text(item['info']!),
                    trailing: const Icon(Icons.more_vert),
                    onTap: () {
                      debugPrint('Element $index angeklickt: ${item['title']}');
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [globalShadow],
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.only(bottom: 4.0, left: 14.0, right: 14.0),
            child: Card(
              elevation: 0,
              color: Colors.white,
              child: ListTile(
                onTap: signOut,
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                trailing: SvgPicture.asset(
                  "assets/logout-icon.svg",
                  height: 22.5,
                  width: 22.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
