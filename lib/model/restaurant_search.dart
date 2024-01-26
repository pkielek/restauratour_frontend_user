import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


part 'restaurant_search.g.dart';
part 'restaurant_search.freezed.dart';

@freezed
class RestaurantSearchData with _$RestaurantSearchData {
  factory RestaurantSearchData({
    @Default("") String searchName,
    @Default({}) Set<int> daysAvailable,
    @Default(8) int timeStart,
    @Default(20) int timeEnd,
    @Default(2) int guestsAmount,
    @Default(5) int distanceInKm,
    @Default(null) bool? hasFreeTables,
    }) =
      _RestaurantSearch;
  factory RestaurantSearchData.fromJson(Map<String, dynamic> json) =>
      _$RestaurantSearchDataFromJson(json);
}


@Riverpod(keepAlive: true)
class RestaurantSearch extends _$RestaurantSearch {
  @override
  RestaurantSearchData build() {
    return RestaurantSearchData();
  }

  void updateSearchName(String? input) {
    if(input == null) return;
    state = state.copyWith(searchName: input);
  }

  void updateDaysAvailable(Set<int> days) {
    state = state.copyWith(daysAvailable: days, hasFreeTables: days.isNotEmpty && state.hasFreeTables==true ? false : state.hasFreeTables);
  }

  void updateTimeStart(String? hour) {
    if(hour == null || int.tryParse(hour) == null || int.parse(hour) < 0 || int.parse(hour) > 24) return;
    state = state.copyWith(timeStart: int.parse(hour));
  }

  void updateTimeEnd(String? hour) {
    if(hour == null || int.tryParse(hour) == null || int.parse(hour) < 0 || int.parse(hour) > 24) return;
    state = state.copyWith(timeEnd: int.parse(hour));
  }

  void updateGuestsAmount(int? amount) {
    if(amount == null) return;
    state = state.copyWith(guestsAmount: amount);
  }

  void updateDistance(int? km) {
    if(km == null) return;
    state = state.copyWith(distanceInKm: km);
  }
  
  void updateHasFreeTables(Set<bool?> value) {
    state = state.copyWith(hasFreeTables: value.first);
  }
}