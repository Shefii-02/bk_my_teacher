import 'package:flutter/material.dart';

class LoginInstructionPage extends StatelessWidget {
  const LoginInstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            GoogleLoginInstruction(),
            SizedBox(height: 16),
            MobileOTPInstruction(),
            SizedBox(height: 16),
            SecurityNotes(),
          ],
        ),
    );
  }
}

//
// 🔹 GOOGLE LOGIN INSTRUCTION WIDGET
//
class GoogleLoginInstruction extends StatelessWidget {
  const GoogleLoginInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return InstructionCard(
      title: "1. Login with Google",
      description: "Fast and secure login using your Google account.",
      sections: [
        Section(
          title: "Steps:",
          items: [
            "Tap on “Continue with Google”.",
            "Select your Google account from the list.",
            "Grant permission to proceed.",
            "You will be logged in automatically and redirected to your dashboard.",
          ],
        ),
        Section(
          title: "Requirements:",
          items: [
            "A valid Google account.",
            "Internet connection.",
            "Google Play Services (for Android users).",
          ],
        ),
      ],
    );
  }
}

//
// 🔹 MOBILE OTP LOGIN INSTRUCTION WIDGET
//
class MobileOTPInstruction extends StatelessWidget {
  const MobileOTPInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return InstructionCard(
      title: "2. Login with Mobile Number (OTP)",
      description: "Login using your mobile number and a one-time password (OTP).",
      sections: [
        Section(
          title: "Steps:",
          items: [
            "Enter your mobile number in the login screen.",
            "Tap “Send OTP”.",
            "You will receive a 6-digit OTP via SMS.",
            "Enter the OTP and tap “Verify”.",
            "If the OTP is correct, you will be logged in instantly.",
          ],
        ),
        Section(
          title: "If you didn’t receive the OTP:",
          items: [
            "Wait for 30–60 seconds.",
            "Tap “Resend OTP”.",
            "Check if your mobile has proper network coverage.",
            "Ensure you entered the correct mobile number.",
          ],
        ),
      ],
    );
  }
}

//
// 🔹 SECURITY NOTES
//
class SecurityNotes extends StatelessWidget {
  const SecurityNotes({super.key});

  @override
  Widget build(BuildContext context) {
    return InstructionCard(
      title: "Security Notes",
      description: "",
      sections: [
        Section(
          items: [
            "We do not store or share your Google password.",
            "OTP login ensures your number is verified before accessing the platform.",
            "All login sessions are secured and encrypted.",
          ],
        ),
      ],
    );
  }
}

//
// 🔹 REUSABLE INSTRUCTION CARD WIDGET
//
class InstructionCard extends StatelessWidget {
  final String title;
  final String description;
  final List<Section> sections;

  const InstructionCard({
    super.key,
    required this.title,
    required this.description,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(description,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700])),
            ],
            const SizedBox(height: 14),

            // Render all sections dynamically
            for (var section in sections) ...[
              if (section.title != null) ...[
                Text(
                  section.title!,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
              ],

              for (var item in section.items) _bullet(item),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

//
// 🔹 SECTION MODEL FOR REUSABILITY
//
class Section {
  final String? title;
  final List<String> items;

  const Section({
    this.title,
    required this.items,
  });
}
