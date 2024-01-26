import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:planner/planner.dart';
import 'package:restaurant/restaurant.dart';
import 'package:restaurant_helper_phone/model/restaurant_add_reservation.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

class ReservationOptions extends HookConsumerWidget {
  const ReservationOptions(
      {super.key, required this.restaurantId, this.isDialog = false});
  final int restaurantId;
  final bool isDialog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
        RestaurantAddReservationProvider(restaurantId)
            .select((value) => value.reservationSuccessful), (previous, next) {
      if (next != null) {
        !isDialog ? Routemaster.of(context).replace('/reservations/$next') : null; 
      }
    });
    if (ref.watch(RestaurantAddReservationProvider(restaurantId)
        .select((value) => value.reservationSuccessful != null))) {}
    final provider = ref.watch(RestaurantAddReservationProvider(restaurantId));
    final notifier =
        ref.read(RestaurantAddReservationProvider(restaurantId).notifier);
    final dateController = useTextEditingController(
        text: provider.date == null
            ? '-'
            : provider.date!.fullDate());
    final timeController = useTextEditingController(
        text: provider.availableTimes.isEmpty
            ? '-'
            : provider.availableTimes.first.fullHour());
    if (provider.availableTimes.isEmpty) {
      timeController.text = '-';
    }

    final guestsAmountWidget = Expanded(
      child: DropdownMenu<int>(
          inputDecorationTheme: const InputDecorationTheme(
              isDense: true, suffixIconColor: Colors.black),
          selectedTrailingIcon: Icon(
              provider.guestsAmount == 1
                  ? Icons.person
                  : provider.guestsAmount == 2
                      ? Icons.group
                      : Icons.groups,
              color: Colors.black),
          trailingIcon: Icon(
              provider.guestsAmount == 1
                  ? Icons.person
                  : provider.guestsAmount == 2
                      ? Icons.group
                      : Icons.groups,
              color: Colors.black),
          textStyle: const TextStyle(
              fontWeight: FontWeight.w700, color: Colors.black, fontSize: 16),
          requestFocusOnTap: false,
          initialSelection: provider.guestsAmount,
          enableFilter: false,
          enableSearch: false,
          label: const Text("Liczba gości"),
          onSelected: (value) {
            notifier.updateGuestsAmount(value, timeController);
            if(!isDialog) {
              ref
                .read(PlannerInfoProvider(AuthType.user, restaurantId).notifier)
                .resetAllowedTables();
            }
          },
          expandedInsets: EdgeInsets.zero,
          dropdownMenuEntries: [
            for (final value in List.generate(8, (index) => index + 1))
              DropdownMenuEntry(
                  value: value,
                  label: "$value",
                  leadingIcon: Icon(
                    value == 1
                        ? Icons.person
                        : value == 2
                            ? Icons.group
                            : Icons.groups,
                    color: Colors.black,
                  ))
          ]),
    );
    final dateWidget = Expanded(
        child: TextFormField(
      readOnly: true,
      onTap: () async {
        final chosenDate = await showDatePicker(
          context: context,
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          firstDate: DateTime.now().add(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 60)),
          selectableDayPredicate: (day) => !ref
              .read(InfoProvider(restaurantId))
              .value!
              .openingHours[day.weekday - 1]!
              .closed,
        );
        if (chosenDate != null) {
          await notifier.updateDate(chosenDate, timeController);
          if(!isDialog) {
            ref
              .read(PlannerInfoProvider(AuthType.user, restaurantId).notifier)
              .resetAllowedTables();
          }
          dateController.text = chosenDate.fullDate();
        }
      },
      controller: dateController,
      decoration: defaultDecoration(labelText: "Data rezerwacji"),
    ));

    final timeWidget = Expanded(
      child: DropdownMenu<DateTime?>(
          inputDecorationTheme: const InputDecorationTheme(
              isDense: true, suffixIconColor: Colors.black),
          selectedTrailingIcon: const Icon(
            Icons.schedule,
            color: Colors.black,
          ),
          trailingIcon: const Icon(Icons.schedule, color: Colors.black),
          textStyle: const TextStyle(
              fontWeight: FontWeight.w700, color: Colors.black, fontSize: 16),
          requestFocusOnTap: false,
          enableFilter: false,
          enableSearch: false,
          enabled: provider.availableTimes.isNotEmpty,
          controller: timeController,
          label: const Text("Godzina"),
          onSelected: (value) {
            notifier.updateTime(value, restaurantId,isDialog);
          },
          expandedInsets: EdgeInsets.zero,
          dropdownMenuEntries: provider.availableTimes.isEmpty
              ? const [
                  DropdownMenuEntry(
                    value: null,
                    label: "-",
                  )
                ]
              : [
                  for (final time in provider.availableTimes)
                    DropdownMenuEntry(
                        value: time, label: time.fullHour())
                ]),
    );
    if (isDialog) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text("Dane rezerwacji"),
          content: IntrinsicHeight(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(children: [
                guestsAmountWidget,
                const SizedBox(height: 20),
                dateWidget,
                const SizedBox(height: 20),
                timeWidget
              ]),
            ),
          ),
          actions: <Widget>[
          if(provider.availableTimes.isNotEmpty)
          IconButton( 
              icon: const Icon(Icons.done),
              color: Colors.green,
              tooltip: "Złóż rezerwację",
              onPressed: () async {
                if(await notifier.makeReservation(null))  {
                  Navigator.pop(context,'Złóż rezerwację');
                  Routemaster.of(context).replace('/reservations/${ref.read(RestaurantAddReservationProvider(restaurantId)).reservationSuccessful}');
                }
        
              }),
          IconButton(
              icon: const Icon(Icons.cancel),
              color: primaryColor,
              tooltip: "Anuluj",
              onPressed: () {
                Navigator.pop(context, 'Anuluj');
              })
        ],
        ),
      );
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      guestsAmountWidget,
      const SizedBox(width: 20),
      dateWidget,
      const SizedBox(width: 20),
      timeWidget,
    ]);
  }
}
