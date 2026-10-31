import 'package:flutter/foundation.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/profile_repository.dart';

class HomeController extends ChangeNotifier {
  HomeController(this._auth, this._profiles);
  final AuthRepository _auth;
  final ProfileRepository _profiles;

  String? name;
  String? error;

  String? get email => _auth.currentEmail;

  Future<void> load() async {
    try {
      name = await _profiles.getName();
    } catch (_) {
      error = 'No se pudo cargar tu perfil';
    }
    notifyListeners();
  }

  Future<void> signOut() => _auth.signOut();
}