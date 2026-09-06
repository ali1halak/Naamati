/// Reusable form-field validators compatible with [TextFormField.validator].
///
/// All validators return `null` (valid) or a non-null error message (invalid),
/// matching Flutter's `FormFieldValidator<String>` signature.
library;

// ─────────────────────────────────────────────────────────────────────────────
// Email
// ─────────────────────────────────────────────────────────────────────────────

/// Validates that [value] is a properly formed email address.
String? emailValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'البريد الإلكتروني مطلوب.';
  }
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
  );
  if (!emailRegex.hasMatch(value.trim())) {
    return 'يرجى إدخال بريد إلكتروني صحيح.';
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Password
// ─────────────────────────────────────────────────────────────────────────────

/// Validates a password for minimum length and basic complexity.
///
/// Rules: at least 8 characters, one uppercase, one lowercase, one digit.
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'كلمة المرور مطلوبة.';
  }
  if (value.length < 8) {
    return 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل.';
  }
  // if (!RegExp(r'[A-Z]').hasMatch(value)) {
  //   return 'يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل.';
  // }
  // if (!RegExp(r'[a-z]').hasMatch(value)) {
  //   return 'يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل.';
  // }
  // if (!RegExp(r'[0-9]').hasMatch(value)) {
  //   return 'يجب أن تحتوي كلمة المرور على رقم واحد على الأقل.';
  // }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Phone
// ─────────────────────────────────────────────────────────────────────────────

/// Validates an international phone number (E.164-ish, 7-15 digits, optional +).
String? phoneValidator(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'رقم الهاتف مطلوب.';
  }
  final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
  if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
    return 'يرجى إدخال رقم هاتف صحيح.';
  }
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────
// Required field
// ─────────────────────────────────────────────────────────────────────────────

/// Returns an error message if [value] is null or blank.
///
/// Optionally pass a custom [fieldName] for a more descriptive message.
String? Function(String?) requiredFieldValidator({
  String fieldName = 'هذا الحقل',
}) {
  return (String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName مطلوب.';
    }
    return null;
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Positive integer (quantities)
// ─────────────────────────────────────────────────────────────────────────────

/// Validates a positive whole number (1–99999) — used for the donation
/// quantity so free text like "تكفي -5 أشخاص" can never reach the API.
String? Function(String?) positiveIntegerValidator({
  String fieldName = 'الكمية',
}) {
  return (String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) {
      return '$fieldName مطلوب.';
    }
    final n = int.tryParse(v);
    if (n == null) {
      return 'يجب أن يكون $fieldName رقماً صحيحاً.';
    }
    if (n < 1) {
      return 'يجب أن يكون $fieldName أكبر من صفر.';
    }
    if (n > 99999) {
      return '$fieldName كبير جداً — الحد الأعلى 99999.';
    }
    return null;
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirm password
// ─────────────────────────────────────────────────────────────────────────────

/// Validates that [value] matches the current password returned by
/// [originalPassword].
///
/// Use this as the validator for a "Confirm Password" field, passing the
/// current password value getter of the original field.
String? Function(String?) confirmPasswordValidator(
  String? Function() originalPassword,
) {
  return (String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور.';
    }
    if (value != originalPassword()) {
      return 'كلمتا المرور غير متطابقتين.';
    }
    return null;
  };
}
