import 'package:flutter/material.dart';
import 'package:phone_store/models/cart.dart';

class UserApp extends ChangeNotifier {
  String id;
  String userEmail;
  String userImage;
  String userName;
  String userGender;
  String userDate;
  String userPhone;
  String userAddress;
  List<String> favorite = [];
  List<Cart> cart = [];

  UserApp({
    required this.id,
    required this.userImage,
    required this.userEmail,
    required this.userName,
    required this.userGender,
    required this.userDate,
    required this.favorite,
    required this.cart,
    required this.userPhone,
    required this.userAddress,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userEmail': userEmail,
      'userImage': userImage,
      'userName': userName,
      'userGender': userGender,
      'userDate': userDate,
      'favorite': favorite,
      'cart': cart,
      'userPhone': userPhone,
      'userAddress': userAddress,
    };
  }

  factory UserApp.fromMap(Map<String, dynamic> map) {
    return UserApp(
      id: map['id'] as String,
      userEmail: map['userEmail'] as String,
      userImage: map['userImage'] as String,
      userName: map['userName'] as String,
      userGender: map['userGender'] as String,
      userDate: map['userDate'] as String,
      favorite: (map['favorite'] as List).map((e) => e as String).toList(),
      userPhone: map['userPhone'] as String,
      userAddress: map['userAddress'] as String,
      cart: (map['cart'] as List)
          .map((e) => Cart.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
