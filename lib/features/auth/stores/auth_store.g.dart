// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on AuthStoreBase, Store {
  Computed<bool>? _$canSubmitComputed;

  @override
  bool get canSubmit => (_$canSubmitComputed ??= Computed<bool>(
    () => super.canSubmit,
    name: 'AuthStoreBase.canSubmit',
  )).value;

  late final _$phoneNumberAtom = Atom(
    name: 'AuthStoreBase.phoneNumber',
    context: context,
  );

  @override
  String get phoneNumber {
    _$phoneNumberAtom.reportRead();
    return super.phoneNumber;
  }

  @override
  set phoneNumber(String value) {
    _$phoneNumberAtom.reportWrite(value, super.phoneNumber, () {
      super.phoneNumber = value;
    });
  }

  late final _$privacyAcceptedAtom = Atom(
    name: 'AuthStoreBase.privacyAccepted',
    context: context,
  );

  @override
  bool get privacyAccepted {
    _$privacyAcceptedAtom.reportRead();
    return super.privacyAccepted;
  }

  @override
  set privacyAccepted(bool value) {
    _$privacyAcceptedAtom.reportWrite(value, super.privacyAccepted, () {
      super.privacyAccepted = value;
    });
  }

  late final _$isLoadingAtom = Atom(
    name: 'AuthStoreBase.isLoading',
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
    name: 'AuthStoreBase.errorMessage',
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

  late final _$requestOtpAsyncAction = AsyncAction(
    'AuthStoreBase.requestOtp',
    context: context,
  );

  @override
  Future<void> requestOtp() {
    return _$requestOtpAsyncAction.run(() => super.requestOtp());
  }

  late final _$AuthStoreBaseActionController = ActionController(
    name: 'AuthStoreBase',
    context: context,
  );

  @override
  void setPhoneNumber(String value) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
      name: 'AuthStoreBase.setPhoneNumber',
    );
    try {
      return super.setPhoneNumber(value);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void togglePrivacy(bool value) {
    final _$actionInfo = _$AuthStoreBaseActionController.startAction(
      name: 'AuthStoreBase.togglePrivacy',
    );
    try {
      return super.togglePrivacy(value);
    } finally {
      _$AuthStoreBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
phoneNumber: ${phoneNumber},
privacyAccepted: ${privacyAccepted},
isLoading: ${isLoading},
errorMessage: ${errorMessage},
canSubmit: ${canSubmit}
    ''';
  }
}
