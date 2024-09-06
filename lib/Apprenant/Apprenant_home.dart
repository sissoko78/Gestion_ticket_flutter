import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gestion_ticket_flutter/Admin/Parametre.dart';
import 'package:gestion_ticket_flutter/Composant/Liste_Disscussion.dart';
import 'Vue_ticket.dart';

class ApprenantHome extends StatefulWidget {
  const ApprenantHome({super.key});

  @override
  State<ApprenantHome> createState() => _ApprenantHomeState();
}

class _ApprenantHomeState extends State<ApprenantHome> {
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
            children: [Ticket_page(), ListeDisscussion(), ParametrePage()],
          )),
    );
  }
}
