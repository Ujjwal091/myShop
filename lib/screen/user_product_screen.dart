import 'package:flutter/material.dart';
import 'package:myshop/screen/edit_product_screen.dart';
import 'package:myshop/widget/app_drawer.dart';
import 'package:provider/provider.dart';

import '../provider/products.dart';
import '../widget/user_product_item.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = '/user-products';
  const UserProductScreen({super.key});

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productData = Provider.of<Products>(context);
    return Scaffold(
      // appBar: AppBar(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routName);
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (context, productData, child) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemCount: productData.items.length,
                          itemBuilder: ((context, index) => Column(
                                children: [
                                  UserProductItem(
                                    id: productData.items[index].id,
                                    title: productData.items[index].title,
                                    imageUrl: productData.items[index].imageUrl,
                                  ),
                                  const Divider()
                                ],
                              )),
                        ),
                      ),
                    ),
                  ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
