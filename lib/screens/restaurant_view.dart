import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant/restaurant.dart';
import 'package:restaurant_helper_phone/model/restaurant_list.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

class RestaurantView extends ConsumerWidget {
  const RestaurantView({super.key, required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (int.tryParse(restaurantId) == null) {
      return const Scaffold(
        body: Center(child: Text("Błąd aplikacji", style: headerStyle)),
      );
    }
    final id = int.parse(restaurantId);
    final RestaurantBaseData initData = ref
        .read(restaurantListProvider)
        .value!
        .firstWhere((element) => element.id == id);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            initData.name,
            style: headerStyle,
          ),
          primary: true,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          shrinkWrap: true,
          children: [
            AspectRatio(
              aspectRatio: 2.0,
              child: Hero(
                tag: "restaurant_photo:$restaurantId",
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                              initData.photoUrl.isEmpty
                                  ? "https://zmbfyqdwrbmykdtzopwo.supabase.co/storage/v1/object/public/menuitemspictures/restaurant_pictures/default.png"
                                  : initData.photoUrl,
                              scale: 1.0))),
                ),
              ),
            ),
            ref.watch(InfoProvider(id)).when(
                data: (data) {
                  return Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              width: 1000,
                              child: DefaultButton(
                                  callback: () => null,
                                  text: "Zarezerwuj stolik")),
                          SizedBox(
                              width: 1000,
                              child: DefaultButton(
                                  callback: () => Routemaster.of(context).push('menu'), text: "Zobacz menu")),
                          const Text("Adres", style: listStyle),
                          Text(data.toFullAddress, style: listLightStyle),
                          const SizedBox(height: 30),
                          const Text("Godziny otwarcia", style: listStyle),
                          for (final hour in data.openingHours.entries)
                            Text(
                              "${getWeekdayName(hour.key)}: ${hour.value.closed ? "Zamknięte" : "${hour.value.openTime} - ${hour.value.closeTime}"}${hour.value.temporary ? " (Tymczasowo)" : ""}",
                              style: listLightStyle,
                            ),
                          const SizedBox(height: 30),
                          const Text("Kontakt", style: listStyle),
                          ListTile(
                              leading:
                                  const Icon(Icons.email, color: primaryColor),
                              title: Text(data.email, style: listLightStyle)),
                          ListTile(
                              leading:
                                  const Icon(Icons.phone, color: primaryColor),
                              title: Text(data.phoneNumber,
                                  style: listLightStyle)),
                          const SizedBox(height: 30),
                          const Text("Numer identyfikacji podatkowej",
                              style: listStyle),
                          Text(data.nip, style: listLightStyle),
                          SizedBox(
                            height: 200,
                            child: true
                                ? Container(color: Colors.red)
                                : GoogleMap(
                                    markers: {
                                        Marker(
                                            markerId: const MarkerId(""),
                                            position: LatLng(
                                                data.latitude, data.longitude))
                                      },
                                    initialCameraPosition: CameraPosition(
                                        zoom: 15.0,
                                        target: LatLng(
                                            data.latitude, data.longitude))),
                          )
                        ]),
                  );
                },
                error: (error, stackTrace) => const Center(
                    child: Text("Niewłaściwa restauracja", style: headerStyle)),
                loading: () => Container())
          ],
        ));
  }
}
