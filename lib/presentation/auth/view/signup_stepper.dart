import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/enums/app_config.dart';

class SignUpStepper extends StatefulWidget {
  const SignUpStepper({super.key});

  @override
  State<SignUpStepper> createState() => _SignUpStepperState();
}

class _SignUpStepperState extends State<SignUpStepper> {
  String _selectedRole = "teacher";

  Widget _buildRoleCard(String value, String label, IconData icon) {
    final bool isSelected = _selectedRole == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade100, Colors.grey.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: isSelected
                  ? Colors.white
                  : Colors.green.shade100,
              child: Icon(
                icon,
                color: isSelected ? Colors.green.shade700 : Colors.green,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedRole,
              activeColor: Colors.white,
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image for AppBar section
          SizedBox(
            height: 600,
            width: double.infinity,
            child: Image.network(AppConfig.headerTop, fit: BoxFit.fitWidth),
          ),

          // Main Content with Rounded Container
          Column(
            children: [
              const SizedBox(height: 60),
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Column(
                      children: const [
                        Text(
                          'Choose Who You Are?',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Select account type',
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                    // Help button
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 290,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          _buildRoleCard(
                            "teacher",
                            "I am a Teacher",
                            Icons.school,
                          ),
                          _buildRoleCard(
                            "student",
                            "I am a Student/Parent",
                            Icons.person,
                          ),
                          // _buildRoleCard(
                          //   "guest",
                          //   "I am a Guest User (Limited Access)",
                          //   Icons.group,
                          // ),
                          const SizedBox(height: 40),

                          // 🔹 Submit button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.green.shade600,
                                elevation: 3,
                              ),
                              onPressed: () {
                                if (_selectedRole == "teacher") {
                                  context.go('/signup-teacher');
                                } else if (_selectedRole == "student") {
                                  context.go('/signup-student');
                                } else {
                                  context.go('/signup-guest');
                                }
                              },
                              child: const Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
