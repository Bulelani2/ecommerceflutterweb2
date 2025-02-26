import 'package:flutter/material.dart';
import '../constants/colors.dart';

class Aboutus2 extends StatelessWidget {
  const Aboutus2({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;

    return SingleChildScrollView(
      child: Stack(
        children: [
          // Gradient Background
          Container(
            width: screenWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomColor.bgdark1, CustomColor.bgdark2],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Icon with Shadow and Border
                Image.asset(
                  'assets/profile.jpg',
                  width: screenWidth / 3.5,
                ),

                const SizedBox(height: 20),
                // Name with Styling
                const Text(
                  "Bulelani",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cursive',
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Description with Better Typography
                const Text(
                  "Welcome to my beauty haven! I'm Bulelani, a passionate beauty enthusiast with a flair for creativity and a love for all things glamorous. Specializing in high-quality frontals and exquisite makeup installations, I’m dedicated to helping you look and feel your best. Whether you're preparing for a special event or just want to enhance your everyday look, I'm here to transform your beauty vision into reality.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.6,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 30),
                // Services Section with Hover Effect
                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _buildFeatureCard(
                      icon: Icons.brush,
                      title: "Makeup Artistry",
                      description:
                          "Exquisite makeup installations for any occasion.",
                    ),
                    _buildFeatureCard(
                      icon: Icons.face,
                      title: "Frontals & Weaves",
                      description:
                          "High-quality installations tailored to your style.",
                    ),
                    _buildFeatureCard(
                      icon: Icons.star,
                      title: "Beauty Consulting",
                      description: "Personalized beauty tips and advice.",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Feature Card with Hover Effect
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return MouseRegion(
      onEnter: (_) {
        // Add hover effect when hovering over the card
        // This could be expanded with an animation
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: CustomColor.bgdark),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
