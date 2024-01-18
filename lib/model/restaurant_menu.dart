import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

@riverpod
class RestaurantMenu extends _$RestaurantMenu {
  @override
  Future<RestaurantMenuInfo> build(int restaurantId) async {
    try {
      final response = await Dio().get(
          '${dotenv.env['USER_API_URL']!}restaurant-categories',
          data: restaurantId != null ? {"restaurant_id": restaurantId} : null,
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
          data: restaurantId != null
              ? {"restaurant_id": restaurantId, "category_id": id}
              : null,
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
