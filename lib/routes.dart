import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';

import 'screens/home_view.dart';
import 'screens/login_view.dart';
import 'screens/menu_view.dart';
import 'screens/order_view.dart';
import 'screens/planner_view.dart';
import 'screens/register_view.dart';
import 'screens/reservation_view.dart';
import 'screens/reservations_history_view.dart';
import 'screens/reservations_view.dart';
import 'screens/restaurant_view.dart';



final loggedOutRoute = RouteMap(routes: {
  '/': (_) => MaterialPage(child:LoginView()),
  '/register': (_) => const MaterialPage(child:RegisterView()),
}, onUnknownRoute: (_) => const Redirect('/'));

final loadingRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child:LoadingScreen())
}, onUnknownRoute: (_) => const MaterialPage(child:LoadingScreen()));


final routes = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeView()),
  '/restaurants/:id': (route) => MaterialPage(child: RestaurantView(restaurantId: route.pathParameters['id']!,)),
  '/restaurants/:id/menu': (route) => MaterialPage(child: MenuView(restaurantId: route.pathParameters['id']!)),
  '/restaurants/:id/planner': (route) => MaterialPage(child: PlannerView(restaurantId: route.pathParameters['id']!,)),
  '/reservations': (_) => const MaterialPage(child: ReservationsView()),
  '/reservations_history': (_) => const MaterialPage(child: ReservationsHistoryView()),
  '/reservations/:id': (route) => MaterialPage(child: ReservationView(reservationId: route.pathParameters['id']!, isPast: false)),
  '/reservations/:id/order': (route) => MaterialPage(child: OrderView(reservationId: route.pathParameters['id']!)),
  '/reservations_history/:id': (route) => MaterialPage(child: ReservationView(reservationId: route.pathParameters['id']!, isPast: true))

},onUnknownRoute: (_) => const Redirect('/'));