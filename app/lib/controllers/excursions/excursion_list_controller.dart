import 'package:flutter/foundation.dart';
import '../../models/excursion.dart';
import '../../repositories/excursion_repository.dart';

class ExcursionListController extends ChangeNotifier {
  ExcursionListController(this._repository);
  final ExcursionRepository _repository;

  List<Excursion> excursions = [];
  bool isLoading = false;
  String? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      excursions = await _repository.getMine();
    } catch (e) {
      debugPrint('EXCURSION LIST ERROR: $e'); // temporal
      error = 'No se pudieron cargar tus excursiones.';
    }

    isLoading = false;
    notifyListeners();
  }
}