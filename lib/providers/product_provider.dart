import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> allProducts = [];
  List<Product> visibleProducts = [];
  bool loading = false;
  int skip = 0;
  bool endReached = false;

  String searchText = '';
  String selectedCategory = txtCategoryAll;

  Future<void> fetchProducts({bool reset = false}) async {
    if (loading || endReached) return;

    loading = true;
    notifyListeners();

    if (reset) {
      skip = 0;
      endReached = false;
      allProducts.clear();
      visibleProducts.clear();
    }

    try {
      final url = '$baseUrl?limit=$pageLimit&skip=$skip';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List newProducts = data['products'];

        if (newProducts.isEmpty) {
          endReached = true;
        } else {
          final items = newProducts.map((e) => Product.fromJson(e)).toList();
          allProducts.addAll(items);
          skip += pageLimit;
        }
        applyFilters();
      }
    } catch (_) {}
    loading = false;
    notifyListeners();
  }

  void applyFilters() {
    List<Product> filtered = List.from(allProducts);

    if (searchText.isNotEmpty) {
      filtered = filtered
          .where((p) =>
      p.title.toLowerCase().contains(searchText.toLowerCase()) ||
          p.brand.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }

    if (selectedCategory != txtCategoryAll) {
      filtered = filtered
          .where((p) =>
      p.category.toLowerCase() ==
          selectedCategory.toLowerCase())
          .toList();
    }

    visibleProducts = filtered;
    notifyListeners();
  }

  void updateSearch(String text) {
    searchText = text;
    applyFilters();
  }

  void changeCategory(String cat) {
    selectedCategory = cat;
    applyFilters();
    notifyListeners();

  }

  Future<Product?> fetchProduct(int id) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/$id'));
      if (res.statusCode == 200) {
        return Product.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }
}
