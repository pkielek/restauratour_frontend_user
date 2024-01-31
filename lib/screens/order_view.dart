import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reservations/reservations.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';
import 'package:menu/menu.dart';

class OrderView extends ConsumerWidget {
  const OrderView({super.key, required this.reservationId});
  final String reservationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (int.tryParse(reservationId) == null) {
      return const Scaffold(
        body: Center(child: Text("Błąd aplikacji", style: headerStyle)),
      );
    }
    final id = int.parse(reservationId);
    return ref.watch(RestaurantOrderProvider(id)).when(
        data: (data) {
          return DefaultTabController(
            length: data.menu.categories.length,
            child: Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                        onPressed: () async => await ref
                                .read(RestaurantOrderProvider(id).notifier)
                                .updateOrder(ref.read(ReservationProvider(AuthType.user).notifier).refresh)
                            ? Routemaster.of(context).pop()
                            : null,
                        icon: const Icon(Icons.save))
                  ],
                  title: const Text(
                    "Zamówienie rezerwacji",
                    style: headerStyle,
                  ),
                  primary: true,
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  bottom: TabBar(
                      onTap: (value) => ref
                          .read(RestaurantOrderProvider(id).notifier)
                          .selectCategory(data.menu.categories[value].id),
                      unselectedLabelStyle:
                          const TextStyle(fontWeight: FontWeight.w300),
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      unselectedLabelColor: Colors.white,
                      tabAlignment: TabAlignment.center,
                      isScrollable: true,
                      indicatorColor: Colors.white,
                      dividerColor: Colors.white,
                      labelColor: Colors.white,
                      tabs: [
                        for (final category in data.menu.categories)
                          Tab(text: category.name)
                      ]),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(12),
                  child: data.menu.items.isEmpty
                      ? ListView(shrinkWrap: true, children: [
                          const Text(
                            "Niestety, w tej kategorii nie ma obecnie pozycji",
                            textAlign: TextAlign.center,
                            style: headerStyle,
                          ),
                          Image.asset("images/missing2.png"),
                          const Text("© Storyset, Freepik",
                              textAlign: TextAlign.center,
                              style: footprintStyle),
                        ])
                      : ListView.separated(
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          shrinkWrap: true,
                          itemCount: data.menu.items.length,
                          itemBuilder: (context, index) => Row(children: [
                            Expanded(
                                child:
                                    MenuItemTile(item: data.menu.items[index])),
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Column(children: [
                                if (data.menu.items[index].isAvailable)
                                  IconButton(
                                      onPressed: () => ref
                                          .read(RestaurantOrderProvider(id)
                                              .notifier)
                                          .addItemToOrder(
                                              data.menu.items[index].id),
                                      icon: const Icon(Icons.add,
                                          color: Colors.green)),
                                Text(
                                  "${data.currentOrder[data.menu.items[index].id] ?? 0}x",
                                  style: listStyle,
                                ),
                                if (data.currentOrder.containsKey(
                                        data.menu.items[index].id) &&
                                    data.menu.items[index].isAvailable)
                                  IconButton(
                                      onPressed: () => ref
                                          .read(RestaurantOrderProvider(id)
                                              .notifier)
                                          .removeItemFromOrder(
                                              data.menu.items[index].id),
                                      icon: const Icon(Icons.remove,
                                          color: Colors.red))
                                else
                                  const IconButton(
                                      onPressed: null,
                                      icon: Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                      ))
                              ]),
                            )
                          ]),
                        ),
                )),
          );
        },
        error: (error, stackTrace) => Scaffold(
              body: Center(child: Text(error.toString(), style: headerStyle)),
            ),
        loading: () => const Scaffold(
              body: Center(child: Loading("Ładowanie kategorii..")),
            ));
  }
}
