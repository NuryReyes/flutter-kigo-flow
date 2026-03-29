import 'package:kigo_app/features/auth/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<void> requestOtp(String phoneNumber) async {
    await Future.delayed(const Duration(seconds: 2));

    // Uncomment to simulate error state:
    // throw Exception('Error al enviar el código');
  }

  @override
  Future<bool> verifyOtp(String phoneNumber, String otpCode) async {
    await Future.delayed(const Duration(seconds: 2));

    // Uncomment to simulate error state:
    // throw Exception('Código incorrecto');

    // Uncomment to simulate wrong code:
    // return false;

    return true;
  }
}
