import 'package:kigo_app/features/home/models/card_info.dart';

abstract class HomeRepository {
  Future<CardInfo> getActiveCard();
}
