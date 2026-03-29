import 'package:mobx/mobx.dart';
import 'package:kigo_app/features/auth/repositories/auth_repository.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
  final AuthRepository repository;

  AuthStoreBase(this.repository);

  @observable
  String phoneNumber = '';

  @observable
  bool privacyAccepted = false;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get canSubmit => privacyAccepted && phoneNumber.length == 10;

  @action
  void setPhoneNumber(String value) {
    phoneNumber = value;
    errorMessage = null;
  }

  @action
  void togglePrivacy(bool value) {
    privacyAccepted = value;
  }

  @action
  Future<void> requestOtp() async {
    if (!canSubmit) return;
    isLoading = true;
    errorMessage = null;

    try {
      await repository.requestOtp(phoneNumber);
    } catch (e) {
      errorMessage = 'Error al enviar el código. Intenta de nuevo.';
    } finally {
      isLoading = false;
    }
  }
}
