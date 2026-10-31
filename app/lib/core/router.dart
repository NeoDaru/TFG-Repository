import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/account/home_page.dart';
import '../views/auth/login_page.dart';
import '../views/auth/register_page.dart';
import 'supabase_client.dart';

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    _subscription =
        supabase.auth.onAuthStateChange.listen((_) => notifyListeners());
  }
  late final StreamSubscription _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: _AuthNotifier(),
  redirect: (context, state) {
    final hasSession = supabase.auth.currentSession != null;
    final location = state.matchedLocation;
    final inAuthPages = location == '/login' || location == '/register';

    if (!hasSession && !inAuthPages) return '/login';
    if (hasSession && inAuthPages) return '/home';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/home', builder: (_, __) => const HomePage()),
  ],
);