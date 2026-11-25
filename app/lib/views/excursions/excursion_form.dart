import 'package:flutter/material.dart';
import '../../core/date_format.dart';
import '../../core/validators.dart';
import '../../models/excursion.dart';

class ExcursionForm extends StatefulWidget {
  const ExcursionForm({
    super.key,
    this.initial,
    required this.submitLabel,
    required this.isLoading,
    required this.error,
    required this.onSubmit,
  });

  final Excursion? initial;
  final String submitLabel;
  final bool isLoading;
  final String? error;
  final Future<void> Function(String name, String description, DateTime startAt)
  onSubmit;

  @override
  State<ExcursionForm> createState() => _ExcursionFormState();
}

class _ExcursionFormState extends State<ExcursionForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _dateField = TextEditingController();
  final _timeField = TextEditingController();

  DateTime? _date;
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _name.text = initial.name;
      _description.text = initial.description;
      _date = DateTime(
        initial.startAt.year,
        initial.startAt.month,
        initial.startAt.day,
      );
      _time = TimeOfDay(
        hour: initial.startAt.hour,
        minute: initial.startAt.minute,
      );
      _dateField.text = formatDate(initial.startAt);
      _timeField.text = formatTime(initial.startAt);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _dateField.dispose();
    _timeField.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = _date ?? today;
    final first = current.isBefore(today) ? current : today;

    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: first,
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
    await widget.onSubmit(
      _name.text.trim(),
      _description.text.trim(),
      startAt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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
            decoration: const InputDecoration(labelText: 'Descripción'),
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
            validator: (value) =>
            (value == null || value.isEmpty) ? 'Elige la fecha' : null,
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
          if (widget.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                widget.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isLoading ? null : _submit,
              child: widget.isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Text(widget.submitLabel),
            ),
          ),
        ],
      ),
    );
  }
}