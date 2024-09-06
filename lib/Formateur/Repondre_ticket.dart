import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RepondreTicket extends StatefulWidget {
  const RepondreTicket({super.key});

  @override
  State<RepondreTicket> createState() => _RepondreTicketState();
}

class _RepondreTicketState extends State<RepondreTicket>
    with SingleTickerProviderStateMixin {
  String _response = ''; // Variable pour stocker la réponse de l'utilisateur
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

  // Méthode pour envoyer la réponse au ticket
  void _sendResponse(String ticketId) async {
    if (_response.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer une réponse.')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser!;

    try {
      // Ajouter la réponse au ticket dans la collection 'reponses'
      await FirebaseFirestore.instance.collection('reponses').add({
        'ticketId': ticketId,
        'formateurId': currentUser.uid, // Utiliser l'ID du formateur actuel
        'reponse': _response,
        'reponseAt': Timestamp.now(),
      });

      // Mettre à jour le ticket pour marquer comme répondu
      await FirebaseFirestore.instance
          .collection('tickets')
          .doc(ticketId)
          .update({
        'status': 'répondu',
        'reponseAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Réponse envoyée avec succès')),
      );
      setState(() {
        _response = ''; // Réinitialiser la réponse après l'envoi
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
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
            'Tickets à Répondre',
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTicketList(),
          _buildTicketList(categorie: 'Pédagogique'),
          _buildTicketList(categorie: 'Technique'),
          _buildTicketList(categorie: 'Autres'),
        ],
      ),
    );
  }

  Widget _buildTicketList({String? categorie}) {
    Query query = FirebaseFirestore.instance.collection('tickets');

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
          return Center(child: Text('Aucun ticket disponible.'));
        }

        final tickets = snapshot.data!.docs;

        return ListView(
          padding: EdgeInsets.all(8.0),
          children: tickets.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final titre = data['titre'] ?? 'Sans titre';
            final statut = data['status'] ?? 'Non défini';
            final createdAt = (data['createdAt'] as Timestamp).toDate();
            final formattedDate =
                "${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute}";

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
                trailing: Text(formattedDate),
                onTap: () => _showTicketDetails(doc.id, data),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Afficher les détails du ticket dans une boîte de dialogue
  void _showTicketDetails(String ticketId, Map<String, dynamic> ticketData) {
    // Vérifier si le ticket est déjà pris en charge
    final bool isAssigned = ticketData['status'] == 'en cours';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ticketData['titre']),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Catégorie: ${ticketData['categorie']}'),
            Text('Description: ${ticketData['description']}'),
            Text('Envoyé par: ${ticketData['userEmail']}'),
            Text(
                'Envoyé le: ${((ticketData['createdAt'] as Timestamp).toDate()).toLocal()}'),
            SizedBox(height: 20),
            if (isAssigned) ...[
              // Si le ticket est pris en charge, afficher le champ de réponse
              TextField(
                decoration: InputDecoration(labelText: 'Réponse'),
                onChanged: (value) {
                  setState(() {
                    _response = value;
                  });
                },
                maxLines: 4,
              ),
            ],
          ],
        ),
        actions: <Widget>[
          if (!isAssigned) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                _showTakeOwnershipDialog(
                    ticketId); // Afficher la boîte de dialogue de prise en charge
              },
              child: Text('Prendre en charge'),
            ),
          ],
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer la boîte de dialogue
            },
            child: Text('Annuler'),
          ),
          if (isAssigned) ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                _sendResponse(ticketId); // Envoyer la réponse
              },
              child: Text('Envoyer'),
            ),
          ],
        ],
      ),
    );
  }

  void _showTakeOwnershipDialog(String ticketId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Prendre en charge le ticket'),
        content: Text('Voulez-vous vraiment prendre ce ticket en charge ?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer la boîte de dialogue
            },
            child: Text('Non'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Fermer la boîte de dialogue

              final currentUser = FirebaseAuth.instance.currentUser!;

              try {
                // Mettre à jour le statut du ticket pour le marquer comme "en cours"
                await FirebaseFirestore.instance
                    .collection('tickets')
                    .doc(ticketId)
                    .update({
                  'status': 'en cours',
                  'assignedTo': currentUser.uid,
                  // Enregistrer l'ID du formateur qui prend en charge le ticket
                  'assignedAt': Timestamp.now(),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ticket pris en charge avec succès')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            },
            child: Text('Oui'),
          ),
        ],
      ),
    );
  }
}
