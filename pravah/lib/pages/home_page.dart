// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pravah/components/custom_appbar.dart';
import 'package:pravah/components/custom_navbar.dart';
import 'package:pravah/components/custom_snackbar.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    user = _auth.currentUser;

    if (user != null) {
      try {
        // Fetch the username from Firestore using the user's UID
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        setState(() {
          username = userDoc.get('username');
        });
      } catch (e) {
        showCustomSnackbar(
          context,
          "Failed to fetch username.",
          backgroundColor: const Color.fromARGB(255, 57, 2, 2),
        );
      }
    }
  }

  void signUserOut(BuildContext context) async {
    await _auth.signOut();
    showCustomSnackbar(
      context,
      "Signed out successfully!",
      backgroundColor: const Color.fromARGB(255, 2, 57, 24),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      appBar: CustomAppBar(title: 'Home'),
      drawer: CustomDrawer(),
      body: Center(
        child: Text(
          user != null
              ? "LOGGED IN AS: ${user!.email!}\nUsername: ${username!}"
              : "No user logged in!",
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 0),
    );
  }
}
