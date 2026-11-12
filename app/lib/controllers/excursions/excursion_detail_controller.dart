import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/excursion.dart';
import '../../repositories/excursion_repository.dart';

class ExcursionDetailController extends ChangeNotifier {
  ExcursionDetailController(this._repository, this.excursionId);
  final ExcursionRepository _repository;
  final String excursionId;

  Excursion? excursion;
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      excursion = await _repository.getById(excursionId);
    } catch (e) {
      debugPrint('EXCURSION DETAIL ERROR: $e'); // temporal
      error = e is PostgrestException
          ? 'No se encontró la excursión o ya no perteneces a ella.'
          : 'No se pudo cargar la excursión.';
    }

    isLoading = false;
    notifyListeners();
  }
}