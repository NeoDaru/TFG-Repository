import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/excursions/create_excursion_controller.dart';
import '../../core/date_format.dart';
import '../../core/validators.dart';
import '../../repositories/excursion_repository.dart';

class CreateExcursionPage extends StatefulWidget {
  const CreateExcursionPage({super.key});

  @override
  State<CreateExcursionPage> createState() => _CreateExcursionPageState();
}

class _CreateExcursionPageState extends State<CreateExcursionPage> {
  final _controller = CreateExcursionController(ExcursionRepository());
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _dateField = TextEditingController();
  final _timeField = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;

  @override
  void dispose() {
    _controller.dispose();
    _name.dispose();
    _description.dispose();
    _dateField.dispose();
    _timeField.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
      _dateField.text = formatDate(picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && mounted) {
      setState(() => _time = picked);
      _timeField.text = MaterialLocalizations.of(context)
          .formatTimeOfDay(picked, alwaysUse24HourFormat: true);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final startAt = DateTime(
      _date!.year,
      _date!.month,
      _date!.day,
      _time!.hour,
      _time!.minute,
    );
    final ok = await _controller.create(
      name: _name.text.trim(),
      description: _description.text.trim(),
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
              builder: (context, _) => Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 100,
                      validator: Validators.excursionName,
                    ),
                    TextFormField(
                      controller: _description,
                      decoration:
                      const InputDecoration(labelText: 'Descripción'),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 4,
                      maxLength: 500,
                    ),
                    TextFormField(
                      controller: _dateField,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fecha',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: _pickDate,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Elige la fecha'
                          : null,
                    ),
                    TextFormField(
                      controller: _timeField,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Hora de inicio',
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      onTap: _pickTime,
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Elige la hora de inicio'
                          : null,
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
                            : const Text('Crear excursión'),
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