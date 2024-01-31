import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:menu/menu.dart';
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
                  child: data.items.isEmpty ? ListView(shrinkWrap: true, children: [
                          const Text(
                            "Niestety, w tej kategorii nie ma obecnie pozycji",
                            textAlign: TextAlign.center,
                            style: headerStyle,
                          ),
                          Image.asset("images/missing2.png"),
                          const Text("© Storyset, Freepik",
                              textAlign: TextAlign.center,
                              style: footprintStyle),
                        ]) : ListView.separated(
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
