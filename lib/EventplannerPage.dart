import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventplannerPage extends StatefulWidget {
  const EventplannerPage({super.key});

  @override
  State<EventplannerPage> createState() => _EventplannerPageState();
}

class _EventplannerPageState extends State<EventplannerPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Planner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Event Planner Page'),
      ),
    );
  }
}