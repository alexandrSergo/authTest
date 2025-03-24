import 'package:authtest/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// {@template HomeScreen.class}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro HomeScreen.class}
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: ValueListenableBuilder(
          valueListenable: AuthScope.of(context),
          builder: (context, user, child) => Center(
            child: Column(
              spacing: 10.0,
              children: [
                Text('id: ${user?.uid}'),
                Text('Name: ${user?.displayName}'),
                ElevatedButton(onPressed: _signOut, child: const Text('Sign out')),
              ],
            ),
          ),
        ),
      );
}
