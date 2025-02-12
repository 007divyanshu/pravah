// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pravah/components/custom_dialog.dart';
import 'package:pravah/components/custom_snackbar.dart';
import 'package:pravah/pages/auth_page.dart';
import 'package:pravah/pages/chatbot.dart';
import 'package:pravah/pages/home_page.dart';
import 'package:pravah/pages/location_page.dart';
import 'package:pravah/pages/notification_page.dart';
import 'package:pravah/pages/profile_page.dart';

void signUserOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  if (context.mounted) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false, // Removes all previous routes
    );
    showCustomSnackbar(
      context,
      "Signed out successfully!",
      backgroundColor: const Color.fromARGB(255, 2, 57, 24),
    );
  }
}

// Custom App Bar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      centerTitle: true,
      elevation: 0,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            color: Theme.of(context).colorScheme.primary,
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.camera),
            onPressed: () {},
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.chat_bubble),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Chatbot()),
              );
            },
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationPage()),
              );
            },
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Custom Drawer
class CustomDrawer extends StatelessWidget {
  final VoidCallback? onTap; // Function to toggle login/register

  const CustomDrawer({this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(
              'Pravah',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Location
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Location'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LocationPage())
              );
            },
          ),

          // Profile
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage())
              );
            },
          ),

          // Toggle Login/Register
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Login / Register'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthPage()),
              );
            },
          ),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => CustomDialogBox(
                  title: "Logout",
                  content: "Are you sure you want to logout?",
                  confirmText: "Yes",
                  onConfirm: () {
                    signUserOut(context);
                  },
                ),
              );
            },
          ),

          // Delete Account
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Delete Account'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
