import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sgovs/home.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class ChatMessage {
  final String message;
  final DateTime timestamp;
  final String senderId;
  final String receiverId;

  ChatMessage({
    required this.message,
    required this.timestamp,
    required this.senderId,
    required this.receiverId,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      senderId: json['senderId'],
      receiverId: json['receiverId'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatPage(),
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late List<ChatMessage> _chatMessages;
  late TextEditingController _messageController;
  late List<Map<String, dynamic>> _admins;
  String? _selectedAdminId;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _chatMessages = [];
    _messageController = TextEditingController();
    _admins = [];
    _fetchAdmins(); 
    _startTimer();// Fetch admins when the app starts
  }
  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      // Fetch messages every 10 seconds
      if (_selectedAdminId != null) {
        _fetchMessagesWithAdmin(_selectedAdminId!);
      }
    });
  }

  Future<void> _fetchAdmins() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int participantId = prefs.getInt('participant_id') ?? 0;

    final response = await http.get(
      Uri.parse(
          'http://regestrationrenion.atwebpages.com/api2.php?action=fetch_admins&participant_id=$participantId'),
    );
    print("ssssssssssssssss:${response.body}");
    if (response.statusCode == 200) {
      List<Map<String, dynamic>> admins = [];
      List<dynamic> responseData = jsonDecode(response.body);
      
      // Use a set to ensure uniqueness of admin records
      Set<String> adminIds = Set();

      // Loop through the response data to filter out duplicates
      responseData.forEach((adminData) {
        String adminId = adminData['id'].toString();
        if (!adminIds.contains(adminId)) {
          adminIds.add(adminId);
          admins.add(adminData);
        }
      });

      setState(() {
        _admins = admins;
      });
    } else {
      throw Exception('Failed to fetch admins');
    }
  } catch (e) {
    print("Error fetching admins: $e");
  }
}

  Future<void> _fetchMessagesWithAdmin(String adminId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int participantId = prefs.getInt('participant_id') ?? 0;

      final response = await http.get(
        Uri.parse(
            'http://regestrationrenion.atwebpages.com/api3.php?action=fetch_messages&admin_id=$adminId&participant_id=$participantId'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _chatMessages = data.map((e) => ChatMessage.fromJson(e)).toList();
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }

  Future<void> _sendMessage(String message, String receiverId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int participantId = prefs.getInt('participant_id') ?? 0;

      final response = await http.post(
        Uri.parse('http://regestrationrenion.atwebpages.com/participant_messages.php'),
        body: jsonEncode(<String, String>{
          'action': 'send_message',
          'message': message,
          'senderId': participantId.toString(),
          'receiverId': receiverId,
        }),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 201) {
        _fetchMessagesWithAdmin(receiverId);
        _messageController.clear();
      } else {
        print("Failed to send message: ${response.body}");
        throw Exception('Failed to send message');
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Chat'),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),);
        },
      ),
    ),
    body: Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: ListView.builder(
              itemCount: _admins.length,
              itemBuilder: (context, index) {
                final admin = _admins[index];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAdminId = admin['id'];
                      _fetchMessagesWithAdmin(_selectedAdminId!);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[200]!,
                        ),
                      ),
                    ),
                    child: Text(
                      '${admin['name']} ${admin['prename']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      final message = _chatMessages[index];
                      final isParticipantMessage = message.senderId != _selectedAdminId;

                      return Row(
                        mainAxisAlignment: isParticipantMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                              padding: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: isParticipantMessage ? Colors.blue : Colors.grey,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Column(
                                crossAxisAlignment: isParticipantMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.message,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    message.timestamp.toString(),
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Enter message...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_messageController.text.isNotEmpty && _selectedAdminId != null) {
                            _sendMessage(
                              _messageController.text,
                              _selectedAdminId!,
                            );
                          }
                        },
                        child: Text('Send'),
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
  );
}
}