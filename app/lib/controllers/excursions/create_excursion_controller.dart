import 'package:flutter/foundation.dart';
import '../../repositories/excursion_repository.dart';

class CreateExcursionController extends ChangeNotifier {
  CreateExcursionController(this._repository);
  final ExcursionRepository _repository;

  bool isLoading = false;
  String? error;

  Future<bool> create({
    required String name,
    required String description,
    required DateTime startAt,
  }) async {
    if (startAt.isBefore(DateTime.now())) {
      error = 'La excursión debe empezar en el futuro';
      notifyListeners();
      return false;
    }

    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _repository.create(
        name: name,
        description: description,
        startAt: startAt,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('CREATE EXCURSION ERROR: $e'); // temporal
      error = 'No se pudo crear la excursión. Inténtalo de nuevo.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}