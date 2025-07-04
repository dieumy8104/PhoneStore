import 'package:flutter/material.dart';
import 'package:phone_store/models/cart.dart';

class UserOrder extends ChangeNotifier {
  String id;
  String userId;
  String nameUser;
  List<Cart> orderProduct;
  String orderStatus;
  String userDate;
  String userPhone;
  String userAddress;
  String methodPayment;
  double totalPrice;
  UserOrder({
    required this.id,
    required this.nameUser,
    required this.userId,
    required this.orderProduct,
    required this.orderStatus,
    required this.userDate,
    required this.userPhone,
    required this.userAddress,
    required this.totalPrice,
    required this.methodPayment,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id, 
      'nameUser': nameUser,
      'userId': userId,
      'orderProduct': orderProduct.map((e) => e.toMap()).toList(),
      'orderStatus': orderStatus,
      'userDate': userDate,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'totalPrice': totalPrice,
      'methodPayment': methodPayment,
    };
  }

  factory UserOrder.fromMap(Map<String, dynamic> map) {
    return UserOrder(
      id: map['id'] as String,
      nameUser: map['nameUser'] as String,
      userId: map['userId'] as String,
      orderProduct: (map['orderProduct'] as List)
          .map((item) => Cart.fromMap(item as Map<String, dynamic>))
          .toList(),
      orderStatus: map['orderStatus'] as String,
      userDate: map['userDate'] as String,
      userPhone: map['userPhone'] as String,
      userAddress: map['userAddress'] as String,
      totalPrice: map['totalPrice'] is double
          ? map['totalPrice'] as double
          : (map['totalPrice'] as num).toDouble(),
      methodPayment: map['methodPayment'] as String,
    );
  }
}
