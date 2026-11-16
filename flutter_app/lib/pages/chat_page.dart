import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/socket_service.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SocketService socketService = SocketService();
  final ApiService apiService = ApiService();

  final TextEditingController messageController =
      TextEditingController();

  List<Map<String, dynamic>> messages = [];

  List<String> onlineUsers = [];

  String username = "";

  @override
  void initState() {
    super.initState();

    socketService.connect();

    loadUser();

    loadMessages();

    socketService.socket.on(
      'usersList',
      (data) {
        setState(() {
          onlineUsers =
              List<String>.from(data);
        });
      },
    );

    socketService.listen((data) {
      setState(() {
        messages.add(
          Map<String, dynamic>.from(data),
        );
      });
    });
  }

  Future<void> loadMessages() async {
    try {
      final data =
          await apiService.getMessages();

      setState(() {
        messages =
            List<Map<String, dynamic>>.from(
          data,
        );
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadUser() async {
    final prefs =
        await SharedPreferences.getInstance();

    username =
        prefs.getString("username") ??
            "Utilisateur";

    socketService.registerUser(username);

    setState(() {});
  }

  Future<void> logout() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginPage(),
      ),
      (route) => false,
    );
  }

  void sendMessage() {
    final text =
        messageController.text.trim();

    if (text.isEmpty) return;

    socketService.sendMessage({
      "sender": username,
      "receiver": "global",
      "message": text,
    });

    messageController.clear();
  }

  @override
  void dispose() {
    socketService.disconnect();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0D0D0D),

      appBar: AppBar(
        centerTitle: true,
        backgroundColor:
            const Color(0xFF171717),

        title: const Text(
          "⚜ CHAT GLOBAL ⚜",
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon:
                const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),

      body: Row(
        children: [

          // SIDEBAR
          Container(
            width: 220,
            color:
                const Color(0xFF151515),

            child: Column(
              children: [

                const SizedBox(
                  height: 16,
                ),

                Text(
                  "🟢 EN LIGNE (${onlineUsers.length})",
                  style:
                      const TextStyle(
                    color:
                        Color(0xFFFFD700),
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const Divider(),

                Expanded(
                  child:
                      ListView.builder(
                    itemCount:
                        onlineUsers.length,

                    itemBuilder:
                        (context, index) {

                      final user =
                          onlineUsers[
                              index];

                      return ListTile(
                        leading:
                            CircleAvatar(
                          radius: 14,
                          backgroundColor:
                              Colors.green,

                          child: Text(
                            user
                                .substring(
                                    0,
                                    1)
                                .toUpperCase(),

                            style:
                                const TextStyle(
                              color:
                                  Colors
                                      .white,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),

                        title: Text(
                          user,

                          style:
                              const TextStyle(
                            color:
                                Colors
                                    .white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // CHAT
          Expanded(
            child: Column(
              children: [

                Expanded(
                  child:
                      ListView.builder(
                    itemCount:
                        messages.length,

                    itemBuilder:
                        (context, index) {

                      final msg =
                          messages[index];

                      final sender =
                          msg["sender"]
                                  ?.toString() ??
                              "";

                      final content =
                          msg["content"]
                                  ?.toString() ??
                              "";

                      final isMe =
                          sender ==
                              username;

                      return Padding(
                        padding:
                            const EdgeInsets
                                .all(8),

                        child: Align(
                          alignment:
                              isMe
                                  ? Alignment
                                      .centerRight
                                  : Alignment
                                      .centerLeft,

                          child:
                              Container(
                            padding:
                                const EdgeInsets
                                    .all(
                                        12),

                            decoration:
                                BoxDecoration(
                              color:
                                  isMe
                                      ? const Color(
                                          0xFFFFD700)
                                      : const Color(
                                          0xFF232323),

                              borderRadius:
                                  BorderRadius.circular(
                                      14),
                            ),

                            child:
                                Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  sender,

                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,

                                    color:
                                        isMe
                                            ? Colors.black
                                            : Colors.white,
                                  ),
                                ),

                                const SizedBox(
                                  height:
                                      4,
                                ),

                                Text(
                                  content,

                                  style:
                                      TextStyle(
                                    color:
                                        isMe
                                            ? Colors.black
                                            : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  color:
                      const Color(
                          0xFF171717),

                  padding:
                      const EdgeInsets
                          .all(8),

                  child: Row(
                    children: [

                      Expanded(
                        child:
                            TextField(
                          controller:
                              messageController,

                          style:
                              const TextStyle(
                            color:
                                Colors
                                    .white,
                          ),

                          decoration:
                              InputDecoration(
                            hintText:
                                "Écrire un message...",

                            hintStyle:
                                const TextStyle(
                              color:
                                  Colors
                                      .grey,
                            ),

                            filled:
                                true,

                            fillColor:
                                const Color(
                                    0xFF232323),

                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                      12),
                            ),
                          ),

                          onSubmitted:
                              (_) =>
                                  sendMessage(),
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      IconButton(
                        icon:
                            const Icon(
                                Icons
                                    .send),

                        color:
                            const Color(
                                0xFFFFD700),

                        onPressed:
                            sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
