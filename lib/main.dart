// ignore_for_file: use_build_context_synchronously

import 'package:authtest/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.deviceCheck,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final youPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final youPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
  @override
  Widget build(BuildContext context) {
    return youPhone == null 
      ? const AuthScreen()
      : Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(youPhone ?? "phone"),
              const SizedBox(height: 30,),
              TextButton(
                onPressed:() async {
                  await FirebaseAuth.instance.signOut();
                  _goToScreenReplaceAll(context, const AuthScreen());
                }, 
                child: const Text('SIGN OUT')
              ),
            ],
          ),
        ),
      );
  }
}

void _showError(BuildContext context, Object e) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: const TextStyle(color: Colors.white),)));
}

void _goToScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(MaterialPageRoute(builder:(context) => screen));
}

void _goToScreenReplaceAll(BuildContext context, Widget screen) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(context) => screen), (_) => false);
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final controller = TextEditingController();

  void _onSendCode() async {
    try {
      final phone = controller.text;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          _showError(context, e.message ?? "error");
        },
        codeSent: (verificationId, forceResendingToken) {
          _goToScreen(context, VerifyScreen(verifyId: verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _showError(context, "TIMEOUT");
        },
      );
    } catch (e) {
      _showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: controller,
              ),
              const SizedBox(height: 30,),
              TextButton(
                onPressed: _onSendCode, 
                child: const Text('NEXT')
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key, required this.verifyId,});
  final String verifyId;

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {

  final controller = TextEditingController();

  void _onVerify() async {
    try {
      final code = controller.text;
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verifyId, 
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _goToScreenReplaceAll(context, const HomeScreen());
    } catch (e) {
      _showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: controller,
              ),
              const SizedBox(height: 30,),
              TextButton(
                onPressed: _onVerify, 
                child: const Text('VERIFY')
              ),
            ],
          ),
        ),
      ),
    );
  }
}
