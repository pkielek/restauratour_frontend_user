import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:restaurant_helper_phone/model/restaurant_menu.dart';
import 'package:utils/utils.dart';

class MenuItemTile extends HookConsumerWidget {
  const MenuItemTile({super.key, required this.item});
  final RestaurantMenuItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height:150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (item.photoUrl.isNotEmpty)
            AspectRatio(
                aspectRatio: 1.0,
                child: Image.network(item.photoUrl, fit: BoxFit.fill)),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: RichText(
                    text: TextSpan(
                        text: item.name +
                            (item.isAvailable ? "" : " (Niedostępny)"),
                        style: listStyle.copyWith(
                            color: item.isAvailable ? Colors.black : Colors.grey),
                        children: [
                      TextSpan(
                          text: '\n${item.description}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15))
                    ])),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '${item.price.toStringAsFixed(2)} zł',
                  style: listStyle,
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
