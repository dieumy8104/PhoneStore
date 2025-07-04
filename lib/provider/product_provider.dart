import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart'; 
import 'package:phone_store/models/products.dart'; 

class ProductProvider extends ChangeNotifier {
  List<Product> _items = [];
  List<Product> get items => [..._items];
String userId = FirebaseAuth.instance.currentUser!.uid;
  Stream<List<Product>> streamAllProducts() {
    return FirebaseFirestore.instance.collection('products').snapshots().map(
      (snapshot) {
        final products = snapshot.docs
            .map((snapshot) {
              try {
                return Product.fromMap(snapshot.data());
              } catch (e) {
                print('Bỏ qua doc không hợp lệ: ${snapshot.id}');
              }
            })
            .whereType<Product>()
            .toList();
        _items.clear();
        _items.addAll(products);
        return products;
      },
    );
  }

  Stream<Product> streamProduct(String id) {
    return FirebaseFirestore.instance
        .collection('products')
        .doc(id)
        .snapshots()
        .map(
      (snapshot) {
        try {
          return Product.fromMap(snapshot.data() as Map<String, dynamic>);
        } catch (e) {
          debugPrint('Bỏ qua doc không hợp lệ: ${snapshot.id}');
          rethrow;
        }
      },
    );
  } 

  Stream<List<Product>> streamProductsByCategory(String categoryId) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs.map((doc) => Product.fromMap(doc.data())).toList();
      } catch (e) {
        debugPrint('Bỏ qua doc không hợp lệ: ${snapshot.docs}');
        rethrow;
      }
    });
  }

  Stream<List<Product>> relatedItem(String id, String categoryId) {
    return FirebaseFirestore.instance.collection('products').snapshots().map(
      (snapshot) {
        final products = snapshot.docs
            .map((doc) {
              try {
                final data = doc.data();
                if (data['id'] == null || data['categoryId'] == null)
                  return null;
                return Product.fromMap(data);
              } catch (e) {
                debugPrint('Bỏ qua doc không hợp lệ: ${doc.id}');
                return null;
              }
            })
            .whereType<Product>()
            .toList();

        return products
            .where((element) =>
                element.categoryId == categoryId && element.id != id)
            .toList();
      },
    );
  }

  List<Product> getList(String query) {
    if (query.isEmpty) return [];
    List<String> keywords = query.toLowerCase().split(" ");

    return _items.where((product) {
      String name = product.phoneName.toLowerCase();
      return keywords.every((word) => name.contains(word));
    }).toList();
  }
}
