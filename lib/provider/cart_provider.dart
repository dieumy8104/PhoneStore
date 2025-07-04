import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_store/models/cart.dart';
import 'package:phone_store/models/products.dart';

class CartProvider extends ChangeNotifier {
  String userId = FirebaseAuth.instance.currentUser!.uid;

// USER CART
  List<Cart> _cart = [];
  List<Cart> get cart => [..._cart]; 
  Map<String, bool> _selectedItems = {};
  Map<String, bool> get selectedItems => {..._selectedItems};
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  List<Product> _items = [];
  List<Product> get items => [..._items];
  CartProvider() {
    loadCart();
  }

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    _cart = await getCartList();
    print("Giỏ hàng đã load: ${_cart.length}");

    getProducts().listen((products) {
      _items = products;
      notifyListeners();
      print("Đã cập nhật danh sách sản phẩm: ${_items.length}");
    });

    notifyListeners();
  }

  Stream<List<Product>> getProducts() {
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

  Future<List<Cart>> getCartList() async {
    final userCartRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    final docSnapshot = await userCartRef.get();

    if (docSnapshot.exists) {
      List<dynamic> cartData = docSnapshot.data()?['cart'] ?? [];
      _cart = cartData
          .map((item) => Cart.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return _cart;
  }

//ADD TO CART
  void addCart(String id, int quantity ) {
    Cart? cartItem = _cart.firstWhereOrNull((item) {
      return item.id == id;
    });

    if (cartItem != null) {
      cartItem.quantity += quantity;
    } else {
      Cart cartFirebase = Cart(
        id: id,
        quantity: quantity,
      );
      _cart.add(cartFirebase);
    }
    _uploadCartToFirebase(_cart);
    notifyListeners();
  }

// REMOVE FROM CART
  void decreaseFromCart(String productId) {
    Cart product = _cart.firstWhere((item) => item.id == productId);

    product.quantity -= 1;
    _uploadCartToFirebase(_cart);
    notifyListeners();
  }

  void increaseFromCart(String productId) {
    Cart? product = _cart.firstWhereOrNull((item) => item.id == productId);

    if (product != null) {
      product.quantity += 1;
      _uploadCartToFirebase(_cart);
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String id) async {
    _cart.removeWhere((item) => item.id == id);
    _uploadCartToFirebase(_cart);
    notifyListeners();
  }

//GET TOTAL NUMBER OF ITEMS IN CART
  double getTotalItemCount() {
    double totalItemCount = 0;
    for (Cart cartItem in _cart) {
      String productId = cartItem.id;
      final product = _items.firstWhere((p) => p.id == productId);
      if (_selectedItems[productId] == true) {
        totalItemCount += (product.phonePrice -
                ((product.phonePrice * product.phoneDiscount) / 100)) *
            cartItem.quantity;
      }
    }
    return totalItemCount.roundToDouble();
  }

//CLEAR CART

  Future<void> deleteProductById() async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userRef.get();
    final userCartRef =
        List<Map<String, dynamic>>.from(snapshot.data()?['cart'] ?? []);
    userCartRef.where((item) {
      final id = item['id'];
      return _selectedItems[id] == true;
    }).toList();

    _cart.removeWhere((item) => _selectedItems[item.id] == true);
    _uploadCartToFirebase(_cart);
    notifyListeners();
  }
Future<void> deleteProductWhenBuy(List<Cart> buyItem) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userRef.get();

    // Lấy danh sách cart hiện tại từ Firestore
    final userCartRef =
        List<Map<String, dynamic>>.from(snapshot.data()?['cart'] ?? []);

    // Lọc lại: chỉ giữ lại những item KHÔNG nằm trong danh sách đã mua
    final updatedCart = userCartRef.where((item) {
      final id = item['id'];
      return !buyItem.any((b) => b.id == id);
    }).toList();

    // Cập nhật giỏ hàng mới lên Firestore
    await userRef.update({'cart': updatedCart});

    // Xóa trong local _cart
    _cart.removeWhere((item) => buyItem.any((b) => b.id == item.id));

    // Upload lại local _cart lên Firebase nếu cần (có thể bỏ nếu đã update ở trên rồi)
    _uploadCartToFirebase(_cart);

    notifyListeners();
  }

//CHECKBOX
  void toggleSelection(String id) {
    _selectedItems[id] = !(_selectedItems[id] ?? false);
    notifyListeners();
  }

  String getTotalSelection() {
    int count = 0;
    for (Cart cartItem in _cart) {
      if (_selectedItems[cartItem.id] == true) {
        count++;
      }
    }

    return count.toString();
  }

//UP TO FiREBASE
  Future<void> _uploadCartToFirebase(List<Cart> carts) async {
    List<Map<String, dynamic>> cartData =
        _cart.map((cartItem) => cartItem.toMap()).toList();

    await FirebaseFirestore.instance.collection('users').doc(userId).set(
      {
        'cart': cartData,
      },
      SetOptions(merge: true),
    );
  }
}
