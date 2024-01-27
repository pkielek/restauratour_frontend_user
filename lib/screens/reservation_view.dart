import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reservations/reservations.dart';
import 'package:restaurant_helper_phone/widgets/reservations/reservation_tile.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

class ReservationView extends ConsumerWidget {
  const ReservationView(
      {super.key, required this.reservationId, required this.isPast});
  final String reservationId;
  final bool isPast;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (int.tryParse(reservationId) == null) {
      return const Scaffold(
        body: Center(child: Text("Błąd aplikacji", style: headerStyle)),
      );
    }
    final id = int.parse(reservationId);
    final reservationData = isPast
        ? ref.watch(reservationHistoryProvider.select((value) => value.whenData(
            (value2) => value2.reservations.firstWhere((e) => e.id == id))))
        : ref.watch(ReservationProvider(AuthType.user).select((value) =>
            value.whenData((value2) => value2.firstWhere((e) => e.id == id))));

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Szczegóły rezerwacji",
            style: headerStyle,
          ),
          primary: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: reservationData.when(
            data: (data) {
              final isOngoing = !isPast && data.date.isBefore(DateTime.now());
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Hero(
                        tag: "reservation:$reservationId",
                        child: Material(
                          child: InkWell(
                            onTap: () async {},
                            child: IntrinsicHeight(
                                child: ReservationTile(data: data)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (isOngoing && data.status == ReservationStatus.accepted)
                      DefaultButton(
                          callback: () => ref
                              .read(ReservationProvider(AuthType.user).notifier)
                              .notifyService(id),
                          text: data.needService
                              ? "Odwołaj prośbę"
                              : "Poproś o kelnera"),
                    if (!isPast && data.status != ReservationStatus.rejected)
                      DefaultButton(
                          callback: () async => await ref
                                  .read(ReservationProvider(AuthType.user)
                                      .notifier)
                                  .cancel(id)
                              ? Routemaster.of(context).pop()
                              : null,
                          text: "Anuluj rezerwację"),
                    if (data.status == ReservationStatus.accepted)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text("Zamówienie do rezerwacji:",
                            style: headerStyle, textAlign: TextAlign.center),
                      ),
                    if (data.status == ReservationStatus.accepted &&
                        data.order.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Column(children: [
                          Text(
                            isPast
                                ? "Rezerwacja nie miała zamówienia"
                                : "Rezerwacja nie ma jeszcze zamówienia - warto je złożyć wcześniej by ułatwić pracę kelnerom!",
                            textAlign: TextAlign.center,
                            style: listStyle,
                          ),
                          Image.asset("images/missing2.png"),
                          const Text("© Storyset, Freepik",
                              textAlign: TextAlign.center,
                              style: footprintStyle)
                        ]),
                      ),
                    if (data.status == ReservationStatus.accepted &&
                        data.order.isNotEmpty)
                      for (final item in data.order.entries)
                        ListTile(
                            leading: Text("${item.value['count']}x",
                                style: listLightStyle),
                            title: Text(
                              item.value['name'],
                              style: listStyle,
                            ),
                            trailing: Text(
                              item.value['total_price'],
                              style: listLightStyle,
                            )),
                    if (!isPast && data.status == ReservationStatus.accepted)
                      Padding(
                        padding: const EdgeInsets.only(top: 24.0),
                        child: DefaultButton(
                            callback: () =>
                                Routemaster.of(context).push('order'),
                            text:
                                "${data.order.isEmpty ? "Złóż" : "Edytuj"} zamówienie"),
                      ),
                    const Text("Uwagi do zamówienia:",
                        style: headerStyle, textAlign: TextAlign.center),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        if (data.areDetailsEdited)
                          Expanded(
                              child: TextFormField(
                                  maxLines: 6,
                                  initialValue: data.additionalDetails,
                                  maxLength: 240,
                                  onChanged: (value) => ref
                                      .read(ReservationProvider(AuthType.user)
                                          .notifier)
                                      .onEditDetails(id,value),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                  )))
                        else
                          Expanded(
                              child: Text(data.additionalDetails,
                                  style: listLightStyle)),
                        if (!isPast &&
                            data.status != ReservationStatus.rejected)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Column(
                                children: data.areDetailsEdited
                                    ? [
                                        IconButton(
                                            onPressed: () => ref
                                                .read(ReservationProvider(
                                                        AuthType.user)
                                                    .notifier)
                                                .saveEditDetails(id),
                                            icon: const Icon(Icons.save,
                                                color: Colors.indigo)),
                                        IconButton(
                                            onPressed: () => ref
                                                .read(ReservationProvider(
                                                        AuthType.user)
                                                    .notifier)
                                                .cancelEditDetails(id),
                                            icon: const Icon(Icons.close,
                                                color: Colors.red))
                                      ]
                                    : [
                                        IconButton(
                                            onPressed: () => ref
                                                .read(ReservationProvider(
                                                        AuthType.user)
                                                    .notifier)
                                                .editDetails(id),
                                            icon: Icon(Icons.edit,
                                                color: Colors.yellow.shade900))
                                      ]),
                          )
                      ]),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              );
            },
            error: (error, stackTrace) {
              return const Center(
                  child: Text("Coś poszło nie tak, spróbuj ponownie później!",
                      style: headerStyle));
            },
            loading: () => const Loading("Trwa ładowanie rezerwacji...")));
  }
}
