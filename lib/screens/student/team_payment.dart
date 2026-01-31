import 'package:flutter/material.dart';

class TeamPaymentScreen extends StatelessWidget {
  final String teamId;
  
  const TeamPaymentScreen({super.key, required this.teamId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Team Payment')),
      body: Center(child: Text('Team Payment for $teamId - To be implemented')),
    );
  }
}






