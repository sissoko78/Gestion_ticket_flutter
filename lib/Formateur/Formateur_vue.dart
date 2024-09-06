import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gestion_ticket_flutter/Admin/Parametre.dart';
import 'package:gestion_ticket_flutter/Composant/Liste_Disscussion.dart';
import 'package:gestion_ticket_flutter/Formateur/Repondre_ticket.dart';

class FormateurVue extends StatefulWidget {
  const FormateurVue({super.key});

  @override
  State<FormateurVue> createState() => _FormateurVueState();
}

class _FormateurVueState extends State<FormateurVue> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              selectedIndex = index;
            });
          },
          destinations: const <NavigationDestination>[
            NavigationDestination(
              selectedIcon: Icon(FontAwesomeIcons.ticket),
              icon: Icon(FontAwesomeIcons.ticketSimple),
              label: 'Ticket',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.chat),
              icon: Icon(Icons.chat),
              label: 'Discussion',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings),
              label: 'Parametre',
            )
          ]),
      body: SafeArea(
          top: false,
          child: IndexedStack(
            index: selectedIndex,
            children: [
              RepondreTicket(),
              ListeDisscussion(),
              ParametrePage(),
            ],
          )),
    );
  }
}
