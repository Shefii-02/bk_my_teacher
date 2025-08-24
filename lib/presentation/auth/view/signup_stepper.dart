import 'package:flutter/material.dart';

class SignUpStepper extends StatefulWidget {
  const SignUpStepper({super.key});

  @override
  State<SignUpStepper> createState() => _SignUpStepperState();
}

class _SignUpStepperState extends State<SignUpStepper> {
  String _selectedRole = "teacher";

  Widget _buildRadioOption(String value, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 25),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: _selectedRole == value ? Colors.green : Colors.black26,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: value,
              groupValue: _selectedRole,
              activeColor: Colors.green,
              onChanged: (val) {
                setState(() {
                  _selectedRole = val!;
                });
              },
            ),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image for AppBar section
          Container(
            height: 200,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background/full-bg.jpg'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              // Custom AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Title
                    Column(
                      children: const [
                        Text(
                          'Choose You who are?',
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
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                    // Help button
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 0.8),
                        color: Colors.transparent,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.question_mark_sharp,
                          color: Colors.black,
                        ),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Scrollable Body with Rounded Top Corners
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
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
                        minHeight:
                            MediaQuery.of(context).size.height -
                            290, // minus appbar height
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Who am I?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildRadioOption("teacher", "I am a Teacher"),
                            _buildRadioOption("student", "I am a Student"),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .green, // Sets the background color to blue
                                foregroundColor: Colors
                                    .white, // Sets the text/icon color to white
                              ),
                              onPressed: () async {},
                              child: SizedBox(
                                width: 100,
                                height: 30,
                                child: Center(child: const Text('Submit')),
                              ),
                            ),
                          ],
                        ),
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
