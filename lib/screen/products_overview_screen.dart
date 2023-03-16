import 'package:flutter/material.dart';
import 'package:myshop/provider/products.dart';
import 'package:provider/provider.dart';

import './cart_screen.dart';
import '../provider/cart.dart';
import '../widget/app_drawer.dart';
import '../widget/badget.dart';
import '../widget/products_grid.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = 'products-overview';
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = false;
  var _isLoading = false;

  void _showError() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Something went wrong')));
  }

  @override
  void didChangeDependencies() {
    if (_isInit == false) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((_) {
        setState(() {
          _isLoading = false;
        });
        _showError();
      });
    }
    _isInit = true;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyShop"),
        actions: [
          PopupMenuButton(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: FilterOptions.favorites, child: Text("Only Favorite")),
              const PopupMenuItem(
                  value: FilterOptions.all, child: Text("Show All")),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cartData, ch) => InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              child: Badge(
                value: cartData.itemCount.toString(),
                color: Colors.blue,
                child: ch!,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
      drawer: const AppDrawer(),
    );
  }
}
