import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pravah/components/custom_appbar.dart';
import 'package:pravah/components/custom_navbar.dart';
import 'package:pravah/components/custom_snackbar.dart';
import 'package:pravah/components/loader.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  String? username;
  bool isLoading = true; // Loader state

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    setState(() {
      isLoading = true; // Show loader
    });

    user = _auth.currentUser;

    if (user != null) {
      try {
        // Fetch username from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();

        setState(() {
          username = userDoc.get('username');
          isLoading = false; // Stop loader after data is fetched
        });
      } catch (e) {
        setState(() {
          isLoading = false; // Stop loader on error
        });
        showCustomSnackbar(
          context,
          "Failed to fetch username.",
          backgroundColor: const Color.fromARGB(255, 57, 2, 2),
        );
      }
    } else {
      setState(() {
        isLoading = false; // Stop loader if no user
      });
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'Home'),
      drawer: CustomDrawer(),
      body: isLoading
          ? const LoaderPage() // Display loader while loading
          : Center(
        child: Text(
          user != null
              ? "LOGGED IN AS: ${user!.email!}\nUsername: ${username ?? 'Loading...'}"
              : "No user logged in!",
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
      ),
      bottomNavigationBar: BottomNavBar(selectedIndex: 0),
    );
  }
}
