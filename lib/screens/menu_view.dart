import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper_phone/model/restaurant_menu.dart';
import 'package:restaurant_helper_phone/widgets/menu/menu_item_tile.dart';
import 'package:utils/utils.dart';

class MenuView extends ConsumerWidget {
  const MenuView({super.key, required this.restaurantId});
  final String restaurantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (int.tryParse(restaurantId) == null) {
      return const Scaffold(
        body: Center(child: Text("Błąd aplikacji", style: headerStyle)),
      );
    }
    final id = int.parse(restaurantId);
    return ref.watch(RestaurantMenuProvider(id)).when(
        data: (data) {
          if (data.items.isEmpty) {
            ref
                .read(RestaurantMenuProvider(id).notifier)
                .selectCategory(data.categories.first.id);
          }
          return DefaultTabController(
            length: data.categories.length,
            child: Scaffold(
                appBar: AppBar(
                  title: const Text(
                    "Menu restauracji",
                    style: headerStyle,
                  ),
                  primary: true,
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  bottom: TabBar(
                      onTap: (value) => ref
                          .read(RestaurantMenuProvider(id).notifier)
                          .selectCategory(data.categories[value].id),
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
                        for (final category in data.categories)
                          Tab(text: category.name)
                      ]),
                ),
                body: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(height:12),
                    shrinkWrap: true,
                    itemCount: data.items.length,
                    itemBuilder: (context, index) =>
                        MenuItemTile(item: data.items[index]),
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
