import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:utils/utils.dart';

import '../../model/restaurant_reservation.dart';

class ReservationTile extends ConsumerWidget {
  const ReservationTile({super.key, required this.data});
  final RestaurantReservation data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [BoxShadow(blurRadius: 5.0, spreadRadius: 1.0)],
          borderRadius: BorderRadius.circular(40)),
      child: Row(
        children: [
          IntrinsicHeight(
            child: Container(
              width: 50,
              decoration: BoxDecoration(
                  color: primaryColor,
                  border: Border.all(color: primaryColor, width: 3),
                  borderRadius: BorderRadius.circular(5)),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        data.date.fullDay(),
                        textAlign: TextAlign.center,
                        style: headerStyle.copyWith(color: Colors.white),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Text(
                        data.date.month3Chars(),
                        style: headerStyle,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ]),
            ),
          ),
          Expanded(
              child: ListTile(
            title: Text(
               data.name,
              style: listStyle,
            ),
            subtitle: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "${data.date.fullHour()}\n",
                    style: listLightStyle.copyWith(color: Colors.black)),
                const WidgetSpan(
                    child: Padding(
                  padding: EdgeInsets.only(bottom: 18),
                )),
                TextSpan(
                    text: "${data.status.label} ",
                    style: smallDetailStyle.copyWith(color: data.status.color)),
                WidgetSpan(
                    child: Icon(data.status.icon,
                        color: data.status.color, size: 12))
              ]),
            ),
            isThreeLine: true,
          )),
          Column(mainAxisAlignment: MainAxisAlignment.center,children: [
            RichText(
                text: TextSpan(
              children: [
                const WidgetSpan(child: Icon(Icons.people, size: 18)),
                TextSpan(
                    text: " ${data.guestsAmount.toString()}",
                    style: listStyle.copyWith(color: Colors.black))
              ],
            )),
            const Padding(padding: EdgeInsets.symmetric(vertical: 10)),
            RichText(
                text: TextSpan(
              children: [
                WidgetSpan(
                    child: Icon(Icons.restaurant_menu,
                        size: 18,
                        color:
                            data.order.isEmpty ? primaryColor : Colors.black)),
                TextSpan(
                    text: " ${data.order.length.toString()}",
                    style: listStyle.copyWith(
                        color:
                            data.order.isEmpty ? primaryColor : Colors.black))
              ],
            )),
          ])
        ],
      ),
    );
  }
}
