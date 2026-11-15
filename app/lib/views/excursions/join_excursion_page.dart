import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/excursions/join_excursion_controller.dart';
import '../../core/validators.dart';
import '../../repositories/excursion_repository.dart';

class JoinExcursionPage extends StatefulWidget {
  const JoinExcursionPage({super.key});

  @override
  State<JoinExcursionPage> createState() => _JoinExcursionPageState();
}

class _JoinExcursionPageState extends State<JoinExcursionPage> {
  final _controller = JoinExcursionController(ExcursionRepository());
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final excursionId = await _controller.join(_code.text);
    if (excursionId != null && mounted) context.pop(excursionId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unirse a una excursión')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pide el código de acceso al coordinador de la excursión '
                          'e introdúcelo aquí.',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _code,
                      decoration: const InputDecoration(
                        labelText: 'Código de acceso',
                        hintText: 'ABCD-EFGH-JKMN',
                      ),
                      textCapitalization: TextCapitalization.characters,
                      autocorrect: false,
                      validator: Validators.accessCode,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 16),
                    if (_controller.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _controller.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _controller.isLoading ? null : _submit,
                        child: _controller.isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                          CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Text('Unirme'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}