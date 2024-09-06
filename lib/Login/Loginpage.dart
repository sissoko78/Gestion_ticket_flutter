import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestion_ticket_flutter/Composant/Button.dart';
import 'package:gestion_ticket_flutter/Composant/Formulaire.dart'; // Assure-toi que ce package est importé

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordControler = TextEditingController();

  // Méthode de connexion
  void signup() async {
    // Récupérer les valeurs des contrôleurs
    final email = emailController.text.trim();
    final password = passwordControler.text.trim();

    // Valider les entrées
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un email et un mot de passe.')),
      );
      return;
    }

    try {
      // Connexion avec Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Obtenir l'ID de l'utilisateur
      final userId = userCredential.user!.uid;

      // Récupérer les informations de l'utilisateur depuis Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'L\'utilisateur n\'existe pas dans la base de données.')),
        );
        return;
      }

      // Récupérer le rôle de l'utilisateur
      final userData = userDoc.data() as Map<String, dynamic>;
      final role = userData['role'];

      // Rediriger vers la page appropriée en fonction du rôle
      if (role == 'apprenant') {
        Navigator.pushReplacementNamed(context, '/Apprenant');
      } else if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/Dashbord');
      } else if (role == 'formateur') {
        Navigator.pushReplacementNamed(context, '/formateur');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rôle inconnu.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs ici
      String message = 'Erreur inconnue';
      if (e.code == 'user-not-found') {
        message = 'Aucun utilisateur trouvé avec cet email.';
      } else if (e.code == 'wrong-password') {
        message = 'Mot de passe incorrect.';
      } else if (e.code == 'invalid-email') {
        message = 'Email invalide.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              // Logo
              const Icon(
                Icons.lock,
                size: 100,
              ),
              const SizedBox(height: 20),
              // Bienvenue
              const Text(
                "Bienvenue sur la page d'authentification",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 40),

              // Email
              Formulaire(
                controller: emailController,
                hintText: 'Email',
                obscureText: false,
              ),
              const SizedBox(height: 40),
              // Mot de passe
              Formulaire(
                controller: passwordControler,
                hintText: 'Mot de passe',
                obscureText: true,
              ),

              // Mot de passe oublié
              const SizedBox(height: 20),
              // Se connecter
              Button(
                onTap: signup,
              ),
              const SizedBox(height: 20),
              // Google
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Divider(
                  height: 3,
                ),
              ),

              // S'inscrire
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/Inscription');
                },
                child: Text("Pas encore inscrit ? Inscription"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
