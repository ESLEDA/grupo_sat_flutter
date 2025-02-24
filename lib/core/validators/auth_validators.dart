class AuthValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo es requerido';
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {    
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una mayúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }
    if (!value.contains(RegExp(r'[#%&+]'))) {
      return 'La contraseña debe contener al menos un carácter especial (#,%,&,+)';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El celular es requerido';
    }
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Ingrese un número de celular válido (10 dígitos)';
    }
    return null;
  }
}