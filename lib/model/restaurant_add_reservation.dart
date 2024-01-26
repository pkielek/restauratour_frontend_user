import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:restaurant/restaurant.dart';
import 'package:utils/utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:planner/planner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'restaurant_add_reservation.g.dart';
part 'restaurant_add_reservation.freezed.dart';

@freezed
class RestaurantAddReservationData with _$RestaurantAddReservationData {
  factory RestaurantAddReservationData({
    @Default(2) int guestsAmount,
    required DateTime? date,
    @Default([]) @JsonKey(includeToJson: false) List<DateTime> availableTimes,
    @Default(null) @JsonKey(ignore: true) int? reservationSuccessful,
  }) = _RestaurantAddReservationData;
  factory RestaurantAddReservationData.fromJson(Map<String, dynamic> json) =>
      _$RestaurantAddReservationDataFromJson(json);
}

@riverpod
class RestaurantAddReservation extends _$RestaurantAddReservation {
  @override
  RestaurantAddReservationData build(int restaurantId) {
    ref.listenSelf((previous, next) {
      if (next.availableTimes.isEmpty &&
          previous != null &&
          previous.availableTimes.isNotEmpty)
        ref
            .read(PlannerInfoProvider(AuthType.user, restaurantId).notifier)
            .updateCustomSelectTable(null);
    });
    return RestaurantAddReservationData(date: null);
  }

  Future<void> updateDate(DateTime date, TextEditingController timeController) async {
    try {
      Map<String, dynamic> requestData = state.copyWith(date: date).toJson();
      requestData['restaurant_id'] = restaurantId;
      final response = await Dio().get(
          '${dotenv.env['USER_API_URL']!}get-date-available-times',
          queryParameters: requestData,
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      final newTimes = (response.data as List<dynamic>)
          .map((e) => DateTime.parse(e))
          .toList();
      final newDate = DateTime(
          date.year,
          date.month,
          date.day,
          newTimes.isEmpty ? 0 : newTimes[0].hour,
          newTimes.isEmpty ? 0 : newTimes[0].minute);
      timeController.text = newTimes.isEmpty ? '-' : newTimes[0].fullHour();
      if (newTimes.isEmpty)
        fluttertoastDefault(
            "Niestety, wszystkie stoliki o takiej liczbie gości są tego dnia zajęte");
      state = state.copyWith(availableTimes: newTimes, date: newDate);
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        throw responseBody['detail'];
      } else {
        throw "Coś poszło nie tak, spróbuj ponownie później";
      }
    }
  }

  void updateGuestsAmount(int? amount, TextEditingController timeController) {
    if (amount == null) return;
    state = state.copyWith(guestsAmount: amount);
    if (state.date != null) {
      updateDate(state.date!, timeController);
    }
  }

  Future<bool> makeReservation(PlannerTable? table) async {
    if (table != null && !ref
        .read(PlannerInfoProvider(AuthType.user, restaurantId))
        .value!
        .allowedTables
        .contains(table.id)) {
      fluttertoastDefault("Stolik jest już zajęty w wybranym terminie", true);
      return false;
    }
    try {
      Map<String, dynamic> requestData = state.toJson();
      requestData['restaurant_id'] = restaurantId;
      if(table!= null) {
        requestData['table'] = table.id;
      }
      final response = await Dio().post(
          '${dotenv.env['USER_API_URL']!}reserve-table',
          data: requestData,
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      state = state.copyWith(reservationSuccessful: response.data);
      fluttertoastDefault("Rezerwacja zakończona sukcesem!");
      return true;
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
        return false;
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak, spróbuj ponownie później", true);
        return false;
      }
    }
  }

  void updateTime(DateTime? time, int restaurantId, bool isDialog) {
    if (time == null) return;
    final newDate = DateTime(state.date!.year, state.date!.month,
        state.date!.day, time.hour, time.minute);
    if(!isDialog) {
    final reservationsEnabled = ref
        .read(InfoProvider(restaurantId))
        .value!
        .flags
        .firstWhere((element) => element.id == 4)
        .setting;
    ref
        .read(PlannerInfoProvider(AuthType.user, restaurantId).notifier)
        .updateAllowedTables(newDate, state.guestsAmount, reservationsEnabled);
    if (reservationsEnabled) {
      ref
          .read(PlannerInfoProvider(AuthType.user, restaurantId).notifier)
          .updateCustomSelectTable(makeReservation);
    }
    }

    state = state.copyWith(date: newDate);
  }
}
