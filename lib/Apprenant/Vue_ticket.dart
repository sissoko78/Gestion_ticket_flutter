import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';

import 'package:gestion_ticket_flutter/Apprenant/DiscussionPage.dart';
import 'package:gestion_ticket_flutter/Composant/Formulaire.dart';
import '../Composant/Ajout_Ticket.dart';

class Ticket_page extends StatefulWidget {
  const Ticket_page({super.key});

  @override
  State<Ticket_page> createState() => _Ticket_pageState();
}

class _Ticket_pageState extends State<Ticket_page>
    with SingleTickerProviderStateMixin {
  final rechercheController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Afficher la boîte de dialogue pour ajouter un ticket
  void ticketformulaire() {
    showDialog(
      context: context,
      builder: (context) => FormulaireTicket(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications))
        ],
        title: Container(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Tickets',
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 40,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Tout'),
            Tab(text: 'Pédagogique'),
            Tab(text: 'Technique'),
            Tab(text: 'Autres'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 30),
            Formulaire(
              controller: rechercheController,
              hintText: 'Recherche',
              obscureText: false,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTicketList(),
                  _buildTicketList(categorie: 'Pédagogique'),
                  _buildTicketList(categorie: 'Technique'),
                  _buildTicketList(categorie: 'Autres'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ticketformulaire,
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Ajouter un ticket',
      ),
    );
  }

  Widget _buildTicketList({String? categorie}) {
    Query query = FirebaseFirestore.instance
        .collection('tickets')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid);

    if (categorie != null) {
      query = query.where('categorie', isEqualTo: categorie);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Aucun ticket trouvé.'));
        }

        return ListView(
          padding: EdgeInsets.all(8.0),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final titre = data['titre'] ?? 'Sans titre';
            final statut = data['status'] ?? 'Non défini';
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            final formattedDate =
                "${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}";
            final reponse = data['reponse'] ?? '';
            final hasReponse = reponse.isNotEmpty;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200], // Couleur de fond gris
                borderRadius: BorderRadius.circular(12.0), // Bordure arrondie
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2), // Position de l'ombre
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                title: Text(
                  titre,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text('Statut: $statut'),
                trailing: hasReponse
                    ? Icon(FontAwesomeIcons.message, color: Colors.blueAccent)
                    : null,
                onTap: () => _showTicketDetails(data, doc.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Méthode pour afficher les détails du ticket dans une boîte de dialogue
  void _showTicketDetails(Map<String, dynamic> ticket, String ticketId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ticket['titre']),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Statut: ${ticket['status']}'),
            Text('Catégorie: ${ticket['categorie']}'),
            Text('Description: ${ticket['description']}'),
            Text(
              'Envoyé le: ${((ticket['createdAt'] as Timestamp).toDate()).toLocal()}',
            ),
            SizedBox(height: 20),
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('reponses')
                  .where('ticketId', isEqualTo: ticketId)
                  .limit(1)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  final responseData =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  final responseText =
                      responseData['reponse'] ?? 'Pas de réponse';
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('Réponse du formateur: $responseText'),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text('Aucune réponse du formateur'),
                );
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DiscussionPage(
                    ticketId: ticketId,
                    formateurId: ticket['formateurId'] ?? '',
                  ),
                ),
              );
            },
            child: Text('Entamez une discussion'),
          ),
        ],
      ),
    );
  }
}
