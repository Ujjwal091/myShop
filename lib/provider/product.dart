import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:myshop/constants.dart';
import 'package:myshop/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String description;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final url =
        Uri.parse('$dataUrl/userFavorites/$userId/$id.json?auth=$authToken');
    try {
      var response = await http.put(
        url,
        body: json.encode(
          !isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        throw HttpException('something went wrong');
      }
      isFavorite = !isFavorite;
    } catch (error) {
      rethrow;
    }

    notifyListeners();
  }
}
