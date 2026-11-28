import 'package:flutter/material.dart';
import '../../controllers/excursions/change_status_controller.dart';
import '../../models/excursion.dart';
import '../../models/excursion_status.dart';
import '../../repositories/excursion_repository.dart';
import '../widgets/confirm_dialog.dart';

class ExcursionStatusSection extends StatefulWidget {
  const ExcursionStatusSection({
    super.key,
    required this.excursion,
    required this.onChanged,
  });

  final Excursion excursion;
  final VoidCallback onChanged;

  @override
  State<ExcursionStatusSection> createState() => _ExcursionStatusSectionState();
}

class _ExcursionStatusSectionState extends State<ExcursionStatusSection> {
  late final ChangeStatusController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        ChangeStatusController(ExcursionRepository(), widget.excursion.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _description(ExcursionStatus status) => switch (status) {
    ExcursionStatus.planned =>
    'La excursión está planificada. Iníciala cuando comience o cancélala antes.',
    ExcursionStatus.inProgress =>
    'La excursión está en curso. Finalízala cuando termine.',
    ExcursionStatus.finished =>
    'La excursión ha finalizado. Ya no se puede cambiar su estado.',
    ExcursionStatus.cancelled =>
    'La excursión ha sido cancelada. Ya no se puede cambiar su estado.',
  };

  String _actionLabel(ExcursionStatus target) => switch (target) {
    ExcursionStatus.inProgress => 'Iniciar excursión',
    ExcursionStatus.finished => 'Finalizar excursión',
    ExcursionStatus.cancelled => 'Cancelar excursión',
    ExcursionStatus.planned => '',
  };

  String _confirmMessage(ExcursionStatus target) => switch (target) {
    ExcursionStatus.inProgress =>
    'La excursión pasará a estar en curso.',
    ExcursionStatus.finished =>
    'La excursión pasará a estar finalizada y ya no se podrá editar '
        'ni unirse a ella. Esta acción no se puede deshacer.',
    ExcursionStatus.cancelled =>
    'La excursión quedará cancelada y los participantes lo verán. '
        'Ya no se podrá editar ni unirse a ella. '
        'Esta acción no se puede deshacer.',
    ExcursionStatus.planned => '',
  };

  Future<void> _change(ExcursionStatus target) async {
    final confirmed = await showConfirmDialog(
      context,
      title: _actionLabel(target),
      message: _confirmMessage(target),
      confirmLabel: _actionLabel(target),
    );
    if (!confirmed) return;

    final changed = await _controller.change(target);
    if (changed) widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.excursion.status;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final disabled = _controller.isLoading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_description(status)),
            if (_controller.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _controller.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (status.nextStatuses.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final target in status.nextStatuses)
                    if (target == ExcursionStatus.cancelled)
                      OutlinedButton(
                        onPressed: disabled ? null : () => _change(target),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: Text(_actionLabel(target)),
                      )
                    else
                      FilledButton(
                        onPressed: disabled ? null : () => _change(target),
                        child: Text(_actionLabel(target)),
                      ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}