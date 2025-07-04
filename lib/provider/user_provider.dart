import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_store/models/cart.dart';
import 'package:phone_store/models/user.dart';

class UserProvider extends ChangeNotifier {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  UserApp? _user;
  UserApp? get user => _user;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  UserProvider() {
    loadInfo();
  }

  Future<void> loadInfo() async {
    _isLoading = true;
    notifyListeners();

    await _getUserInfo();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _getUserInfo() async {
    try {
      final userCartRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userDoc = await userCartRef.get();

      if (!userDoc.exists) {
        print("User data not found!");
        return;
      }

      _user = UserApp(
        id: userDoc.data()?['id'] ?? '',
        userImage: userDoc.data()?['userImage'] ?? '',
        userEmail: userDoc.data()?['userEmail'] ?? '',
        userName: userDoc.data()?['userName'] ?? '',
        userGender: userDoc.data()?['userGender'] ?? '',
        userDate: userDoc.data()?['userDate'] ?? '',
        userPhone: userDoc.data()?['userPhone'] ?? '',
        userAddress: userDoc.data()?['userAddress'] ?? '',
        favorite: userDoc.data()?['favoriteList'] != null
            ? (userDoc.data()?['favoriteList'] as List)
                .map((e) => e as String)
                .toList()
            : [],
        cart: userDoc.data()?['cartList'] != null
            ? (userDoc.data()?['cartList'] as List)
                .map((e) => Cart.fromMap(e as Map<String, dynamic>))
                .toList()
            : [],
      );

      notifyListeners();
    } catch (e) {
      print("Error loading user data: $e");
    }
  }
}
