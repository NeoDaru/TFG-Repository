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
}