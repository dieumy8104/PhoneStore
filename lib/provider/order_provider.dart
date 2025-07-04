import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_store/models/feedBack.dart';
import 'package:phone_store/models/order.dart';
import 'package:phone_store/models/products.dart';

class OrderProvider extends ChangeNotifier {
  List<UserOrder> _orders = [];
  List<UserOrder> get orders => [..._orders];
  List<Product> _items = [];
  List<Product> get items => [..._items];
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  List<Product> _products = [];
  List<Product> get products => [..._products];
  String userId = FirebaseAuth.instance.currentUser!.uid;
  OrderProvider() {
    loadOrder();
  }

  Future<void> loadOrder() async {
    _isLoading = true;
    notifyListeners();
    _orders = await getUserOrders();
    notifyListeners();
  }

  Stream<List<UserOrder>> streamOrder() {
    return FirebaseFirestore.instance
        .collection('orders')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      final orderList = (snapshot.data()?['orderUser'] ?? []) as List<dynamic>;
      return orderList
          .map((orderData) {
            try {
              return UserOrder.fromMap(orderData as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Bỏ qua order không hợp lệ');
              return null;
            }
          })
          .whereType<UserOrder>()
          .toList();
    });
  }

  

  Future<void> updateOrder(String orderId, String status) async {
    final userRef = FirebaseFirestore.instance.collection('orders').doc(userId);
    final userDoc = await userRef.get();

    if (userDoc.exists && userDoc.data()!.containsKey('orderUser')) {
      List<dynamic> existingOrders = List.from(userDoc.data()!['orderUser']);

      for (int i = 0; i < existingOrders.length; i++) {
        if (existingOrders[i]['id'] == orderId) {
          // Cập nhật trường "orderstatus"
          existingOrders[i]['orderStatus'] = status;
          break;
        }
      }

      await userRef.set({'orderUser': existingOrders}, SetOptions(merge: true));
    }
  }

  Future<void> feedBackOrder(
      String productId, FeedBackModal feedBack) async {
    final userRef =
        FirebaseFirestore.instance.collection('products').doc(productId);
    final userDoc = await userRef.get();
    List<dynamic> existingOrders = [];
    if (userDoc.exists && userDoc.data()!.containsKey('feedBack')) {
      existingOrders = userDoc.data()!['feedBack'];
    }

    existingOrders.add(feedBack.toMap());

    await userRef.set({'feedBack': existingOrders}, SetOptions(merge: true));
  }

  Future<void> uploadOrderToFirebase(UserOrder orderItem) async {
    final docRef = FirebaseFirestore.instance.collection('orders').doc(userId);

    try {
      final docSnapshot = await docRef.get();

      List<dynamic> existingOrders = [];

      if (docSnapshot.exists && docSnapshot.data()!.containsKey('orderUser')) {
        existingOrders = docSnapshot.data()!['orderUser'];
      }

      existingOrders.add(orderItem.toMap());

      await docRef.set({
        'orderUser': existingOrders,
      });

      _orders.add(orderItem);

      // Optional: Update local state

      notifyListeners();
    } catch (e) {
      print('Error uploading order: $e');
    }
  }

  Future<void> uploadOrdersToFirebase(List<UserOrder> orderItem) async {
    final docRef = FirebaseFirestore.instance.collection('orders').doc(userId);

    try {
      final docSnapshot = await docRef.get();

      List<dynamic> existingOrders = [];

      if (docSnapshot.exists && docSnapshot.data()!.containsKey('orderUser')) {
        existingOrders = docSnapshot.data()!['orderUser'];
      }
      for (var item in orderItem) {
        existingOrders.add(item.toMap());
      }

      await docRef.set({
        'orderUser': existingOrders,
      });

      // Optional: Update local state
      for (var orderItem in orderItem) {
        _orders.add(orderItem);
      }

      notifyListeners();
    } catch (e) {
      print('Error uploading order: $e');
    }
  }

  Future<List<UserOrder>> getUserOrders() async {
    try {
      final orderDocs =
          FirebaseFirestore.instance.collection('orders').doc(userId);
      final userDoc = await orderDocs.get();
      if (!userDoc.exists) {
        print("User data not found!");
        return _orders;
      }
      List<dynamic> orderData = userDoc.data()?['orderUser'] ?? [];
      _orders = orderData
          .map((item) => UserOrder.fromMap(item as Map<String, dynamic>))
          .toList();
      return _orders;
    } catch (e) {
      print("Error loading user data: $e");
      return _orders;
    }
  }
}
