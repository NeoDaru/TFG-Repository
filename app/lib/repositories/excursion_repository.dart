import '../core/supabase_client.dart';
import '../models/excursion.dart';

class ExcursionRepository {
  Future<String> create({
    required String name,
    required String description,
    required DateTime startAt,
  }) async {
    final id = await supabase.rpc('create_excursion', params: {
      'p_name': name,
      'p_description': description,
      'p_start_at': startAt.toUtc().toIso8601String(),
    });
    return id as String;
  }

  Future<Excursion> getById(String id) async {
    final row = await supabase
        .from('excursion_members')
        .select('role, excursions(id, name, description, start_at, status)')
        .eq('excursion_id', id)
        .eq('user_id', supabase.auth.currentUser!.id)
        .single();
    return Excursion.fromMembership(row);
  }

  Future<List<Excursion>> getMine() async {
    final rows = await supabase
        .from('excursion_members')
        .select('role, excursions(id, name, start_at, status)')
        .eq('user_id', supabase.auth.currentUser!.id);

    final all = rows.map<Excursion>(Excursion.fromMembership).toList();
    final now = DateTime.now();
    final upcoming = all.where((e) => !e.startAt.isBefore(now)).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    final past = all.where((e) => e.startAt.isBefore(now)).toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    return [...upcoming, ...past];
  }
}