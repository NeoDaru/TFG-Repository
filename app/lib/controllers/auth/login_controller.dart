import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/auth_repository.dart';

class LoginController extends ChangeNotifier {
  LoginController(this._auth);
  final AuthRepository _auth;

  bool isLoading = false;
  String? error;

  Future<void> signIn(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _auth.signIn(email, password);
    } catch (e) {
      error = _messageFor(e);
    }

    isLoading = false;
    notifyListeners();
  }

  String _messageFor(Object e) {
    if (e is AuthException &&
        e.message.toLowerCase().contains('invalid login')) {
      return 'Correo o contraseña incorrectos';
    }
    return 'No se pudo iniciar sesión.';
  }
}