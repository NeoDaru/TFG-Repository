import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/excursion.dart';
import '../../repositories/excursion_repository.dart';

class EditExcursionController extends ChangeNotifier {
  EditExcursionController(this._repository, this.original);
  final ExcursionRepository _repository;
  final Excursion original;

  bool isLoading = false;
  String? error;

  Future<bool> save({
    required String name,
    required String description,
    required DateTime startAt,
  }) async {
    final dateChanged = !startAt.isAtSameMomentAs(original.startAt);
    if (dateChanged && startAt.isBefore(DateTime.now())) {
      error = 'La nueva fecha y hora deben ser futuras';
      notifyListeners();
      return false;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _repository.update(
        id: original.id,
        name: name,
        description: description,
        startAt: startAt,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('EDIT EXCURSION ERROR: $e'); // temporal
      error = _messageFor(e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _messageFor(Object e) {
    if (e is PostgrestException) {
      if (e.message == 'excursion_closed') {
        return 'Esta excursión ya ha finalizado o ha sido cancelada y no se puede editar';
      }
      if (e.message == 'Not allowed') {
        return 'Solo los coordinadores pueden editar la excursión';
      }
    }
    return 'No se pudieron guardar los cambios.';
  }
}