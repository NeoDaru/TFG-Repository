import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/form_status.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/profile_repository.dart';
import '../session_controller.dart';

class AccountController extends ChangeNotifier {
  AccountController(this._auth, this._profiles, this._session) {
    _session.addListener(notifyListeners);
  }

  final AuthRepository _auth;
  final ProfileRepository _profiles;
  final SessionController _session;

  String get name => _session.name ?? '';
  String? get email => _session.email;

  FormStatus nameStatus = const FormStatus();
  FormStatus emailStatus = const FormStatus();
  FormStatus passwordStatus = const FormStatus();

  Future<void> load() => _session.load();

  Future<bool> updateName(String newName) => _perform(
        (s) => nameStatus = s,
        () async {
      await _profiles.updateName(newName.trim());
      await _session.load();
    },
    'Nombre actualizado correctamente',
        (_) => 'No se pudo actualizar el nombre. Inténtalo de nuevo.',
  );

  Future<bool> updateEmail(String newEmail, String currentPassword) => _perform(
        (s) => emailStatus = s,
        () async {
      await _auth.changeEmail(
        newEmail: newEmail.trim(),
        currentPassword: currentPassword,
      );
      await _session.load();
    },
    'Correo actualizado correctamente',
    _emailError,
  );

  Future<bool> updatePassword(String current, String newPassword) => _perform(
        (s) => passwordStatus = s,
        () => _auth.updatePassword(
      currentPassword: current,
      newPassword: newPassword,
    ),
    'Contraseña actualizada correctamente',
    _passwordError,
  );

  Future<bool> _perform(
      void Function(FormStatus) setStatus,
      Future<void> Function() action,
      String successMessage,
      String Function(Object) errorMessage,
      ) async {
    setStatus(const FormStatus(isLoading: true));
    notifyListeners();
    try {
      await action();
      setStatus(FormStatus(success: successMessage));
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('ACCOUNT ERROR: $e'); // temporary
      setStatus(FormStatus(error: errorMessage(e)));
      notifyListeners();
      return false;
    }
  }

  String _emailError(Object e) {
    if (e is FunctionException) {
      final details = e.details;
      final code = details is Map ? details['error'] : null;
      if (code == 'invalid_password') {
        return 'La contraseña actual no es correcta';
      }
      if (code == 'email_in_use') return 'Ese correo ya está en uso';
      if (code == 'invalid_email') return 'Introduce un correo válido';
    }
    return 'No se pudo cambiar el correo. Inténtalo de nuevo.';
  }

  String _passwordError(Object e) {
    if (e is AuthException) {
      final message = e.message.toLowerCase();
      if (message.contains('different')) {
        return 'La nueva contraseña debe ser distinta de la actual';
      }
      if (message.contains('current') || message.contains('invalid')) {
        return 'La contraseña actual no es correcta';
      }
      if (message.contains('at least') || message.contains('weak')) {
        return 'La nueva contraseña no cumple los requisitos';
      }
    }
    return 'No se pudo cambiar la contraseña. Inténtalo de nuevo.';
  }

  @override
  void dispose() {
    _session.removeListener(notifyListeners);
    super.dispose();
  }
}