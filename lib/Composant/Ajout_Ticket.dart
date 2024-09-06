import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FormulaireTicket extends StatefulWidget {
  const FormulaireTicket({super.key});

  @override
  State<FormulaireTicket> createState() => _FormulaireTicketState();
}

class _FormulaireTicketState extends State<FormulaireTicket> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? choixCat;

  final List<String> _categories = ['Technique', 'Pédagogique', 'Autres'];

  // Méthode pour ajouter un ticket
  void AjouterTicket() async {
    if (_formKey.currentState!.validate()) {
      // Récupérer les valeurs du formulaire
      final titre = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final categorie = choixCat;

      // Ajoutez un print pour déboguer
      print('Titre: $titre');
      print('Description: $description');
      print('Catégorie: $categorie');

      try {
        // Obtenir l'utilisateur courant
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          throw Exception('Utilisateur non authentifié');
        }

        // Ajouter le ticket à Firestore avec un statut par défaut
        await FirebaseFirestore.instance.collection('tickets').add({
          'titre': titre,
          'description': description,
          'categorie': categorie ??
              'Non spécifiée', // Valeur par défaut si aucune catégorie sélectionnée
          'userId': user.uid,
          'userEmail': user.email,
          'status': 'en attente', // Statut par défaut
          'createdAt': Timestamp.now(),
        });

        // Fermer la boîte de dialogue et montrer un message de succès
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket ajouté avec succès')),
        );
      } catch (e) {
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: choixCat,
                hint: Text('Catégorie'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    choixCat = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner une catégorie';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: AjouterTicket,
                child: Text('Ajouter Ticket'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
