import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gestion_ticket_flutter/Composant/Button.dart';
import 'package:gestion_ticket_flutter/Composant/Formulaire.dart';

class Ajout_User extends StatefulWidget {
  const Ajout_User({super.key});

  @override
  State<Ajout_User> createState() => _Ajout_UserState();
}

class _Ajout_UserState extends State<Ajout_User> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final prenomController = TextEditingController();
  final nomController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final roleController = TextEditingController();

  // Méthode d'inscription
  void Useradd() async {
    // Validation des champs
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      Dialog('Remplissez bien les champs');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Dialog('Les mots de passe ne sont pas similaires');
      return;
    }

    try {
      // Création du compte utilisateur
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Ajout des informations de l'utilisateur à Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'nom': nomController.text.trim(),
        'prenom': prenomController.text.trim(),
        'email': emailController.text.trim(),
        'role': roleController.text.trim(), // Défini le rôle par défaut
        'createdAt': Timestamp.now(),
      });

      // Optionnel: Afficher une boîte de dialogue de succès ou rediriger l'utilisateur
      Dialog('Utilisateur ajouté avec succès !');
    } catch (e) {
      Dialog('Erreur inconnue: $e');
    }
  }

  // Afficher une boîte de dialogue pour les erreurs
  void Dialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erreur'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                // Logo ou icône
                const Icon(
                  Icons.person_add,
                  size: 100,
                ),
                const SizedBox(height: 20),
                // Titre de la page
                const Text(
                  "Inscription",
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 40),
                // Email
                Formulaire(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                // Prénom
                Formulaire(
                  controller: prenomController,
                  hintText: 'Prénom',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                // Nom
                Formulaire(
                  controller: nomController,
                  hintText: 'Nom',
                  obscureText: false,
                ),
                const SizedBox(height: 20),
                // Mot de passe
                Formulaire(
                  controller: passwordController,
                  hintText: 'Mot de passe',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                // Confirmer le mot de passe
                Formulaire(
                  controller: confirmPasswordController,
                  hintText: 'Confirmer le mot de passe',
                  obscureText: true,
                ),
                const SizedBox(height: 40),
                // Rôle
                Formulaire(
                  controller: roleController,
                  hintText: 'Rôle',
                  obscureText: false,
                ),
                const SizedBox(height: 40),
                // Bouton d'inscription
                Button(
                  onTap: Useradd,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
