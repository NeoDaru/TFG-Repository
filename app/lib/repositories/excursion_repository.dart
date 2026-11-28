import '../core/supabase_client.dart';
import '../models/excursion.dart';
import '../models/excursion_status.dart';

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

  Future<List<Excursion>> getMine() async {
    final rows = await supabase
        .from('excursion_members')
        .select('role, excursions(id, name, start_at, status)')
        .eq('user_id', supabase.auth.currentUser!.id);

    final all = rows.map<Excursion>(Excursion.fromMembership).toList();
    final active = all.where((e) => e.status.isActive).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    final closed = all.where((e) => !e.status.isActive).toList()
      ..sort((a, b) => b.startAt.compareTo(a.startAt));
    return [...active, ...closed];
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

  Future<String?> getAccessCode(String excursionId) async {
    final row = await supabase
        .from('excursion_access_codes')
        .select('code')
        .eq('excursion_id', excursionId)
        .maybeSingle();
    return row?['code'] as String?;
  }

  Future<String> generateAccessCode(String excursionId) async {
    final code = await supabase.rpc(
      'generate_access_code',
      params: {'p_excursion_id': excursionId},
    );
    return code as String;
  }

  Future<String> join(String code) async {
    final id = await supabase.rpc('join_excursion', params: {'p_code': code});
    return id as String;
  }

  Future<void> update({
    required String id,
    required String name,
    required String description,
    required DateTime startAt,
  }) async {
    await supabase.rpc('update_excursion', params: {
      'p_excursion_id': id,
      'p_name': name,
      'p_description': description,
      'p_start_at': startAt.toUtc().toIso8601String(),
    });
  }

  Future<void> changeStatus(String excursionId, ExcursionStatus newStatus) async {
    await supabase.rpc('change_excursion_status', params: {
      'p_excursion_id': excursionId,
      'p_new_status': newStatus.code,
    });
  }
}