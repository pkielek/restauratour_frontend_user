import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

import 'screens/home_view.dart';
import 'screens/login_view.dart';
import 'screens/menu_view.dart';
import 'screens/register_view.dart';
import 'screens/reservations_view.dart';
import 'screens/restaurant_view.dart';



final loggedOutRoute = RouteMap(routes: {
  '/': (_) => MaterialPage(child:LoginView()),
  '/register': (_) => MaterialPage(child:RegisterView()),
}, onUnknownRoute: (_) => const Redirect('/'));

final loadingRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child:LoadingScreen())
}, onUnknownRoute: (_) => const MaterialPage(child:LoadingScreen()));


final routes = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeView()),
  '/restaurants/:id': (route) => MaterialPage(child: RestaurantView(restaurantId: route.pathParameters['id']!,)),
  '/restaurants/:id/menu': (route) => MaterialPage(child: MenuView(restaurantId: route.pathParameters['id']!,)),
  '/search': (_) => MaterialPage(child: HomeView()),
  '/reservations': (_) => MaterialPage(child: ReservationsView()),
},onUnknownRoute: (_) => const Redirect('/'));