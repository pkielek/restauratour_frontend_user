import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper_phone/model/restaurant_reservation.dart';
import 'package:restaurant_helper_phone/widgets/reservations/reservation_tile.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

class ReservationsView extends ConsumerWidget {
  const ReservationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Złożone rezerwacje",
            style: headerStyle,
          ),
          primary: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: ref.watch(ReservationProvider(AuthType.user)).when(
            data: (data) {
              return ListView.builder(
                padding: const EdgeInsets.only(top: 12),
                shrinkWrap: true,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Hero(
                    tag: "reservation:${data[index].id}",
                    child: Material(
                      child: InkWell(
                        onTap: () => Routemaster.of(context).push(data[index].id.toString()),
                        child: ReservationTile(data: data[index]),
                      ),
                    ),
                  ),
                ),
                itemCount: data.length,
              );
            },
            error: (error, stackTrace) => const Center(
                child: Text("Coś poszło nie tak, spróbuj ponownie później!", style: headerStyle)),
            loading: () => const Loading("Ładowanie rezerwacji...")));
  }
}
