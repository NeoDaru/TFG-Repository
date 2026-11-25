import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/excursions/create_excursion_controller.dart';
import '../../repositories/excursion_repository.dart';
import 'excursion_form.dart';

class CreateExcursionPage extends StatefulWidget {
  const CreateExcursionPage({super.key});

  @override
  State<CreateExcursionPage> createState() => _CreateExcursionPageState();
}

class _CreateExcursionPageState extends State<CreateExcursionPage> {
  final _controller = CreateExcursionController(ExcursionRepository());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String name, String description, DateTime startAt) async {
    final ok = await _controller.create(
      name: name,
      description: description,
      startAt: startAt,
    );
    if (ok && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva excursión')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => ExcursionForm(
                submitLabel: 'Crear excursión',
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