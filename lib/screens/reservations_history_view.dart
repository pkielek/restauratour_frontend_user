import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper_phone/model/restaurant_reservation.dart';
import 'package:restaurant_helper_phone/widgets/reservations/reservation_tile.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

class ReservationsHistoryView extends HookConsumerWidget {
  const ReservationsHistoryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();
    scrollController.addListener(() async => scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            !ref.read(reservationHistoryProvider).value!.isLoading &&
            !ref.read(reservationHistoryProvider).value!.finishedLoading
        ? await ref.read(reservationHistoryProvider.notifier).paginate()
        : null);

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Historia rezerwacji",
            style: headerStyle,
          ),
          primary: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: ref.watch(reservationHistoryProvider).when(
            data: (data) {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(top: 12),
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Hero(
                          tag: "reservation:${data.reservations[index].id}",
                          child: Material(
                            child: InkWell(
                                    onTap: () => Routemaster.of(context).push(data.reservations[index].id.toString()),
                                    child: ReservationTile(
                                        data: data.reservations[index]),
                                  ),
                          ),
                        ),
                      ),
                      itemCount: data.reservations.length ,
                    ),
                  ),
                  if(data.isLoading && !data.finishedLoading)
                    const CircularProgressIndicator()
                ],
              );
            },
            error: (error, stackTrace) => const Center(
                child: Text("Coś poszło nie tak. Spróbuj ponownie później!",
                    style: headerStyle)),
            loading: () => const Loading("Ładowanie rezerwacji...")));
  }
}
