// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$OtpStore on OtpStoreBase, Store {
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'OtpStoreBase.canSubmit',
  )).value;
  Computed<String>? _$otpCodeComputed;

  @override
  String get otpCode => (_$otpCodeComputed ??= Computed<String>(
    () => super.otpCode,
    name: 'OtpStoreBase.otpCode',
  )).value;

  late final _$digitsAtom = Atom(name: 'OtpStoreBase.digits', context: context);

  @override
  ObservableList<String> get digits {
    _$digitsAtom.reportRead();
    return super.digits;
  }

  @override
  set digits(ObservableList<String> value) {
    _$digitsAtom.reportWrite(value, super.digits, () {
      super.digits = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'OtpStoreBase.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: 'OtpStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$isResendingAtom = Atom(
    name: 'OtpStoreBase.isResending',
    context: context,
  );

  @override
  bool get isResending {
    _$isResendingAtom.reportRead();
    return super.isResending;
  }

  @override
  set isResending(bool value) {
    _$isResendingAtom.reportWrite(value, super.isResending, () {
      super.isResending = value;
    });
  }

  late final _$verifyOtpAsyncAction = AsyncAction(
    'OtpStoreBase.verifyOtp',
    context: context,
  );

  @override
  Future<void> verifyOtp() {
    return _$verifyOtpAsyncAction.run(() => super.verifyOtp());
  }

  late final _$resendCodeAsyncAction = AsyncAction(
    'OtpStoreBase.resendCode',
    context: context,
  );

  @override
  Future<void> resendCode() {
    return _$resendCodeAsyncAction.run(() => super.resendCode());
  }

  late final _$OtpStoreBaseActionController = ActionController(
    name: 'OtpStoreBase',
    context: context,
  );

  @override
  void setDigit(int index, String value) {
    final _$actionInfo = _$OtpStoreBaseActionController.startAction(
      name: 'OtpStoreBase.setDigit',
    );
    try {
      return super.setDigit(index, value);
    } finally {
      _$OtpStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void clearDigits() {
    final _$actionInfo = _$OtpStoreBaseActionController.startAction(
      name: 'OtpStoreBase.clearDigits',
    );
    try {
      return super.clearDigits();
    } finally {
      _$OtpStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
digits: ${digits},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
isResending: ${isResending},
canSubmit: ${canSubmit},
otpCode: ${otpCode}
    ''';
  }
}
