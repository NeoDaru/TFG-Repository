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
}