class Validators {
  static String? name(String? value) {
    if (value == null || value.isEmpty) return 'Nome obrigatório';
    if (value.length < 3) return 'Mínimo 3 caracteres';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email obrigatório';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Senha obrigatória';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }
}