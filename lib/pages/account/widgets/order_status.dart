import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:intl/intl.dart';
import 'package:phone_store/models/feedBack.dart';
import 'package:phone_store/models/order.dart';
import 'package:phone_store/models/products.dart';
import 'package:phone_store/provider/order_provider.dart';
import 'package:phone_store/provider/product_provider.dart';
import 'package:provider/provider.dart';

class OrderStatusPage extends StatefulWidget {
  const OrderStatusPage({super.key});
  static String routeName = '/order_status';
  @override
  State<OrderStatusPage> createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _initialTabIndex = 0;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 5, vsync: this, initialIndex: _initialTabIndex);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final args = ModalRoute.of(context)?.settings.arguments
            as Map<String, int>?; // Kiểm tra kiểu Map
        if (args != null && args.containsKey("index")) {
          final tabIndex = args["index"];
          if (tabIndex != null && tabIndex >= 0 && tabIndex < 5) {
            setState(() {
              _tabController.index = tabIndex; // Chuyển đến tab tương ứng
            });
          }
        }
      },
    );
  }
  Future<Map<String, List<FeedBackModal>>> getAllFeedback(
      List<String> productIds, BuildContext context) async {
    Map<String, List<FeedBackModal>> feedbackMap = {};

    for (var id in productIds) {
      final userDoc =
          await FirebaseFirestore.instance.collection('products').doc(id).get();
      if (userDoc.exists && userDoc.data()!.containsKey('feedBack')) {
        List<dynamic> existingProducts = List.from(userDoc.data()!['feedBack']);

        final filtered = existingProducts
            .where((item) => item['userId'] == userId)
            .map((item) => FeedBackModal.fromMap(item))
            .toList();

        feedbackMap[id] = filtered;
      }
    }

    return feedbackMap;
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 245, 245, 245),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(0, 255, 255, 255),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.keyboard_backspace,
              color: Color.fromRGBO(203, 89, 128, 1),
            ),
          ),
          title: Text(
            'Đơn hàng đã mua',
            style: TextStyle(
              color: Color.fromRGBO(203, 89, 128, 1),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(50),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(text: "Chờ giao hàng"),
                Tab(text: "Đang giao"),
                Tab(text: "Đã giao"),
                Tab(text: "Đánh giá"),
                Tab(text: "Đã hủy"),
              ],
            ),
          ),
        ),
        body: StreamBuilder(
          stream:
              Provider.of<OrderProvider>(context, listen: false).streamOrder(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: const CircularProgressIndicator());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No categories available',
                    style: TextStyle(color: Colors.red)),
              );
            } else {
              final data = snapshot.data!;

              final waitingPrepare = data
                  .where((order) => order.orderStatus == "Chờ giao hàng")
                  .toList();
              final waitingDelivery = data
                  .where((order) => order.orderStatus == "Đang giao hàng")
                  .toList();
              final completeOrder = data
                  .where((order) => order.orderStatus == "Đã giao")
                  .toList();
              final feedback = data
                  .where((order) => order.orderStatus == "Đánh giá")
                  .toList();
              final cancel =
                  data.where((order) => order.orderStatus == "Đã hủy").toList();
              return StreamBuilder(
                stream: Provider.of<ProductProvider>(context, listen: false)
                    .streamAllProducts(),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState ==
                          ConnectionState.waiting ||
                      !productSnapshot.hasData) {
                    return Center(child: const CircularProgressIndicator());
                  }

                  final products = productSnapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        waitingWidget(context, waitingPrepare, products),
                        deliverWidget(context, waitingDelivery, products),
                        completeWidget(context, completeOrder, products),
                        feedbackWidget(context, feedback, products),
                        cancelWidget(context, cancel, products),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget waitingWidget(
      BuildContext context, List<UserOrder> category, List<Product> products) {
    return category.isNotEmpty
        ? ListView.builder(
            itemCount: category.length,
            itemBuilder: (context, orderIndex) {
              final order = category[orderIndex];
              final ValueNotifier<bool> isExpanded = ValueNotifier(false);

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/orderDetail',
                    arguments: {
                      "order": order,
                      "product": products,
                    },
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isExpanded,
                    builder: (context, value, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...order.orderProduct.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            final product =
                                products.firstWhere((p) => p.id == item.id);

                            if (index > 0 && !value) return SizedBox.shrink();

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.network(
                                        product.phoneImage,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.phoneName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'x${item.quantity}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${NumberFormat("#,###", "en_US").format(product.phonePrice)}đ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                '${NumberFormat("#,###", "en_US").format(
                                                  product.phonePrice -
                                                      ((product.phonePrice *
                                                              product
                                                                  .phoneDiscount) /
                                                          100),
                                                )}đ',
                                                style: TextStyle(
                                                  color: Color(0xffEF6A62),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                )
                              ],
                            );
                          }).toList(),
                          if (order.orderProduct.length > 1)
                            TextButton(
                              onPressed: () {
                                isExpanded.value = !isExpanded.value;
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    value ? "Ẩn bớt" : "Xem thêm",
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey),
                                  ),
                                  Icon(
                                    value
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Tổng tiền: ${NumberFormat("#,###", "en_US").format(order.totalPrice)} đ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  Provider.of<OrderProvider>(context,
                                          listen: false)
                                      .updateOrder(order.id, 'Đã hủy');
                                  Navigator.pushNamed(
                                    context,
                                    '/cancelOrder',
                                  );
                                  Future.delayed(Duration(seconds: 2000));
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  side:
                                      BorderSide(color: Colors.grey, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8), // bo góc
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 11),
                                ),
                                child: Text('Hủy đơn',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400)),
                              ),
                              SizedBox(width: 10),
                              TextButton(
                                onPressed: () async {
                                  await FlutterPhoneDirectCaller.callNumber(
                                      "0852711187");
                                },
                                style: TextButton.styleFrom(
                                  side:
                                      BorderSide(color: Colors.grey, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 11),
                                ),
                                child: Text(
                                  'Liên hệ shop',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          )
        : Center(child: Text("Bạn chưa có bất kì đơn hàng nào!"));
  }

  Widget deliverWidget(
      BuildContext context, List<UserOrder> category, List<Product> products) {
    return category.isNotEmpty
        ? ListView.builder(
            itemCount: category.length,
            itemBuilder: (context, orderIndex) {
              final order = category[orderIndex];
              final ValueNotifier<bool> isExpanded = ValueNotifier(false);

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/orderDetail',
                    arguments: {
                      "order": order,
                      "product": products,
                    },
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isExpanded,
                    builder: (context, value, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...order.orderProduct.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            final product =
                                products.firstWhere((p) => p.id == item.id);

                            if (index > 0 && !value) return SizedBox.shrink();

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.network(
                                        product.phoneImage,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.phoneName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'x${item.quantity}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${NumberFormat("#,###", "en_US").format(product.phonePrice)}đ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                '${NumberFormat("#,###", "en_US").format(
                                                  product.phonePrice -
                                                      ((product.phonePrice *
                                                              product
                                                                  .phoneDiscount) /
                                                          100),
                                                )}đ',
                                                style: TextStyle(
                                                  color: Color(0xffEF6A62),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            );
                          }).toList(),
                          if (order.orderProduct.length > 1)
                            TextButton(
                              onPressed: () {
                                isExpanded.value = !isExpanded.value;
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    value ? "Ẩn bớt" : "Xem thêm",
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey),
                                  ),
                                  Icon(
                                    value
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Tổng tiền: ${NumberFormat("#,###", "en_US").format(order.totalPrice)} đ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  await FlutterPhoneDirectCaller.callNumber(
                                      "0852711187");
                                },
                                style: TextButton.styleFrom(
                                  side:
                                      BorderSide(color: Colors.grey, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8), // bo góc
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 11),
                                ),
                                child: Text('Liên hệ shop',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          )
        : Center(child: Text("Bạn chưa có bất kì đơn hàng nào!"));
  }

  Widget completeWidget(
      BuildContext context, List<UserOrder> category, List<Product> products) {
    return category.isNotEmpty
        ? ListView.builder(
            itemCount: category.length,
            itemBuilder: (context, orderIndex) {
              final order = category[orderIndex];
              final ValueNotifier<bool> isExpanded = ValueNotifier(false);

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/orderDetail',
                    arguments: {
                      "order": order,
                      "product": products,
                    },
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isExpanded,
                    builder: (context, value, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...order.orderProduct.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            final product =
                                products.firstWhere((p) => p.id == item.id);

                            // Hiện index = 0 luôn, còn lại thì chỉ hiện nếu isExpanded = true
                            if (index > 0 && !value) return SizedBox.shrink();

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.network(
                                        product.phoneImage,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.phoneName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'x${item.quantity}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${NumberFormat("#,###", "en_US").format(product.phonePrice)}đ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                '${NumberFormat("#,###", "en_US").format(
                                                  product.phonePrice -
                                                      ((product.phonePrice *
                                                              product
                                                                  .phoneDiscount) /
                                                          100),
                                                )}đ',
                                                style: TextStyle(
                                                  color: Color(0xffEF6A62),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                )
                              ],
                            );
                          }).toList(),
                          if (order.orderProduct.length > 1)
                            TextButton(
                              onPressed: () {
                                isExpanded.value = !isExpanded.value;
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    value ? "Ẩn bớt" : "Xem thêm",
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey),
                                  ),
                                  Icon(
                                    value
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Tổng tiền: ${NumberFormat("#,###", "en_US").format(order.totalPrice)} đ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/feedBackPage',
                                    arguments: {
                                      "order": order,
                                      "product": products,
                                    },
                                  );
                                },
                                style: TextButton.styleFrom(
                                  side:
                                      BorderSide(color: Colors.grey, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8), // bo góc
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 11),
                                ),
                                child: Text('Đánh giá',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400)),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              TextButton(
                                onPressed: () async {
                                  await FlutterPhoneDirectCaller.callNumber(
                                      "0852711187");
                                },
                                style: TextButton.styleFrom(
                                  side:
                                      BorderSide(color: Colors.grey, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8), // bo góc
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 11),
                                ),
                                child: Text('Liên hệ shop',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          )
        : Center(child: Text("Bạn chưa có bất kì đơn hàng nào!"));
  }

 Widget feedbackWidget(
      BuildContext context, List<UserOrder> category, List<Product> products) {
    if (category.isEmpty) {
      return const Center(child: Text("Bạn chưa có bất kỳ đơn hàng nào!"));
    }

    // Lấy danh sách sản phẩm duy nhất (unique)
    final uniqueProductIds = category
        .expand((order) => order.orderProduct.map((item) => item.id))
        .toSet();

    return FutureBuilder<Map<String, List<FeedBackModal>>>(
      future: getAllFeedback(uniqueProductIds.toList(), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final feedbackMap = snapshot.data ?? {};

        return ListView(
          children: uniqueProductIds.map((productId) {
            final product = products.firstWhere((p) => p.id == productId);
            final feedbackList = feedbackMap[productId] ?? [];

            if (feedbackList.isEmpty) return const SizedBox.shrink();

            return Column(
              children: feedbackList.map((feedBack) {
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.phoneImage,
                              width: 35,
                              height: 35,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              product.phoneName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: List.generate(
                          feedBack.vote,
                          (_) => const Icon(Icons.star,
                              color: Colors.amber, size: 16),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        feedBack.feedBackText,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      if (feedBack.reply != null && feedBack.reply!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text("Phản hồi: ${feedBack.reply!}",
                              style: const TextStyle(color: Colors.blue)),
                        ),
                    ],
                  ),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }


  Widget cancelWidget(
      BuildContext context, List<UserOrder> category, List<Product> products) {
    return category.isNotEmpty
        ? ListView.builder(
            itemCount: category.length,
            itemBuilder: (context, orderIndex) {
              final order = category[orderIndex];
              final ValueNotifier<bool> isExpanded = ValueNotifier(false);

              return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/orderDetail',
                    arguments: {
                      "order": order,
                      "product": products,
                    },
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isExpanded,
                    builder: (context, value, _) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...order.orderProduct.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            final product =
                                products.firstWhere((p) => p.id == item.id);

                            // Hiện index = 0 luôn, còn lại thì chỉ hiện nếu isExpanded = true
                            if (index > 0 && !value) return SizedBox.shrink();

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.network(
                                        product.phoneImage,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.phoneName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                'x${item.quantity}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${NumberFormat("#,###", "en_US").format(product.phonePrice)}đ',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Text(
                                                '${NumberFormat("#,###", "en_US").format(
                                                  product.phonePrice -
                                                      ((product.phonePrice *
                                                              product
                                                                  .phoneDiscount) /
                                                          100),
                                                )}đ',
                                                style: TextStyle(
                                                  color: Color(0xffEF6A62),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                )
                              ],
                            );
                          }).toList(),
                          if (order.orderProduct.length > 1)
                            TextButton(
                              onPressed: () {
                                isExpanded.value = !isExpanded.value;
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    value ? "Ẩn bớt" : "Xem thêm",
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey),
                                  ),
                                  Icon(
                                    value
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 12,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Tổng tiền: ${NumberFormat("#,###", "en_US").format(order.totalPrice)} đ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () async {},
                                style: TextButton.styleFrom(
                                  side:
                                      BorderSide(color: Colors.grey, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(8), // bo góc
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 11),
                                ),
                                child: Text('Mua lại',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w400)),
                              )
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              );
            },
          )
        : Center(child: Text("Bạn chưa có bất kì đơn hàng nào!"));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
