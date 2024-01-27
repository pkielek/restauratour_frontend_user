import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant/restaurant.dart';
import 'package:restaurant_helper_phone/widgets/planner/reservation_options.dart';
import 'package:utils/utils.dart';
import 'package:auth/auth.dart';
import 'package:planner/planner.dart';

class PlannerView extends ConsumerWidget {
  const PlannerView({super.key, required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (int.tryParse(restaurantId) == null) {
      return const Scaffold(
        body: Center(child: Text("Błąd aplikacji", style: headerStyle)),
      );
    }
    final id = int.parse(restaurantId);
    final provider = ref.watch(PlannerInfoProvider(AuthType.user, id));
    final notifier = ref.read(PlannerInfoProvider(AuthType.user, id).notifier);
    final reservationsEnabled = ref
        .read(InfoProvider(id))
        .value!
        .flags
        .firstWhere((element) => element.id == 3)
        .setting;
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Widok restauracji",
            style: headerStyle,
          ),
          primary: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: provider.when(
            data: (board) {
              return Row(
                children: [
                  Expanded(
                    child: Stack(children: [
                      PlannerBoard(board: board, notifier: notifier),
                      if (reservationsEnabled)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 58,
                              child: ReservationOptions(restaurantId: id)),
                        ),
                    ]),
                  ),
                ],
              );
            },
            error: (error, stackTrace) => Center(
                    child: Text(
                  error.toString(),
                  style: boldBig,
                )),
            loading: () => const Center(
                child: Loading("Trwa ładowanie planu restauracji..."))));
  }
}
