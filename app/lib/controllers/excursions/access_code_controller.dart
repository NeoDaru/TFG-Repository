import 'package:flutter/foundation.dart';
import '../../repositories/excursion_repository.dart';

class AccessCodeController extends ChangeNotifier {
  AccessCodeController(this._repository, this.excursionId);
  final ExcursionRepository _repository;
  final String excursionId;

  String? code;
  bool isLoading = false;
  bool loaded = false;
  String? error;

  Future<void> load() => _run(() async {
    code = await _repository.getAccessCode(excursionId);
  });

  Future<void> generate() => _run(() async {
    code = await _repository.generateAccessCode(excursionId);
  });

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await action();
    } catch (e) {
      debugPrint('ACCESS CODE ERROR: $e'); // temporal
      error = 'No se pudo completar la operación. Inténtalo de nuevo.';
    }

    isLoading = false;
    loaded = true;
    notifyListeners();
  }
}