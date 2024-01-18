import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper_phone/model/restaurant_list.dart';
import 'package:restaurant_helper_phone/model/restaurant_search.dart';
import 'package:utils/utils.dart';

class SearchOptions extends ConsumerWidget {
  const SearchOptions(
      {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(restaurantSearchProvider);
    final notifier = ref.read(restaurantSearchProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(50)),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: options.searchName,
                    textInputAction: TextInputAction.search,
                    onChanged: notifier.updateSearchName,
                    onFieldSubmitted: (_) => ref.read(restaurantListProvider.notifier).search,
                    decoration: const InputDecoration(
                        labelText: "Nazwa restauracji",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none),
                  ),
                ),
                IconButton(
                    onPressed: ref.read(restaurantListProvider.notifier).search,
                    icon: const Icon(Icons.search, color: Colors.black))
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownMenu<int>(
                    inputDecorationTheme: const InputDecorationTheme(
                        isDense: true, suffixIconColor: Colors.black),
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 16),
                    requestFocusOnTap: false,
                    initialSelection: options.distanceInKm,
                    enableFilter: false,
                    enableSearch: false,
                    label: const Text("Odległość"),
                    onSelected: notifier.updateDistance,
                    expandedInsets: EdgeInsets.zero,
                    dropdownMenuEntries: [
                      for (final value in [1, 3, 5, 10, 15])
                        DropdownMenuEntry(value: value, label: "$value km")
                    ]),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SegmentedButton<bool?>(
                  onSelectionChanged: notifier.updateHasFreeTables,
                  multiSelectionEnabled: false,
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                        tooltip: "Wszystkie restauracje",
                        value: null,
                        icon: Icon(
                          Icons.restaurant,
                          color: Colors.black,
                        )),
                    ButtonSegment(
                        tooltip: "Otwarte restauracje",
                        value: false,
                        icon: Icon(
                          Icons.event_available,
                          color: Colors.black,
                        )),
                    ButtonSegment(
                        tooltip: "Wolne stoliki",
                        value: true,
                        icon: Icon(
                          Icons.table_bar,
                          color: Colors.black,
                        ))
                  ],
                  selected: {options.hasFreeTables},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: options.hasFreeTables != true
                    ? const SizedBox()
                    : DropdownMenu<int>(
                        enabled: options.hasFreeTables == true,
                        inputDecorationTheme: const InputDecorationTheme(
                            isDense: true, suffixIconColor: Colors.black),
                        selectedTrailingIcon: Icon(
                            options.guestsAmount == 1
                                ? Icons.person
                                : options.guestsAmount == 2
                                    ? Icons.group
                                    : Icons.groups,
                            color: Colors.black),
                        trailingIcon: Icon(
                            options.guestsAmount == 1
                                ? Icons.person
                                : options.guestsAmount == 2
                                    ? Icons.group
                                    : Icons.groups,
                            color: Colors.black),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontSize: 16),
                        requestFocusOnTap: false,
                        initialSelection: options.guestsAmount,
                        enableFilter: false,
                        enableSearch: false,
                        label: const Text("Liczba gości"),
                        onSelected: notifier.updateGuestsAmount,
                        expandedInsets: EdgeInsets.zero,
                        dropdownMenuEntries: [
                            for (final value
                                in List.generate(8, (index) => index + 1))
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
              ),
            ],
          ),
          if(options.hasFreeTables != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width:60,
                child: SegmentedButton<bool>(
                    onSelectionChanged: (value) => value.isEmpty
                        ? notifier.updateDaysAvailable({0})
                        : notifier.updateDaysAvailable({}),
                    showSelectedIcon: false,
                    emptySelectionAllowed: true,
                    segments: [
                      ButtonSegment(
                          label: Text(
                            "Teraz",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: options.daysAvailable.isEmpty
                                    ? FontWeight.bold
                                    : FontWeight.normal),
                          ),
                          value: true)
                    ],
                    selected: options.daysAvailable.isEmpty ? {true} : {}),
              ),
              const SizedBox(width: 8,height:58),
              if (options.daysAvailable.isNotEmpty)
                Expanded(
                  child: SegmentedButton<int>(
                      style: const ButtonStyle(padding: MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal:0)),minimumSize: MaterialStatePropertyAll(Size(0,0))),
                      onSelectionChanged: notifier.updateDaysAvailable,
                      showSelectedIcon: false,
                      emptySelectionAllowed: true,
                      multiSelectionEnabled: true,
                      segments: [
                        for (final i in List.generate(6, (index) => index))
                          ButtonSegment(
                              label: Text(
                                getWeekdayNameShort(i),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                    fontWeight:
                                        options.daysAvailable.contains(i)
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                              ),
                              value: i)
                      ],
                      selected: options.daysAvailable),
                ),
              const SizedBox(width: 8),
              if (options.daysAvailable.isNotEmpty)
                SizedBox(
                  width: 25,
                  child: TextFormField(
                    maxLength: 2,
                    
                    initialValue: options.timeStart.toString(),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    onChanged: notifier.updateTimeStart,
                    decoration: const InputDecoration(

                        counterText: "",
                        labelText: "Od",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none),
                  ),
                ),
              if (options.daysAvailable.isNotEmpty)
              
                const SizedBox(
                  width: 25,
                  child: Text("-",
                      textAlign: TextAlign.left, style: TextStyle(fontSize: 32, color: Colors.black87)),
                ),
              if (options.daysAvailable.isNotEmpty)
                SizedBox(
                  width: 25,
                  child: TextFormField(
                    
                    maxLength: 2,
                    initialValue: options.timeEnd.toString(),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    onChanged: notifier.updateTimeEnd,
                    decoration: const InputDecoration(
                        counterText: "",
                        labelText: "Do",
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
