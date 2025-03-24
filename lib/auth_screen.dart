import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

sealed class PhoneVerificationResponse {
  const PhoneVerificationResponse();
}

final class PhoneVerificationResponse$Credentials extends PhoneVerificationResponse {
  const PhoneVerificationResponse$Credentials(this.authCredential);

  final AuthCredential authCredential;
}

final class PhoneVerificationResponse$Data extends PhoneVerificationResponse {
  const PhoneVerificationResponse$Data(this.verificationId, this.resendToken);

  final String verificationId;
  final int? resendToken;
}

/// {@template AuthScreen.class}
/// AuthScreen widget.
/// {@endtemplate}
class AuthScreen extends StatefulWidget {
  /// {@macro AuthScreen.class}
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late String _phone;
  late bool _isLoading;
  late GlobalKey<FormState> _signInFormKey;
  PhoneVerificationResponse$Data? _verificationData;
  late String _smsCode;

  @override
  void initState() {
    super.initState();
    _isLoading = false;
    _phone = '';
    _signInFormKey = GlobalKey<FormState>();
  }

  void _onPhoneChanged(String v) {
    _phone = v;
  }

  void _onCodeChanged(String v) {
    _smsCode = v;
  }

  bool _validateForm() {
    final isValid = _signInFormKey.currentState?.validate() ?? false;
    setState(() {});
    return isValid;
  }

  Future<void> _submit() async {
    try {
      setState(() {
        _isLoading = true;
      });
      if (!_validateForm()) return;
      _verificationData == null ? await _submitSendingCode() : await _submitVerification(_verificationData!);
    } on Object catch (e, s) {
      debugPrint('$e\n$s');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e'), backgroundColor: Colors.red));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitSendingCode() async {
    final verificationData = await _verifyPhoneNumber().timeout(const Duration(seconds: 30));
    switch (verificationData) {
      case PhoneVerificationResponse$Credentials():
        await FirebaseAuth.instance.signInWithCredential(verificationData.authCredential);
      case final PhoneVerificationResponse$Data verificationData:
        setState(() {
          _verificationData = verificationData;
        });
    }
  }

  Future<void> _submitVerification(PhoneVerificationResponse$Data verificationData) async {
    final phoneCredentials =
        PhoneAuthProvider.credential(verificationId: verificationData.verificationId, smsCode: _smsCode);
    await FirebaseAuth.instance.signInWithCredential(phoneCredentials);
  }

  Future<PhoneVerificationResponse> _verifyPhoneNumber() async {
    final completer = Completer<PhoneVerificationResponse>();
    // FirebaseAuth.instance.signInWithPhoneNumber(phoneNumber);
    FirebaseAuth.instance
        .verifyPhoneNumber(
          phoneNumber: '+$_phone',
          verificationCompleted: (credentials) {
            final verificationResponse = PhoneVerificationResponse$Credentials(credentials);
            completer.complete(verificationResponse);
          },
          verificationFailed: (error) {
            completer.completeError(error, error.stackTrace);
          },
          codeSent: (verificationId, resendToken) {
            final verificationResponse = PhoneVerificationResponse$Data(verificationId, resendToken);
            completer.complete(verificationResponse);
          },
          codeAutoRetrievalTimeout: (verificationId) {
            if (completer.isCompleted) return;
            completer.completeError(TimeoutException('Code auto-retrieval timed out'), StackTrace.current);
          },
        )
        .ignore();
    final result = await completer.future;
    return result;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('Sign In')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Form(
              key: _signInFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.3),
                  TextFormField(
                    onChanged: _onPhoneChanged,
                    decoration: const InputDecoration(hintText: 'Phone number', border: OutlineInputBorder()),
                    maxLength: 11,
                    keyboardType: TextInputType.phone,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    validator: (_) => _phone.length != 11 || !_phone.startsWith('7') ? 'Invalid phone number' : null,
                  ),
                  if (_verificationData != null) ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      onChanged: _onCodeChanged,
                      decoration: const InputDecoration(hintText: 'SMS code', border: OutlineInputBorder()),
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                      validator: (_) => _smsCode.length != 6 ? 'Invalid code' : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0).copyWith(bottom: kMinInteractiveDimension),
          child: ElevatedButton(
            onPressed: _submit,
            child: _isLoading
                ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator.adaptive())
                : const Text('Submit'),
          ),
        ),
      );
}
