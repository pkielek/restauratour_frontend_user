import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reservations/reservations.dart';
import 'package:restaurant_helper_phone/model/restaurant_list.dart';
import 'package:restaurant_helper_phone/widgets/home/search_options.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

class HomeView extends HookConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 48),
            children: [
              Text("Cześć, ${ref.read(authProvider).value!.getUsername()}!",
                  style: headerStyle),
              const SizedBox(
                height: 25,
              ),
              ListTile(
                leading: const Icon(Icons.chair_alt),
                title: const Text(
                  "Złożone rezerwacje",
                  style: listLightStyle,
                ),
                onTap: () => Routemaster.of(context).push('reservations'),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text(
                  "Historia rezerwacji",
                  style: listLightStyle,
                ),
                onTap: () =>
                    Routemaster.of(context).push('reservations_history'),
              ),
              ListTile(
                leading: const Icon(Icons.key),
                title: const Text("Zmień hasło", style: listLightStyle),
                onTap: () => showDialog(
                  context: context,
                  builder: (context) =>
                      const ChangePasswordDialog(type: AuthType.user),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text(
                  "Wyloguj się",
                  style: listLightStyle,
                ),
                onTap: ref.read(authProvider.notifier).logOut,
              )
            ]),
      ),
      appBar: AppBar(
          title: const Text(
            "Wyszukaj restaurację",
            style: headerStyle,
          ),
          primary: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          bottom: ref.watch(hasOngoingReservationsProvider).when(
              data: (data) => data
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(40),
                      child: InkWell(
                          onTap: () =>
                              Routemaster.of(context).push('reservations'),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: "Masz trwającą rezerwację! ",
                                  style: headerStyle.copyWith(
                                      color: Colors.white)),
                              const WidgetSpan(
                                  child: Icon(Icons.trending_flat,
                                      color: Colors.white))
                            ])),
                          )))
                  : null,
              error: (_, __) => null,
              loading: () => null)),
      body: Column(
        children: [
          const SearchOptions(),
          Container(
            height: 2,
            color: Colors.black,
          ),
          ...ref.watch(restaurantListProvider).when(
              skipLoadingOnRefresh: false,
              data: (data) => data.isEmpty
                  ? [
                      RefreshIndicator(
                        onRefresh:
                            ref.read(restaurantListProvider.notifier).search,
                        child: ListView(shrinkWrap: true, children: [
                          const Padding(padding: EdgeInsets.only(top: 24)),
                          const Text(
                            "Niestety, nie znaleziono restauracji o podanych parametrach",
                            textAlign: TextAlign.center,
                            style: headerStyle,
                          ),
                          Image.asset("images/missing.png"),
                          const Text("© Storyset, Freepik",
                              textAlign: TextAlign.center,
                              style: footprintStyle),
                        ]),
                      )
                    ]
                  : [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh:
                              ref.read(restaurantListProvider.notifier).search,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 12),
                            shrinkWrap: true,
                            itemBuilder: (context, index) => AspectRatio(
                                aspectRatio: 2.0,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Hero(
                                    tag: "restaurant_photo:${data[index].id}",
                                    child: Material(
                                      child: InkWell(
                                        onTap: () async {
                                          Routemaster.of(context).push(
                                              "restaurants/${data[index].id}");
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(32),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              boxShadow: const [
                                                BoxShadow(
                                                    blurRadius: 5.0,
                                                    spreadRadius: 1.0)
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: NetworkImage(
                                                      data[index]
                                                              .photoUrl
                                                              .isEmpty
                                                          ? "https://zmbfyqdwrbmykdtzopwo.supabase.co/storage/v1/object/public/menuitemspictures/restaurant_pictures/default.png"
                                                          : data[index]
                                                              .photoUrl,
                                                      scale: 1.0))),
                                          child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withAlpha(200),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                              child: Text(
                                                data[index].name,
                                                textAlign: TextAlign.center,
                                                style: headerStyle,
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                            itemCount: data.length,
                          ),
                        ),
                      )
                    ],
              error: (error, stackTrace) => [
                    const Center(
                        child: Text(
                            "Coś poszło nie tak, spróbuj ponownie później!"))
                  ],
              loading: () => [const Expanded(child: Loading(""))])
        ],
      ),
    );
  }
}
