import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:restaurant_helper_phone/model/restaurant_reservation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:utils/utils.dart';

part 'restaurant_menu.g.dart';
part 'restaurant_menu.freezed.dart';

@freezed
class RestaurantMenuItem with _$RestaurantMenuItem {
  RestaurantMenuItem._();
  factory RestaurantMenuItem({
    required int id,
    required String name,
    required String description,
    required double price,
    required int order,
    required bool isAvailable,
    required String photoUrl,
  }) = _RestaurantMenuItem;
  factory RestaurantMenuItem.fromJson(Map<String, dynamic> json) =>
      _$RestaurantMenuItemFromJson(json);
}

@freezed
class RestaurantMenuCategory with _$RestaurantMenuCategory {
  factory RestaurantMenuCategory(
      {required int id,
      required String name,
      required int order}) = _RestaurantMenuCategory;
  factory RestaurantMenuCategory.fromJson(Map<String, dynamic> json) =>
      _$RestaurantMenuCategoryFromJson(json);
}

@freezed
class RestaurantMenuInfo with _$RestaurantMenuInfo {
  factory RestaurantMenuInfo(
      {required List<RestaurantMenuCategory> categories,
      required List<RestaurantMenuItem> items}) = _RestaurantMenuInfo;
  factory RestaurantMenuInfo.fromJson(Map<String, dynamic> json) =>
      _$RestaurantMenuInfoFromJson(json);
}

@freezed
class RestaurantOrderInfo with _$RestaurantOrderInfo {
  factory RestaurantOrderInfo(
      {required RestaurantMenuInfo menu,
      required Map<int, int> currentOrder,
      required int restaurantId}) = _RestaurantOrderInfo;
  factory RestaurantOrderInfo.fromJson(Map<String, dynamic> json) =>
      _$RestaurantOrderInfoFromJson(json);
}

@riverpod
class RestaurantOrder extends _$RestaurantOrder {
  @override
  Future<RestaurantOrderInfo> build(int reservationId) async {
    try {
      final response = await Dio().get(
          '${dotenv.env['USER_API_URL']!}reservation-order-items',
          queryParameters: {"reservation_id": reservationId},
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      return RestaurantOrderInfo.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        throw responseBody['detail'];
      } else {
        throw "Coś poszło nie tak, spróbuj ponownie później";
      }
    }
  }

  Future<void> selectCategory(int id) async {
    try {
      final response = await Dio().get(
          '${dotenv.env['USER_API_URL']!}restaurant-category-items',
          queryParameters: {
            "restaurant_id": state.value!.restaurantId,
            "category_id": id
          },
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      final items = (response.data as List<dynamic>)
          .map((e) => RestaurantMenuItem.fromJson(e))
          .toList();
      state = AsyncData(state.value!.copyWith.menu(items: items));
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        throw responseBody['detail'];
      } else {
        throw "Coś poszło nie tak, spróbuj ponownie później";
      }
    }
  }

  void addItemToOrder(int id) {
    Map<int, int> newOrder = state.value!.currentOrder.containsKey(id)
        ? <int, int>{
            for (final x in state.value!.currentOrder.entries)
              if (x.key == id) x.key: x.value + 1 else x.key: x.value
          }
        : {...state.value!.currentOrder, id: 1};
    state = AsyncData(state.value!.copyWith(currentOrder: newOrder));
  }

  void removeItemFromOrder(int id) {
    Map<int, int> newOrder = <int, int>{
      for (final x in state.value!.currentOrder.entries)
        if (x.key == id && x.value != 1)
          x.key: x.value - 1
        else if (x.key != id)
          x.key: x.value
    };
    state = AsyncData(state.value!.copyWith(currentOrder: newOrder));
  }

  Future<bool> updateOrder() async {
    try {
      await Dio().post('${dotenv.env['USER_API_URL']!}update-order',
          data: {
            "order": state.value!.currentOrder
                .map((k, e) => MapEntry(k.toString(), e)),
            "reservation_id": reservationId
          },
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      fluttertoastDefault("Poprawnie zapisano zamówienie");
      ref.read(ReservationProvider(AuthType.user).notifier).refresh();
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak, spróbuj ponownie później", true);
      }
      return false;
    }
  }
}

@riverpod
class RestaurantMenu extends _$RestaurantMenu {
  @override
  Future<RestaurantMenuInfo> build(int restaurantId) async {
    try {
      final response = await Dio().get(
          '${dotenv.env['USER_API_URL']!}restaurant-categories',
          queryParameters: {"restaurant_id": restaurantId},
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      return RestaurantMenuInfo.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        throw responseBody['detail'];
      } else {
        throw "Coś poszło nie tak, spróbuj ponownie później";
      }
    }
  }

  Future<void> selectCategory(int id) async {
    try {
      final response = await Dio().get(
          '${dotenv.env['USER_API_URL']!}restaurant-category-items',
          queryParameters: {"restaurant_id": restaurantId, "category_id": id},
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      final items = (response.data as List<dynamic>)
          .map((e) => RestaurantMenuItem.fromJson(e))
          .toList();
      state = AsyncData(state.value!.copyWith(items: items));
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        throw responseBody['detail'];
      } else {
        throw "Coś poszło nie tak, spróbuj ponownie później";
      }
    }
  }
}
