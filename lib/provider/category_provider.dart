import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phone_store/models/category.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<Category> get categories => [..._categories];
  // final List<Product> _productList = [];
  // List<Product> get productList => [..._productList];
  // bool _isLoading = true;
  // bool get isLoading => _isLoading;

  Stream<List<Category>> streamCategories() {
    return FirebaseFirestore.instance
        .collection('categories')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            try {
              return Category.fromMap(doc.data());
            } catch (e) {
              debugPrint('Bỏ qua doc không hợp lệ: ${doc.id}');
              return null;
            }
          })
          .whereType<Category>()
          .toList(); // Bỏ null
    });
  }

  Category getCategoryWithId(String categoryId) {
    return _categories.firstWhere((category) => category.id == categoryId);
  }
}
