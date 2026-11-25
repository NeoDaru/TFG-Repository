import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/excursions/edit_excursion_controller.dart';
import '../../models/excursion.dart';
import '../../repositories/excursion_repository.dart';
import 'excursion_form.dart';

class EditExcursionPage extends StatefulWidget {
  const EditExcursionPage({super.key, required this.excursion});

  final Excursion excursion;

  @override
  State<EditExcursionPage> createState() => _EditExcursionPageState();
}

class _EditExcursionPageState extends State<EditExcursionPage> {
  late final EditExcursionController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        EditExcursionController(ExcursionRepository(), widget.excursion);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String name, String description, DateTime startAt) async {
    final ok = await _controller.save(
      name: name,
      description: description,
      startAt: startAt,
    );
    if (ok && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar excursión')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => ExcursionForm(
                initial: widget.excursion,
                submitLabel: 'Guardar cambios',
                isLoading: _controller.isLoading,
                error: _controller.error,
                onSubmit: _submit,
              ),
            ),
          ),
        ),
      ),
    );
  }
}