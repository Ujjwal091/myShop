import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './provider/cart.dart';
import './provider/orders.dart';
import 'provider/products.dart';
import './screen/cart_screen.dart';
import './screen/orders_screen.dart';
import './screen/product_detail_screen.dart';
import './screen/products_overview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Products(),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProvider.value(
          value: Orders(),
        ),
      ],

      // value: Products(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MyShop',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
              .copyWith(secondary: Colors.deepOrange),
          fontFamily: 'Lato',
        ),
        // home: ProductsOverviewScreen(),
        routes: {
          '/': (context) => const ProductsOverviewScreen(),
          ProductDetailScreen.route: (context) => const ProductDetailScreen(),
          CartScreen.routeName: (ctx) => const CartScreen(),
          OrdersScreen.routeName: (ctx) => const OrdersScreen(),
        },
      ),
    );
  }
}
