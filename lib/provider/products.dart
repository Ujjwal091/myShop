import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myshop/constants.dart';
import 'package:myshop/models/http_exception.dart';

import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
    // for (int i = 0; i < a.length; i++) {
    //   print(a[i].title);
    // }
  }

  // Future<void> addProduct(Product product) {
  //   final url = Uri.parse(
  //       'https://myshop-7530a-default-rtdb.firebaseio.com/products.json');
  //   return http
  //       .post(
  //     url,
  //     body: json.encode({
  //       'title': product.title,
  //       'description': product.description,
  //       'imageUrl': product.imageUrl,
  //       'price': product.price,
  //       'isFavorite': product.isFavorite,
  //     }),
  //   )
  //       .then((value) {
  //     final newProduct = Product(
  //       id: json.decode(value.body)['name'],
  //       description: product.description,
  //       imageUrl: product.imageUrl,
  //       price: product.price,
  //       title: product.title,
  //     );
  //     _items.add(newProduct);
  //     notifyListeners();
  //   }).catchError((error) {
  //     print(error);
  //     throw error;
  //   });
  // }

  String? authToken;
  String? userId;

  Products(this.authToken, this.userId, this._items);

  Future<void> fetAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creator"&equalTo="$userId"' : '';
    final url =
        Uri.parse('$dataUrl/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      var extractedData = jsonDecode(response.body) as Map<String, dynamic>;

      if (extractedData.isEmpty) {
        return;
      }

      final favaoriteResponse = await http.get(
          Uri.parse('$dataUrl/userFavorites/$userId.json?auth=$authToken'));
      final favoriteData = json.decode(favaoriteResponse.body);
      List<Product> loadedProduct = [];

      extractedData.forEach((productId, productData) {
        loadedProduct.add(Product(
          id: productId,
          description: productData['description'],
          imageUrl: productData['imageUrl'],
          // ensure productData will always promoted to double from integer type
          price: productData['price'] * 1.0,
          title: productData['title'],
          isFavorite:
              favoriteData == null ? false : favoriteData[productId] ?? false,
        ));
      });

      _items = loadedProduct;

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse('$dataUrl/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavorite': product.isFavorite,
          'creator': userId,
        }),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse('$dataUrl/products/$id.json?auth=$authToken');

    var response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw HttpException('Could not delete product');
    }
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
    // catchError((error) {
    //   throw error;
    // });
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.parse('$dataUrl/products/$id.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imagUrl': newProduct.imageUrl,
            'creator': userId,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }
}
