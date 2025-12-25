import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:dots_indicator/dots_indicator.dart';

import '../../core/constants/endpoints.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'color': '#FFFFFF',
      'title': 'Online Learning',
      'image': 'assets/images/onboarding/slide-1.png',
      'description':
      'We Provide Online Classes and Pre-Recorded Lectures!',
      'skip': true,
    },
    {
      'color': '#FFFFFF',
      'title': 'Learn Anytime',
      'image': 'assets/images/onboarding/slide-2.png',
      'description': 'Book or Save Lectures for the Future',
      'skip': true,
    },
    {
      'color': '#FFFFFF',
      'title': 'Performance Visualization',
      'image': 'assets/images/onboarding/slide-3.png',
      'description': 'Check Your Performance and Track Your Education',
      'skip': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPageContent(_pages[index]);
            },
          ),

          // Bottom controls (dots + buttons) inside SafeArea
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              minimum: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots indicator
                  DotsIndicator(
                    dotsCount: _pages.length,
                    position: _currentIndex.toDouble(),
                    decorator: DotsDecorator(
                      activeColor: Colors.green,
                      size: const Size.square(9.0),
                      activeSize: const Size(18.0, 9.0),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentIndex != _pages.length - 1)
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.green),
                            foregroundColor: WidgetStateProperty.all(Colors.white),
                            elevation: WidgetStateProperty.all(5.0),
                            shape: WidgetStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                            ),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.all(16.0),
                            ),
                          ),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: const Icon(Icons.arrow_forward),
                        ),
                      if (_currentIndex == _pages.length - 1)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final box = Hive.box('settings');
                            box.put('hasSeenOnboarding', true);
                            context.go('/auth');
                          },
                          child: const Text('Get Started'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(Map<String, dynamic> page) {
    final bgColor = page['color'] != null
        ? Color(
      int.parse(page['color'].substring(1, 7), radix: 16) + 0xFF000000,
    )
        : Colors.white;

    return Container(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (page['image'] != null)
              Image.asset(page['image'], width: 300, height: 300),
            if ((page['title'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Text(
                page['title'],
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            if ((page['description'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  page['description'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
