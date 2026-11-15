import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../repositories/excursion_repository.dart';

class JoinExcursionController extends ChangeNotifier {
  JoinExcursionController(this._repository);
  final ExcursionRepository _repository;

  bool isLoading = false;
  String? error;
  
  Future<String?> join(String code) async {
    isLoading = true;
    error = null;
    notifyListeners();

    String? excursionId;
    try {
      excursionId = await _repository.join(code);
    } catch (e) {
      debugPrint('JOIN EXCURSION ERROR: $e'); // temporal
      error = _messageFor(e);
    }

    isLoading = false;
    notifyListeners();
    return excursionId;
  }

  String _messageFor(Object e) {
    if (e is PostgrestException) {
      switch (e.message) {
        case 'invalid_code':
          return 'El código no es válido';
        case 'already_member':
          return 'Ya perteneces a esta excursión';
        case 'excursion_closed':
          return 'Esta excursión ya ha finalizado o ha sido cancelada';
      }
    }
    return 'No se pudo completar la operación.';
  }
}