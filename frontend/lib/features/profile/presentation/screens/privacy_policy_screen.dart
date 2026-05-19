import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Section(
            icon: Icons.shield_outlined,
            title: 'Our Commitment',
            body:
                'FindMyPart values user privacy and is committed to protecting personal information and user data. The application securely stores account information, authentication credentials, uploaded images, and communication data using protected backend systems and encrypted authentication methods. User information is never shared with unauthorized third parties, and all collected data is used only to improve application functionality and user experience.',
          ),
          _Section(
            icon: Icons.person_outline,
            title: 'Information We Collect',
            body:
                'We collect information you provide directly, including your name, email address, phone number, and profile details. We also collect data you submit through listings, chat messages, and issue reports to enable core app features.',
          ),
          _Section(
            icon: Icons.lock_outline,
            title: 'How We Protect Your Data',
            body:
                'All data is transmitted over encrypted HTTPS connections. Passwords are hashed and never stored in plain text. Authentication is handled using industry-standard token-based methods (Laravel Sanctum).',
          ),
          _Section(
            icon: Icons.location_on_outlined,
            title: 'Location Data',
            body:
                'Location access is used solely to show nearby garages and scrapyards. Location data is never stored on our servers and is only used in real time within the app.',
          ),
          _Section(
            icon: Icons.image_outlined,
            title: 'Images & Media',
            body:
                'Photos you upload for listings or your profile are stored securely. They are only used to display your listings to other users and are not shared externally.',
          ),
          _Section(
            icon: Icons.delete_outline,
            title: 'Your Rights',
            body:
                'You may request deletion of your account and associated data at any time by contacting our support team. Upon request, all personal data will be permanently removed from our systems.',
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: May 2025',
            style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Section({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
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
