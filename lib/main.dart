import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gestion_ticket_flutter/Admin/Apprenant.dart';
import 'package:gestion_ticket_flutter/Admin/Dashbord.dart';
import 'package:gestion_ticket_flutter/Admin/FAQ.dart';
import 'package:gestion_ticket_flutter/Admin/User_page.dart';
import 'package:gestion_ticket_flutter/Admin/Parametre.dart';
import 'package:gestion_ticket_flutter/Apprenant/Apprenant_home.dart';
import 'package:gestion_ticket_flutter/Apprenant/DiscussionPage.dart';
import 'package:gestion_ticket_flutter/Formateur/Formateur_vue.dart';
import 'package:gestion_ticket_flutter/Login/Inscription.dart';
import 'package:gestion_ticket_flutter/Login/Loginpage.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assure-toi d'importer Cloud Firestore

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => LoginPage(),
        "/Dashbord": (context) => HomePage(),
        "/Formateur": (context) => FormateurPage(),
        "/Apprenants": (context) => ApprenantPage(),
        "/FAQ": (context) => FaqPage(),
        "/Parametre": (context) => ParametrePage(),
        '/Inscription': (context) => Inscription_page(),
        '/Apprenant': (context) => ApprenantHome(),
        '/formateur': (context) => FormateurVue(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/Discussion') {
          final arguments = settings.arguments as Map<String, dynamic>;
          final ticketId = arguments['ticketId'];
          final formateurId = arguments['formateurId'];
          return MaterialPageRoute(
            builder: (context) =>
                DiscussionPage(ticketId: ticketId, formateurId: formateurId),
          );
        }
      },
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.teal, primary: Colors.blueAccent)),
    );
  }
}
