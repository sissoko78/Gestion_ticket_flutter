import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ParametrePage extends StatefulWidget {
  const ParametrePage({super.key});

  @override
  State<ParametrePage> createState() => _ParametrePageState();
}

class _ParametrePageState extends State<ParametrePage> {
  Future<User?> getCurrentUser() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    return _auth.currentUser;
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    return await FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profil",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<User?>(
        future: getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return Center(child: Text('Aucun utilisateur connecté.'));
          }

          User? user = snapshot.data;
          return FutureBuilder<DocumentSnapshot>(
            future: getUserData(user!.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData) {
                return Center(child: Text('Données utilisateur non trouvées.'));
              }

              var userData = userSnapshot.data!.data() as Map<String, dynamic>;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildUserInfoTile(
                          icon: Icons.person,
                          title: 'Nom',
                          value: userData['nom'] ?? 'Non renseigné',
                        ),
                        _buildUserInfoTile(
                          icon: Icons.person_outline,
                          title: 'Prénom',
                          value: userData['prenom'] ?? 'Non renseigné',
                        ),
                        _buildUserInfoTile(
                          icon: Icons.school,
                          title: 'Promotion',
                          value: userData['promotion'] ?? 'Non renseigné',
                        ),
                        _buildUserInfoTile(
                          icon: Icons.email,
                          title: 'Email',
                          value: userData['email'] ?? 'Pas d\'email',
                        ),
                        // Ajoutez plus d'informations utilisateur ici si nécessaire
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserInfoTile(
      {required IconData icon, required String title, required String value}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}
