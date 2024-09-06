import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_ticket_flutter/Composant/Button.dart';
import 'package:gestion_ticket_flutter/Composant/Formulaire.dart';

class Inscription_page extends StatefulWidget {
  const Inscription_page({super.key});

  @override
  State<Inscription_page> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<Inscription_page> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final prenomController = TextEditingController();
  final nomController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Méthode d'inscription
  void signUp() async {
    // Validation des champs
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showDialog('Tous les champs doivent être remplis');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showDialog('Les mots de passe ne correspondent pas');
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
        'role': 'apprenant', // Défini le rôle par défaut
        'createdAt': Timestamp.now(),
      });

      // Connexion réussie, redirection vers une autre page
      Navigator.pushReplacementNamed(
          context, '/Apprenant'); // Assure-toi que cette route est définie
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs d'authentification
      _showDialog('Erreur: ${e.message}');
    } catch (e) {
      _showDialog('Erreur inconnue: $e');
    }
  }

  // Afficher une boîte de dialogue pour les erreurs
  void _showDialog(String message) {
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
                    obscureText: false),
                const SizedBox(height: 20),

                // Nom
                Formulaire(
                    controller: nomController,
                    hintText: 'Nom',
                    obscureText: false),
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

                // Bouton d'inscription
                Button(
                  onTap: signUp,
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
