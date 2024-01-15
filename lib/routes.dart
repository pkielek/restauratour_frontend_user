import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';
import 'package:utils/utils.dart';



// final loggedOutRoute = RouteMap(routes: {
//   '/': (_) => MaterialPage(child:LoginView()),
// }, onUnknownRoute: (_) => const Redirect('/'));

final loadingRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child:LoadingScreen())
}, onUnknownRoute: (_) => const MaterialPage(child:LoadingScreen()));

// final navigationRoutes = {
//   '/pulpit': (_) => const MaterialPage(child:PlannerView(),name:'Plan restauracji'),
// };

// final routes = RouteMap(routes: {
//   '/': (_) => const Redirect('/pulpit'),
//   ...navigationRoutes
// });