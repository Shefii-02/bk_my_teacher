import 'package:flutter/material.dart';

class SignUpStepper extends StatefulWidget {
  const SignUpStepper({super.key});

  @override
  State<SignUpStepper> createState() => _SignUpStepperState();
}

class _SignUpStepperState extends State<SignUpStepper> {
  int currentStep = 0;
  String selectedRole = '';

  List<Step> getSteps() {
    return [
      Step(
        title: const Text('Choose Account Type'),
        content: Column(
          children: [
            RadioListTile<String>(
              title: const Text("Student"),
              value: 'student',
              groupValue: selectedRole,
              onChanged: (value) {
                setState(() => selectedRole = value!);
              },
            ),
            RadioListTile<String>(
              title: const Text("Teacher"),
              value: 'teacher',
              groupValue: selectedRole,
              onChanged: (value) {
                setState(() => selectedRole = value!);
              },
            ),
          ],
        ),
        isActive: currentStep >= 0,
        state: StepState.indexed,
      ),
      Step(
        title: const Text('Personal Info'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
        ),
        isActive: currentStep >= 1,
        state: StepState.indexed,
      ),
      Step(
        title: const Text('Done'),
        content: const Text("Signup Completed!"),
        isActive: currentStep >= 2,
        state: StepState.complete,
      ),
    ];
  }

  void onStepContinue() {
    if (currentStep < getSteps().length - 1) {
      setState(() => currentStep++);
    } else {
      // Save account type to Hive
      // Then redirect
      Navigator.pop(context); // Back to login
    }
  }

  void onStepCancel() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Stepper(
        currentStep: currentStep,
        steps: getSteps(),
        onStepContinue: onStepContinue,
        onStepCancel: onStepCancel,
      ),
    );
  }
}
