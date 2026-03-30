import 'package:kigo_app/features/home/models/card_info.dart';
import 'package:kigo_app/features/home/repositories/home_repository.dart';

class FakeHomeRepository implements HomeRepository {
  @override
  Future<CardInfo> getActiveCard() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Uncomment to simulate error state:
    // throw Exception('Error al cargar la tarjeta');

    // Uncomment to simulate empty state:
    // return null;

    return const CardInfo(
      country: 'México',
      countryFlag: '🇲🇽',
      balance: 220.00,
      isActive: true,
    );
  }
}
