// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pravah/components/custom_appbar.dart';
import 'package:pravah/components/custom_navbar.dart';
import 'package:pravah/components/custom_snackbar.dart';

class TrackPage extends StatelessWidget {
  TrackPage({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign user out
  void signUserOut(BuildContext context) async {
    await _auth.signOut();
    showCustomSnackbar(
      context,
      "Signed out successfully!",
      backgroundColor: Color.fromARGB(255, 2, 57, 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showCustomSnackbar(
          context,
          "No user signed in!",
          backgroundColor: const Color.fromARGB(255, 57, 2, 2),
        );
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'Track'),
      drawer: CustomDrawer(),
      body: Center(
        child: Text(
          user != null ? "LOGGED IN AS: ${user.email!}" : "No user logged in!",
          style: const TextStyle(fontSize: 20),
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 1),
    );
  }
}
