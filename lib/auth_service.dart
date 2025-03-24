import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthService extends ChangeNotifier implements ValueNotifier<User?> {
  AuthService() : _user = FirebaseAuth.instance.currentUser {
    _userChangedSubscription = FirebaseAuth.instance.userChanges().listen((user) => value = user);
  }

  User? _user;
  StreamSubscription<User?>? _userChangedSubscription;

  @override
  User? get value => _user;

  void close() {
    _userChangedSubscription?.cancel();
  }

  @protected
  @override
  set value(User? user) {
    if (user == _user) return;
    _user = user;
    notifyListeners();
  }
}

/// {@template AuthScope.class}
/// AuthScope widget.
/// {@endtemplate}
class AuthScope extends StatefulWidget {
  /// {@macro AuthScope.class}
  const AuthScope({super.key, required this.child});

  final Widget child;

  static AuthService of(BuildContext context, {bool listen = true}) {
    final settingsScope = listen
        ? context.dependOnInheritedWidgetOfExactType<_InheritedAuth>()
        : context.getInheritedWidgetOfExactType<_InheritedAuth>();
    return settingsScope!.authService;
  }

  @override
  State<AuthScope> createState() => _AuthScopeState();
}

class _AuthScopeState extends State<AuthScope> {
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _authService,
        builder: (context, child) => _InheritedAuth(authService: _authService, child: widget.child),
      );
}

class _InheritedAuth extends InheritedWidget {
  const _InheritedAuth({
    required super.child,
    required this.authService,
  });

  final AuthService authService;

  @override
  bool updateShouldNotify(_InheritedAuth old) => old.authService != authService;
}
