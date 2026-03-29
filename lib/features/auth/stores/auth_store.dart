import 'package:mobx/mobx.dart';

part 'auth_store.g.dart';

class AuthStore = AuthStoreBase with _$AuthStore;

abstract class AuthStoreBase with Store {
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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      // TODO: call repository
    } catch (e) {
      errorMessage = 'Ocurrió un error. Intenta de nuevo.';
    } finally {
      isLoading = false;
    }
  }
}
