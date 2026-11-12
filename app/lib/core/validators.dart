class Validators {
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Introduce tu nombre';
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
    return valid ? null : 'Introduce un correo válido';
  }

  static String? newPassword(String? value) {
    if (value == null || value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres (incluyendo mayúsculas, minúsculas y cifras)';
    }
    return null;
  }

  static String? requiredPassword(String? value) {
    if (value == null || value.isEmpty) return 'Introduce tu contraseña';
    return null;
  }

  static String? excursionName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Introduce el nombre de la excursión';
    if (text.length > 100) return 'Máximo 100 caracteres';
    return null;
  }
}