import 'package:flutter/material.dart';

import 'login_instruction_page.dart';

class SignupInstruction extends StatelessWidget {
  const SignupInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return InstructionCard(
      title: "Signup Instructions",
      description: "Create your new account in a few simple steps.",
      sections: [
        Section(
          title: "1. Enter Mobile Number:",
          items: [
            "Type your mobile number on the signup screen.",
            "Tap on “Send OTP”.",
            "You will receive a 6-digit OTP via SMS.",
          ],
        ),
        Section(
          title: "2. Verify OTP:",
          items: [
            "Enter the 6-digit OTP received.",
            "Tap on “Verify OTP”.",
            "If the OTP is valid, you will be moved to the next step.",
          ],
        ),
        Section(
          title: "3. Choose Account Type:",
          items: [
            "Select whether you are signing up as:",
            "• Teacher",
            "• Student",
            "• Guest (Limited Access)",
          ],
        ),
        Section(
          title: "4. Fill Your Details:",
          items: [
            "Enter your basic information (name, email, etc.).",
            "For teachers, fill additional professional details.",
            "Review your entered information before submission.",
          ],
        ),
        Section(
          title: "5. Submit:",
          items: [
            "Tap on “Submit”.",
            "Your account will be created successfully.",
            "You will be redirected to your dashboard.",
          ],
        ),
      ],
    );
  }
}
