import 'package:flutter/material.dart';
import 'package:myshop/helpers/custom_route.dart';
import 'package:myshop/screen/auth_screen.dart';
import 'package:myshop/screen/splash_screen.dart';
import 'package:provider/provider.dart';

import './provider/auth.dart';
import './provider/cart.dart';
import './provider/orders.dart';
import './provider/products.dart';
import './screen/cart_screen.dart';
import './screen/edit_product_screen.dart';
import './screen/orders_screen.dart';
import './screen/product_detail_screen.dart';
import './screen/products_overview_screen.dart';
import './screen/user_product_screen.dart';

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
          create: (context) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (context, value, previous) => Products(
            value.token,
            value.userId,
            previous != null ? [] : previous!.items,
          ),
          create: (context) => Products('', '', []),
        ),
        ChangeNotifierProvider(
          create: (context) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (context) => Orders('', '', []),
          update: (context, value, previous) => Orders(value.token,
              value.userId, previous == null ? [] : previous.orders),
        ),
      ],

      // value: Products(),
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                  .copyWith(secondary: Colors.deepOrange.shade100),
              primarySwatch: Colors.purple,
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
                TargetPlatform.windows: CustomPageTransitionBuilder()
              })),
          home: auth.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, authResult) => authResult.data == null
                      ? const AuthScreen()
                      // ? Container()
                      : authResult.connectionState == ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            // '/': (context) => const ProductsOverviewScreen(),
            // '/': (context) => const AuthScreen(),
            ProductsOverviewScreen.routeName: (context) =>
                const ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (context) =>
                const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            UserProductScreen.routeName: (context) => const UserProductScreen(),
            EditProductScreen.routName: (context) => const EditProductScreen(),
          },
        ),
      ),
    );
  }
}
