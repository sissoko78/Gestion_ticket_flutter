import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DiscussionPage extends StatefulWidget {
  final String ticketId;
  final String formateurId;

  const DiscussionPage({
    required this.ticketId,
    required this.formateurId,
    Key? key,
  }) : super(key: key);

  @override
  _DiscussionPageState createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Discussion'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('discussions')
                  .doc(widget.ticketId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Aucun message'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    final isFromCurrentUser = message['userId'] ==
                        FirebaseAuth.instance.currentUser!.uid;

                    return ListTile(
                      title: Text(message['text']),
                      subtitle: Text(
                        isFromCurrentUser ? 'Vous' : 'Formateur',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      tileColor: isFromCurrentUser
                          ? Colors.blue[100]
                          : Colors.grey[100],
                      contentPadding: EdgeInsets.all(16.0),
                    );
                  },
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
                      hintText: 'Écrire un message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser!;
    final message = {
      'text': text,
      'userId': currentUser.uid,
      'timestamp': Timestamp.now(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('discussions')
          .doc(widget.ticketId)
          .collection('messages')
          .add(message);

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }
}
