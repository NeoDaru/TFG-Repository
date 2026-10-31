import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/auth_repository.dart';

class RegisterController extends ChangeNotifier {
  RegisterController(this._auth);
  final AuthRepository _auth;

  bool isLoading = false;
  String? error;

  Future<void> register(String name, String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _auth.signUp(name: name, email: email, password: password);
    } catch (e) {
      error = _messageFor(e);
    }

    isLoading = false;
    notifyListeners();
  }

  String _messageFor(Object e) {
    if (e is AuthException) {
      final message = e.message.toLowerCase();
      if (message.contains('already')) {
        return 'Este correo ya está registrado';
      }
      if (message.contains('password')) {
        return 'La contraseña no cumple los requisitos';
      }
    }
    return 'No se pudo crear la cuenta. Revisa tu conexión e inténtalo de nuevo.';
  }
}