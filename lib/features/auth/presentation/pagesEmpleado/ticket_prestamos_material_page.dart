import 'package:flutter/material.dart';

class TicketPrestamosMaterialPage extends StatefulWidget {
  const TicketPrestamosMaterialPage({super.key});

  @override
  State<TicketPrestamosMaterialPage> createState() => _TicketPrestamosMaterialPageState();
}

class _TicketPrestamosMaterialPageState extends State<TicketPrestamosMaterialPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        title: const Text('Ticket de Préstamo'),
        backgroundColor: const Color(0xFFF5F8FF),
      ),
      body: const Center(
        child: Text(
          'Estoy en ticket',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF193F6E),
          ),
        ),
      ),
    );
  }
}