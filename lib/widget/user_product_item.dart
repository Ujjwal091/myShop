import 'package:flutter/material.dart';
import 'package:myshop/provider/products.dart';
import 'package:myshop/screen/edit_product_screen.dart';
import 'package:provider/provider.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  const UserProductItem({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(EditProductScreen.routName, arguments: id);
                },
                icon: const Icon(Icons.edit)),
            IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Are you sure?'),
                      content:
                          const Text('do you want to delete this product?'),
                      actions: [
                        TextButton(
                          child: const Text('No'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Yes'),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            try {
                              await Provider.of<Products>(context,
                                      listen: false)
                                  .deleteProduct(id);
                            } catch (error) {
                              // print('error.toString()');
                              scaffold.showSnackBar(const SnackBar(
                                content: Text("Something went wrong"),
                              ));
                              // SnackBar(
                              //       content: Text("Something went wrong"));
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.delete))
          ],
        ),
      ),
    );
  }
}
