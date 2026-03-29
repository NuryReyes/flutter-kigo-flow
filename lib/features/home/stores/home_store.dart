import 'package:mobx/mobx.dart';
import 'package:kigo_app/features/home/models/card_info.dart';
import 'package:kigo_app/features/home/repositories/home_repository.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  final HomeRepository repository;

  HomeStoreBase(this.repository);

  @observable
  CardInfo? cardInfo;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get hasData => cardInfo != null;

  @action
  Future<void> loadCardInfo() async {
    isLoading = true;
    errorMessage = null;

    try {
      cardInfo = await repository.getActiveCard();
    } catch (e) {
      errorMessage = 'Error al cargar la tarjeta. Intenta de nuevo.';
    } finally {
      isLoading = false;
    }
  }
}
