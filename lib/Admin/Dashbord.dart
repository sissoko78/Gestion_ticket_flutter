import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Row(
                children: [],
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Theme.of(context).primaryColor],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/");
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Utilisateurs'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/Formateur");
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('FAQ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/FAQ");
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Profil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, "/Parametre");
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(
          "Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tickets')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Débogage : Imprimer les documents récupérés
          print("Documents: ${snapshot.data!.docs}");

          int pendingTechnicalTickets = 0;
          int resolvedTechnicalTickets = 0;
          int pendingPedagogicalTickets = 0;
          int resolvedPedagogicalTickets = 0;
          int autreEnattenteTickets = 0;
          int autreResoluTickets = 0;

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'];
            final category = data['categorie'];

            // Débogage : Imprimer les données de chaque ticket
            print("Ticket Data: $data");

            if (category == 'Technique') {
              if (status == 'en attente') {
                pendingTechnicalTickets++;
              } else if (status == 'résolu') {
                resolvedTechnicalTickets++;
              }
            } else if (category == 'Pédagogique') {
              if (status == 'en attente') {
                pendingPedagogicalTickets++;
              } else if (status == 'résolu') {
                resolvedPedagogicalTickets++;
              }
            } else if (category == 'Autres') {
              if (status == 'en attente') {
                autreEnattenteTickets++;
              } else if (status == 'résolu') {
                autreResoluTickets++;
              }
            }
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDashboardCard(
                        context,
                        title: 'Technique\nEn attente',
                        count: pendingTechnicalTickets,
                        icon: Icons.build,
                        color: Colors.orange,
                      ),
                      _buildDashboardCard(
                        context,
                        title: 'Technique\nRésolu',
                        count: resolvedTechnicalTickets,
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDashboardCard(
                        context,
                        title: 'Pédagogique\nEn attente',
                        count: pendingPedagogicalTickets,
                        icon: Icons.school,
                        color: Colors.orange,
                      ),
                      _buildDashboardCard(
                        context,
                        title: 'Pédagogique\nRésolu',
                        count: resolvedPedagogicalTickets,
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDashboardCard(
                        context,
                        title: 'Autres\nEn attente',
                        count: autreEnattenteTickets,
                        icon: FontAwesomeIcons.ticket,
                        color: Colors.orange,
                      ),
                      _buildDashboardCard(
                        context,
                        title: 'Autres\nRésolu',
                        count: autreResoluTickets,
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: color.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40.0, color: color),
            SizedBox(height: 10.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
