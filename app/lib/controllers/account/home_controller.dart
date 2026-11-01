import 'package:flutter/foundation.dart';
import '../../repositories/auth_repository.dart';
import '../session_controller.dart';

class HomeController extends ChangeNotifier {
  HomeController(this._auth, this._session) {
    _session.addListener(notifyListeners);
  }

  final AuthRepository _auth;
  final SessionController _session;

  String get name => _session.name ?? '';
  String get email => _session.email ?? '';
  String? get error => _session.error;

  Future<void> refresh() => _session.load();

  Future<void> signOut() => _auth.signOut();

  @override
  void dispose() {
    _session.removeListener(notifyListeners);
    super.dispose();
  }
}