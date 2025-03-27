import 'package:cst2335_final/database.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleMaintenancePage extends StatefulWidget {
  const VehicleMaintenancePage({super.key, required AppDatabase database});

  @override
  State<VehicleMaintenancePage> createState() => _VehicleMaintenancePageState();
}

class _VehicleMaintenancePageState extends State<VehicleMaintenancePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Maintenance'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Text('Vehicle Maintenance Page'),
      ),
    );
  }
}