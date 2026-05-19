import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About FindMyPart')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Logo / App identity
          Center(
            child: Column(
              children: [
                Image.asset('assets/images/logo_icon.png', width: 88, height: 88),
                const SizedBox(height: 14),
                const Text('FindMyPart',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Version 1.0.0',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 28),

          _Block(
            'About the App',
            'FindMyPart is a smart automotive platform developed as a senior graduation project at the University of Bahrain. The application aims to simplify the process of finding spare parts, garages, scrapyards, salvaged vehicles, and automotive services through one centralized digital platform.',
          ),
          _Block(
            'Technologies',
            'The system integrates modern technologies including AI-based dashboard warning detection, real-time chat, GPS location services, and cloud storage solutions to improve accessibility and communication within Bahrain\'s automotive sector.',
          ),

          const SizedBox(height: 8),
          const Text('Developed By',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          _DeveloperCard(
            name: 'Fawaz Adel Almeer',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 10),
          _DeveloperCard(
            name: 'Mohamed Abdulmonem Aljanahi',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'FindMyPart was created to provide a modern and efficient automotive ecosystem that connects vehicle owners, garages, scrapyards, and spare part sellers through one integrated application.',
              style: TextStyle(fontSize: 14, height: 1.65),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '© 2025 University of Bahrain — Senior Project',
            style: TextStyle(
                fontSize: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final String title;
  final String body;
  const _Block(this.title, this.body);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          Text(body,
              style: const TextStyle(fontSize: 14, height: 1.65)),
          const SizedBox(height: 4),
          Divider(color: Colors.grey.shade100),
        ],
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  final String name;
  final IconData icon;
  const _DeveloperCard({required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}
