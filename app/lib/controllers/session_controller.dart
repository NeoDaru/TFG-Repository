import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';
import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._auth, this._profiles) {
    _subscription = supabase.auth.onAuthStateChange.listen(_onAuthChange);
    if (supabase.auth.currentSession != null) load();
  }

  final AuthRepository _auth;
  final ProfileRepository _profiles;
  late final StreamSubscription<AuthState> _subscription;

  String? name;
  String? email;
  String? error;

  void _onAuthChange(AuthState state) {
    if (state.event == AuthChangeEvent.signedOut) {
      name = null;
      email = null;
      error = null;
      notifyListeners();
    } else if (state.event == AuthChangeEvent.signedIn ||
        state.event == AuthChangeEvent.initialSession) {
      load();
    }
  }

  Future<void> load() async {
    if (supabase.auth.currentSession == null) return;

    email = await _auth.fetchCurrentEmail();
    try {
      name = await _profiles.getName();
      error = null;
    } catch (_) {
      error = 'No se pudo cargar tu perfil';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final sessionController =
SessionController(AuthRepository(), ProfileRepository());