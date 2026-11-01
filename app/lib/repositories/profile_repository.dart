import '../core/supabase_client.dart';

class ProfileRepository {
  Future<String> getName() async {
    final row = await supabase
        .from('profiles')
        .select('name')
        .eq('id', supabase.auth.currentUser!.id)
        .single();
    return row['name'] as String;
  }

  Future<void> updateName(String name) async {
    await supabase
        .from('profiles')
        .update({'name': name})
        .eq('id', supabase.auth.currentUser!.id);
  }
}