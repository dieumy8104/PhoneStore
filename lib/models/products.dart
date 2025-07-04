import 'package:flutter/material.dart';
import 'package:phone_store/models/feedBack.dart';

class Product extends ChangeNotifier {
  String id;
  String categoryId;
  String phoneImage;
  String phoneName;
  double phonePrice;
  int phoneQuantity;
  double phoneDiscount;
  String phoneDescription;
  List<FeedBackModal> feedBack;
  Product({
    required this.id,
    required this.categoryId,
    required this.phoneImage,
    required this.phoneName,
    required this.phonePrice,
    required this.phoneDiscount,
    required this.phoneQuantity,
    required this.phoneDescription,
    required this.feedBack,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'phoneImage': phoneImage,
      'phoneName': phoneName,
      'phonePrice': phonePrice,
      'phoneDiscount': phoneDiscount,
      'phoneQuantity': phoneQuantity,
      'phoneDescription': phoneDescription,
      'feedBack': feedBack,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      phoneImage: map['phoneImage'] as String,
      phoneName: map['phoneName'] as String,
      phonePrice: (map['phonePrice'] as num).toDouble(),
      phoneDiscount: (map['phoneDiscount'] as num).toDouble(),
      phoneQuantity: map['phoneQuantity'] as int,
      phoneDescription: map['phoneDescription'] as String,
      feedBack: (map['feedBack'] as List)
          .map((e) => FeedBackModal.fromMap(e as Map<String, dynamic>))
          .toList()??[],
    );
  }
}
