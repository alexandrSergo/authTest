import 'dart:async';

import 'package:authtest/auth_screen.dart';
import 'package:authtest/auth_service.dart';
import 'package:authtest/home_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() {
  runZonedGuarded(_appRunner, onError);
}

Future<void> _appRunner() async {
  try {
    runApp(const LoadingApp());
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
    await FirebaseAuth.instance.setSettings(forceRecaptchaFlow: true);
    runApp(const AuthScope(child: MyApp()));
  } on Object catch (e, s) {
    debugPrint('$e\n$s');
    runApp(ErrorApp(error: e));
  }
}

void onError(Object error, StackTrace stackTrace) {
  debugPrint('$error\n$stackTrace');
}

/// {@template LoadingApp.class}
/// LoadingApp widget.
/// {@endtemplate}
class LoadingApp extends StatelessWidget {
  /// {@macro LoadingApp.class}
  const LoadingApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Material(
          color: Colors.white,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
}

/// {@template ErrorApp.class}
/// ErrorApp widget.
/// {@endtemplate}
class ErrorApp extends StatelessWidget {
  /// {@macro ErrorApp.class}
  const ErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Material(
          color: Colors.white,
          child: Center(child: Text('$error')),
        ),
      );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GlobalKey<NavigatorState> _navigatorKey;
  AuthService? _authService;

  @override
  void initState() {
    super.initState();
    _navigatorKey = GlobalKey<NavigatorState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authService = AuthScope.of(context)..addListener(_authListener);
    });
  }

  @override
  void dispose() {
    _authService?.removeListener(_authListener);
    super.dispose();
  }

  void _authListener() {
    final isAuthenticated = AuthScope.of(context).value != null;
    final nextScreen = isAuthenticated ? const HomeScreen() : const AuthScreen();
    _navigatorKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => nextScreen));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthScope.of(context).value == null ? const AuthScreen() : const HomeScreen(),
    );
  }
}

// 5d287eb5-0a5e-42ec-966a-dc1e7221ae1e