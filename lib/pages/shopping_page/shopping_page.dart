import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone_store/models/cart.dart';
import 'package:phone_store/models/products.dart';
import 'package:phone_store/pages/home_page/widgets/buyItem.dart';
import 'package:phone_store/provider/cart_provider.dart';
import 'package:phone_store/pages/profile/phone_profile.dart';
import 'package:provider/provider.dart';

class ShoppingPage extends StatefulWidget {
  ShoppingPage({super.key});
  static String routeName = "/shopping_page";
  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  @override
  bool hasShownSnackbar = false;
  void removeItemFromCart(String id) {
    context.read<CartProvider>().removeFromCart(id);
  }

  void _removeItem(BuildContext context, Cart cartItem) async {
    final provider = Provider.of<CartProvider>(context, listen: false);
    if (cartItem.quantity == 1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Delete Product'),
            content: const Text('Are you sure you want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  removeItemFromCart(cartItem.id);
                  Navigator.of(context).pop(true);
                },
                child: const Text("Delete"),
              ),
            ],
          );
        },
      );
    } else {
      provider.decreaseFromCart(cartItem.id);
    }
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: Provider.of<CartProvider>(context, listen: false).getCartList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (!snapshot.hasData) {
          return const Center(
            child: Text(
              'No products available',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else {
          List<Cart> carts = snapshot.data!;

          return StreamBuilder<List<Product>>(
            stream:
                Provider.of<CartProvider>(context, listen: false).getProducts(),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: Colors.white,
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (!snapshot.hasData) {
                return const Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              } else {
                List<Product> products = productSnapshot.data!;
                return Consumer<CartProvider>(
                  builder: (context, provider, child) {
                    return Scaffold(
                      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
                      appBar: PreferredSize(
                        preferredSize: Size.fromHeight(60),
                        child: AppBar(
                          backgroundColor: Colors.white,
                          leading: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Color(0xffb23f56),
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Giỏ hàng',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                '(${carts.length})',
                                style: TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                final selected = provider.selectedItems.values
                                    .where((item) => item == true)
                                    .toList();
                                if (selected.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Chưa có sản phẩm nào được chọn'),
                                    ),
                                  );
                                  return;
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: const Text('Delete Product'),
                                        content: const Text(
                                            'Are you sure you want to delete these item?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              provider.deleteProductById();
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      body: carts.isEmpty
                          ? Center(
                              child: Text(
                                'Chưa có sản phẩm nào được thêm vào giỏ hàng',
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListView.builder(
                                itemCount: carts.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var cartItem = carts[index];
                                  final product = products.firstWhere(
                                    (product) => product.id == cartItem.id,
                                  );

                                  return Dismissible(
                                    confirmDismiss: (direction) async {
                                      return await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.white,
                                            title: const Text('Delete Product'),
                                            content: const Text(
                                                'Are you sure to delete this item?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Text("Delete"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    key: Key(cartItem.id),
                                    onDismissed: (direction) {
                                      removeItemFromCart(cartItem.id);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('Complete!'),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 5),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            PhoneProfilePage.routeName,
                                            arguments: {
                                              "id": product.id,
                                            },
                                          );
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(10),
                                            ),
                                            color: Colors.white,
                                          ),
                                          width: size.width,
                                          child: Row(
                                            children: [
                                              Checkbox(
                                                value: provider.selectedItems[
                                                        cartItem.id] ??
                                                    false,
                                                onChanged: (bool? value) {
                                                  provider.toggleSelection(
                                                      cartItem.id);
                                                  provider.getTotalItemCount();
                                                },
                                                activeColor: Colors.blue,
                                                checkColor: Colors.white,
                                              ),
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  product.phoneImage,
                                                  height: size.width / 5,
                                                  width: size.width / 5,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: size.width,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        '${product.phoneName}',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${product.phoneDescription}',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '${NumberFormat("#,###", "en_US").format(
                                                                  product.phonePrice -
                                                                      ((product.phonePrice *
                                                                              product.phoneDiscount) /
                                                                          100),
                                                                )}đ',
                                                                style:
                                                                    TextStyle(
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          231,
                                                                          103,
                                                                          96),
                                                                  letterSpacing:
                                                                      0.38,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Text(
                                                                '${NumberFormat("#,###", "en_US").format(product.phonePrice)}đ',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .lineThrough,
                                                                  decorationColor:
                                                                      Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {},
                                                        child: Row(
                                                          children: [
                                                            Spacer(),
                                                            Container(
                                                              width: 68,
                                                              height: 18,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          3),
                                                                ),
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      _removeItem(
                                                                        context,
                                                                        cartItem,
                                                                      );
                                                                      provider
                                                                          .getTotalItemCount();
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .only(
                                                                        left: 3,
                                                                      ),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .remove,
                                                                        size:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  VerticalDivider(
                                                                    color: Colors
                                                                        .grey,
                                                                    thickness:
                                                                        1,
                                                                    width: 1,
                                                                  ),
                                                                  Text(
                                                                    '${cartItem.quantity}',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                    ),
                                                                  ),
                                                                  VerticalDivider(
                                                                    color: Colors
                                                                        .grey,
                                                                    thickness:
                                                                        1,
                                                                    width: 1,
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      if (product
                                                                              .phoneQuantity >
                                                                          cartItem
                                                                              .quantity) {
                                                                        provider
                                                                            .increaseFromCart(cartItem.id);
                                                                      } else {
                                                                        if (!hasShownSnackbar) {
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(
                                                                            SnackBar(
                                                                              content: Text('Số lượng sản phẩm đã đạt tối đa'),
                                                                            ),
                                                                          );
                                                                          hasShownSnackbar =
                                                                              true;
                                                                        }
                                                                      }

                                                                      provider
                                                                          .getTotalItemCount();
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .only(
                                                                        right:
                                                                            3,
                                                                      ),
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .add,
                                                                        size:
                                                                            10,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                      bottomNavigationBar: SizedBox(
                        height: 70,
                        child: BottomAppBar(
                          color: Color(0xfff8f8f8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Total: ${provider.getTotalSelection()}',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      Text(
                                        '${NumberFormat("#,###", "en_US").format(provider.getTotalItemCount())}đ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xffb23f56),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  final selectedIds = provider
                                      .selectedItems.entries
                                      .where((entry) => entry.value == true)
                                      .map((entry) => entry.key)
                                      .toList();

                                  final selectedCarts = carts
                                      .where((cart) =>
                                          selectedIds.contains(cart.id))
                                      .toList();

                                  final List<Cart> singleCart = selectedCarts;

                                  Navigator.pushNamed(
                                    context,
                                    BuyItem.routeName,
                                    arguments: {
                                      "product": singleCart,
                                      "price": provider.getTotalItemCount(),
                                    },
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xffb23f56),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Mua ngay',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        '(' +
                                            provider.getTotalSelection() +
                                            ')',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        }
      },
    );
  }
}
