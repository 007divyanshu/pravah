// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pravah/components/custom_dialog.dart';
import 'package:pravah/components/custom_snackbar.dart';
import 'package:pravah/pages/login_page.dart';

// Function to handle sign-out logic (Avoids duplication)
void signUserOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pop(context); // Close drawer or previous screens
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
  );
  showCustomSnackbar(
    context,
    "Signed out successfully!",
    backgroundColor: const Color.fromARGB(255, 2, 57, 24),
  );
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  CustomAppBar({required this.title});

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

      // Scan, Chatbot, and Notification Icons
      actions: [
        IconButton(
          icon: const Icon(Icons.camera),
          onPressed: () {},
          color: Theme.of(context).colorScheme.primary,
        ),
        IconButton(
          icon: const Icon(Icons.chat),
          onPressed: () {},
          color: Theme.of(context).colorScheme.primary,
        ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(
              'Pravah',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text('Location'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create Account'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
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
