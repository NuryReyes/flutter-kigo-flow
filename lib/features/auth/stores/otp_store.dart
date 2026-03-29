import 'package:mobx/mobx.dart';
import 'package:kigo_app/features/auth/repositories/auth_repository.dart';

part 'otp_store.g.dart';

class OtpStore = OtpStoreBase with _$OtpStore;

abstract class OtpStoreBase with Store {
  final AuthRepository repository;
  final String phoneNumber;

  OtpStoreBase(this.repository, this.phoneNumber);

  @observable
  ObservableList<String> digits = ObservableList.of(['', '', '', '', '']);

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  bool isResending = false;

  @computed
  bool get canSubmit => digits.every((d) => d.isNotEmpty);

  @computed
  String get otpCode => digits.join();

  @action
  void setDigit(int index, String value) {
    digits[index] = value;
    errorMessage = null;
  }

  @action
  void clearDigits() {
    for (int i = 0; i < digits.length; i++) {
      digits[i] = '';
    }
  }

  @action
  Future<void> verifyOtp() async {
    if (!canSubmit) return;
    isLoading = true;
    errorMessage = null;

    try {
      final success = await repository.verifyOtp(phoneNumber, otpCode);
      if (!success) {
        errorMessage = 'Código incorrecto. Intenta de nuevo.';
        clearDigits();
      }
    } catch (e) {
      errorMessage = 'Código incorrecto. Intenta de nuevo.';
      clearDigits();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> resendCode() async {
    isResending = true;
    errorMessage = null;

    try {
      await repository.requestOtp(phoneNumber);
      clearDigits();
    } catch (e) {
      errorMessage = 'Error al reenviar el código.';
    } finally {
      isResending = false;
    }
  }
}
