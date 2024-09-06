import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_ticket_flutter/Apprenant/DiscussionPage.dart';

class ListeDisscussion extends StatefulWidget {
  @override
  ListeDisscussionState createState() => ListeDisscussionState();
}

class ListeDisscussionState extends State<ListeDisscussion> {
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste des Discussions',
          style: TextStyle(fontSize: 40, color: Colors.blueAccent),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('discussions')
            .where('userIds', arrayContains: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucune discussion trouvée.'));
          }

          final discussions = snapshot.data!.docs;
          final userIds = <String>{};

          for (var doc in discussions) {
            final data = doc.data() as Map<String, dynamic>;
            final ids = List<String>.from(data['userIds'] ?? []);
            ids.remove(currentUser.uid); // Exclure l'utilisateur actuel
            userIds.addAll(ids);
          }

          return FutureBuilder<List<DocumentSnapshot>>(
            future: _fetchUsers(userIds.toList()),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData || userSnapshot.data!.isEmpty) {
                return Center(child: Text('Aucun utilisateur trouvé.'));
              }

              final users = userSnapshot.data!;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data() as Map<String, dynamic>;
                  final userName = user['nom'] ?? 'Utilisateur inconnu';
                  final userId = users[index].id;

                  return ListTile(
                    title: Text(userName),
                    onTap: () => _openDiscussion(userId),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> _fetchUsers(List<String> userIds) async {
    final futures = userIds.map((userId) =>
        FirebaseFirestore.instance.collection('users').doc(userId).get());
    return await Future.wait(futures);
  }

  void _openDiscussion(String userId) async {
    // Récupérer l'ID du ticket associé à la discussion avec cet utilisateur
    final query = await FirebaseFirestore.instance
        .collection('discussions')
        .where('userIds', arrayContains: currentUser.uid)
        .where('userIds', arrayContains: userId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final ticketId = query.docs.first.id;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiscussionPage(
            ticketId: ticketId,
            formateurId: userId, // Utilisez l'ID de l'utilisateur sélectionné
          ),
        ),
      );
    } else {
      // Gérer le cas où il n'y a pas de ticket associé à cette discussion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Aucune discussion trouvée avec cet utilisateur.')),
      );
    }
  }
}
