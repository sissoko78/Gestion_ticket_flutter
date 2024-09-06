import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';

import '../Composant/Ajout_user.dart';

class FormateurPage extends StatefulWidget {
  const FormateurPage({super.key});

  @override
  State<FormateurPage> createState() => _FormateurPageState();
}

class _FormateurPageState extends State<FormateurPage> {
  @override
  void initState() {
    super.initState();
    // Charger la liste lorsque la page est initialisée
    // Note: _loadList_Utilisateurs n'est pas nécessaire avec StreamBuilder ici
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Liste des utilisateurs",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun utilisateur trouvé'));
          }

          return ListView(
            padding: const EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final email = data['email'] ?? 'Non défini';
              final nom = data['nom'] ?? 'Non défini';
              final prenom = data['prenom'] ?? 'Non défini';
              final createdAt = data['createdAt'] as Timestamp?;
              final formattedDate = createdAt != null
                  ? "${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year} ${createdAt.toDate().hour}:${createdAt.toDate().minute}"
                  : 'Non défini';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4.0,
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      prenom.isNotEmpty ? prenom[0].toUpperCase() : '?',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    '$prenom $nom',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    'Email: $email\nCréé le: $formattedDate',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  contentPadding: const EdgeInsets.all(16.0),
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Ajout_User()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Ajouter un utilisateur',
      ),
    );
  }
}
