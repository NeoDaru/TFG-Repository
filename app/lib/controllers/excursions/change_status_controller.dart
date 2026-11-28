import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/excursion_status.dart';
import '../../repositories/excursion_repository.dart';

class ChangeStatusController extends ChangeNotifier {
  ChangeStatusController(this._repository, this.excursionId);
  final ExcursionRepository _repository;
  final String excursionId;

  bool isLoading = false;
  String? error;

  Future<bool> change(ExcursionStatus newStatus) async {
    isLoading = true;
    error = null;
    notifyListeners();

    var success = false;
    try {
      await _repository.changeStatus(excursionId, newStatus);
      success = true;
    } catch (e) {
      debugPrint('CHANGE STATUS ERROR: $e'); // temporal
      error = _messageFor(e);
    }

    isLoading = false;
    notifyListeners();
    return success;
  }

  String _messageFor(Object e) {
    if (e is PostgrestException) {
      if (e.message == 'invalid_transition') {
        return 'Ese cambio de estado ya no es posible. '
            'Actualiza la pantalla para ver el estado actual.';
      }
      if (e.message == 'Not allowed') {
        return 'Solo los coordinadores pueden cambiar el estado';
      }
    }
    return 'No se pudo cambiar el estado.';
  }
}