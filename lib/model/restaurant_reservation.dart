import 'package:auth/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:utils/utils.dart';

part 'restaurant_reservation.g.dart';
part 'restaurant_reservation.freezed.dart';

enum ReservationStatus {
  @JsonValue("Oczekująca")
  pending,
  @JsonValue("Odrzucona")
  rejected,
  @JsonValue("Zaakceptowana")
  accepted;

  String get label {
    switch (this) {
      case pending:
        return 'Oczekuje na potwierdzenie';
      case rejected:
        return 'Rezerwacja odrzucona';
      case accepted:
        return 'Rezerwacja zaakceptowana';
    }
  }

  Color get color {
    switch (this) {
      case pending:
        return Colors.yellow.shade900;
      case rejected:
        return Colors.red;
      case accepted:
        return Colors.green;
    }
  }

  IconData get icon {
    switch (this) {
      case pending:
        return Icons.schedule;
      case rejected:
        return Icons.block;
      case accepted:
        return Icons.done;
    }
  }
}

@freezed
class RestaurantReservation with _$RestaurantReservation {
  RestaurantReservation._();
  factory RestaurantReservation({
    required int id,
    required int restaurantId,
    required String name, // restaurant or client
    required int table,
    required DateTime date,
    required ReservationStatus status,
    required int guestsAmount,
    required Map<String, Map<String, dynamic>> order,
    required bool needService,
    required double reservationHourLength,
  }) = _RestaurantReservation;
  factory RestaurantReservation.fromJson(Map<String, dynamic> json) =>
      _$RestaurantReservationFromJson(json);
}

@freezed
class RestaurantReservationHistory with _$RestaurantReservationHistory {
  RestaurantReservationHistory._();
  factory RestaurantReservationHistory({
    @Default(0) @JsonKey(ignore: true) int pagination,
    @Default(false) @JsonKey(ignore: true) bool finishedLoading,
    @Default(false) @JsonKey(ignore: true) bool isLoading,
    required List<RestaurantReservation> reservations,
  }) = _RestaurantReservationHistory;
  factory RestaurantReservationHistory.fromJson(Map<String, dynamic> json) =>
      _$RestaurantReservationHistoryFromJson(json);
}

@riverpod
class Reservation extends _$Reservation {
  @override
  Future<List<RestaurantReservation>> build(AuthType type) async {
    try {
      final response = await Dio().get(
          '${dotenv.env['${type.name.toUpperCase()}_API_URL']!}current-reservations',
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      return (response.data as List<dynamic>)
          .map((e) => RestaurantReservation.fromJson(e))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        throw responseBody['detail'];
      } else {
        throw "Coś poszło nie tak, spróbuj ponownie później";
      }
    }
  }

  Future<bool> cancel(int reservationId) async {
    try {
      await Dio().post('${dotenv.env['USER_API_URL']!}cancel-reservation',
          data: {"reservation_id": reservationId},
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      ref.invalidateSelf();
      fluttertoastDefault("Anulowano rezerwację pomyślnie");
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

  Future<void> notifyService(int reservationId) async {
    try {
      final response = await Dio().post(
          '${dotenv.env['USER_API_URL']!}notify-service',
          data: {"reservation_id": reservationId},
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      state = AsyncData([
        for (final reservation in state.value!)
          if (reservation.id == reservationId)
            reservation.copyWith(needService: response.data)
          else
            reservation
      ]);
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak, spróbuj ponownie później", true);
      }
    }
  }

  void refresh() {
    ref.invalidateSelf();
  }
}

@riverpod
Future<bool> hasOngoingReservations(HasOngoingReservationsRef ref) async {
  try {
    final response = await Dio().get(
        '${dotenv.env['USER_API_URL']!}has-ongoing-reservations',
        options: Options(headers: {
          "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
        }));
    return response.data;
  } on DioException {
    return false;
  }
}

@riverpod
class ReservationHistory extends _$ReservationHistory {
  @override
  Future<RestaurantReservationHistory> build() async {
    return RestaurantReservationHistory(
        reservations: await getNext(1), pagination: 1);
  }

  Future<void> paginate() async {
    if (!state.value!.finishedLoading) {
      state = AsyncData(state.value!
          .copyWith(pagination: state.value!.pagination + 1, isLoading: true));
      final nextItems = await getNext();
      if (nextItems.isEmpty) {
        state = AsyncData(
            state.value!.copyWith(finishedLoading: true, isLoading: false));
      } else {
        state = AsyncData(state.value!.copyWith(
            reservations: [...state.value!.reservations, ...nextItems],
            isLoading: false));
      }
    }
  }

  Future<List<RestaurantReservation>> getNext([int? pagination]) async {
    try {
      final response = await Dio().get(
          '${dotenv.env['USER_API_URL']!}reservations-history',
          queryParameters: {'page': pagination ?? state.value!.pagination},
          options: Options(headers: {
            "Authorization": "Bearer ${ref.read(authProvider).value!.jwtToken}"
          }));
      return (response.data as List<dynamic>)
          .map((e) => RestaurantReservation.fromJson(e))
          .toList();
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
