import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:location/location.dart';
import 'package:restaurant_helper_phone/model/location.dart';
import 'package:restaurant_helper_phone/model/restaurant_search.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:utils/utils.dart';

part 'restaurant_list.g.dart';
part 'restaurant_list.freezed.dart';

@freezed
class RestaurantBaseData with _$RestaurantBaseData {
  factory RestaurantBaseData(
      {required int id,
      required String name,
      required String photoUrl}) = _RestaurantBaseData;
  factory RestaurantBaseData.fromJson(Map<String, dynamic> json) =>
      _$RestaurantBaseDataFromJson(json);
}

@Riverpod(keepAlive: true)
class RestaurantList extends _$RestaurantList {
  @override
  Future<List<RestaurantBaseData>> build() async {
    LocationData? locationData;
    while(!ref.read(locationProvider).hasValue) {
      await Future.delayed(const Duration(milliseconds: 500));
    }
    locationData = ref.read(locationProvider).value;
    if(locationData == null) {
      throw Exception("Brak lokalizacji");
    }
    final options = ref.read(restaurantSearchProvider).toJson();
    options.addEntries({
      "latitude": locationData.latitude,
      "longitude": locationData.longitude
    }.entries);
    final token = ref.read(authProvider).value!;
    try {
      final response = await Dio().get(
          '${dotenv.env['USER_API_URL']!}restaurant-search',
          data: options,
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      return (response.data as List<dynamic>)
          .map((e) => RestaurantBaseData.fromJson(e))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        print(e.response);
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak. Spróbuj zapisać dane ponownie później", true);
      }
      rethrow;
    }
  }

  Future<void> search() async {
    ref.invalidateSelf();
    await future;
  }
}