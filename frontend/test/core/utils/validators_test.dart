import 'package:flutter_test/flutter_test.dart';

import 'package:naamati/core/utils/validators.dart';

void main() {
  group('confirmPasswordValidator', () {
    test('accepts matching values', () {
      final validator = confirmPasswordValidator(() => 'Secret123');

      expect(validator('Secret123'), isNull);
    });

    test('rejects mismatched values', () {
      final validator = confirmPasswordValidator(() => 'Secret123');

      expect(validator('Secret124'), 'كلمتا المرور غير متطابقتين.');
    });

    test('reads the latest password value', () {
      var password = 'Secret123';
      final validator = confirmPasswordValidator(() => password);

      expect(validator('Secret123'), isNull);

      password = 'Secret456';

      expect(validator('Secret123'), 'كلمتا المرور غير متطابقتين.');
      expect(validator('Secret456'), isNull);
    });
  });
}
