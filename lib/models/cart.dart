 

class Cart {
  String id;
  int quantity;

  Cart({
    required this.id,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quantity': quantity,
    };
  }

  factory Cart.fromMap(Map<String, dynamic> map) {
    return Cart(
      id: map['id'] as String,
      quantity: map['quantity'] as int,
    );
  } 
}
