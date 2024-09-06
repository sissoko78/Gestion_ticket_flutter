import 'package:flutter/material.dart';
import 'package:gestion_ticket_flutter/Admin/Parametre.dart';

import 'Vue_ticket.dart';

class Routage extends StatefulWidget {
  const Routage({super.key});

  @override
  State<Routage> createState() => _TicketPageState();
}

class _TicketPageState extends State<Routage> {
  GlobalKey<NavigatorState> RoutageNavigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: RoutageNavigatorKey,
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (BuildContext context) {
            if (settings.name == '') {
              return Ticket_page();
            }

            return Container();
          },
        );
      },
    );
  }
}
