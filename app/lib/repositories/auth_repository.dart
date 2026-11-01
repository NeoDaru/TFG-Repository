import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';

class AuthRepository {
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  Future<void> signIn(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  String? get currentEmail => supabase.auth.currentUser?.email;

  Future<void> changeEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    await supabase.functions.invoke(
      'change-email',
      body: {'newEmail': newEmail, 'currentPassword': currentPassword},
    );
    await refreshUser();
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await supabase.auth.updateUser(
      UserAttributes(password: newPassword, currentPassword: currentPassword),
    );
  }

  Future<void> refreshUser() async {
    try {
      await supabase.auth.refreshSession();
    } catch (_) {}
  }

  Future<String?> fetchCurrentEmail() async {
    try {
      final response = await supabase.auth.getUser();
      return response.user?.email;
    } catch (_) {
      return supabase.auth.currentUser?.email;
    }
  }
}