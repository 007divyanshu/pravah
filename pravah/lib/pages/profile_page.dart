import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pravah/pages/home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "No user Login";
  String email = "No user Login";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        email = user.email ?? "Email not available";
      });

      try {
        // Fetch the username from Firestore using the user's UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          username = userDoc.get('username');
        });
      } catch (e) {
        setState(() {
          username = "Failed to load username";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Combined Username and Email Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Username: $username',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: $email',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: colorScheme.surface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for additional information
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            const SizedBox(height: 16),

            // Selected location
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
