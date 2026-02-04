import 'package:flutter/material.dart';

import '../../widgets/logo.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Logo(),
          const SizedBox(height: 16),
          const Text(
            'Cron Clock',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Version 1.0.0',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cron Clock is for the nerds who want to schedule tasks using the cron expression.\n'
            'For more such apps checkout DEV007.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Developer'),
            subtitle: const Text('DEV007'),
          ),

          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Contact'),
            subtitle: const Text('prashanith007@example.com'),
          ),

          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Website'),
            subtitle: const Text('www.nullinfinity1010.com'),
          ),

          const SizedBox(height: 24),

          Text(
            '© ${DateTime.now().year} Your Company',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
