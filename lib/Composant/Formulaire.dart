import 'package:flutter/material.dart';

class Formulaire extends StatefulWidget {
  final controller; // va permettre de recuperer les données saisie
  final String hintText; // va m'indiquer le nom de la case
  final bool obscureText; // Permet de hacher les saisies

  Formulaire(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText});

  @override
  State<Formulaire> createState() => _FormulaireState();
}

class _FormulaireState extends State<Formulaire> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent),
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: widget.hintText)),
    );
  }
}
