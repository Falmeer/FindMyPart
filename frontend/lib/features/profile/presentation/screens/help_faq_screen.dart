import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _intro(
            'FindMyPart is designed to simplify access to automotive services, spare parts, garages, and scrapyards across Bahrain. The Help & FAQ section provides users with answers to common questions related to account registration, spare part listings, AI dashboard detection, maps navigation, chat functionality, and troubleshooting support. Users can also contact the support team for additional assistance when needed.',
          ),
          const SizedBox(height: 24),
          _FaqItem(
            question: 'How do I create an account?',
            answer:
                'Open the app and tap "Register". Fill in your name, email, phone number, and password. A verification code will be sent to your phone to activate your account.',
          ),
          _FaqItem(
            question: 'How do I list a spare part for sale?',
            answer:
                'Go to the Spare Parts section and tap the "+" button. Add photos, a title, description, price, and your contact details. Your listing will be visible to buyers immediately.',
          ),
          _FaqItem(
            question: 'What is the AI Warning Light Scanner?',
            answer:
                'The AI Scanner lets you photograph a dashboard warning light and receive an instant AI-powered explanation of what it means and recommended next steps.',
          ),
          _FaqItem(
            question: 'How does the map feature work?',
            answer:
                'The app uses your GPS location to show nearby garages and scrapyards on the map. You can tap any listing to get directions through Google Maps.',
          ),
          _FaqItem(
            question: 'How do I contact a garage or seller?',
            answer:
                'Open the garage, scrapyard, or spare part listing and tap the "Contact" button. This opens a direct in-app chat with the other party.',
          ),
          _FaqItem(
            question: 'I forgot my password. What should I do?',
            answer:
                'On the login screen, tap "Forgot Password?" and follow the instructions sent to your registered email address.',
          ),
          _FaqItem(
            question: 'How do I contact support?',
            answer:
                'For additional help, contact us on WhatsApp at +973 33399330 and our team will assist you.',
          ),
        ],
      ),
    );
  }

  Widget _intro(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.65),
      ),
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  Icon(
                    _open ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              if (_open) ...[
                const SizedBox(height: 10),
                Text(
                  widget.answer,
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.6),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
