import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone_store/pages/profile/phone_profile.dart';

class DetailOrder extends StatefulWidget {
  const DetailOrder({super.key});
  static String routeName = '/orderDetail';
  @override
  State<DetailOrder> createState() => _DetailOrderState();
}

class _DetailOrderState extends State<DetailOrder> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final data = ModalRoute.of(context)!.settings.arguments as Map; 
    final order = data['order'];
    Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            color: Color.fromRGBO(203, 89, 128, 1),
          ),
        ),
        title: const Text(
          'Thông tin đơn hàng',
          style: TextStyle(
            color: Color.fromRGBO(203, 89, 128, 1),
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin vận chuyển',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                color: Colors.grey),
                            SizedBox(width: 10),
                            Text(
                              'Nhanh',
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Divider(
                    color: const Color.fromARGB(255, 233, 233, 233),
                    thickness: 1,
                  ),
                  FutureBuilder(
                    future: getUserDetails(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.hasData) {
                        Map<String, dynamic>? user = snapshot.data!.data();
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Địa chỉ nhận hàng',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              color: Colors.grey),
                                          SizedBox(width: 10),
                                          Text(
                                            user?['address'] ?? 'Chưa cập nhật',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(Icons.phone, color: Colors.grey),
                                          SizedBox(width: 10),
                                          Text(
                                            user?['userPhone'] ??
                                                'Chưa cập nhật',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/changeOrderInfo',
                                          arguments: {
                                            "user": user,
                                          });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Text(
                                        'Cập nhật',
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text('No data found'),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  ...order.orderProduct.map(
                    (item) {
                      final product =
                          data['product'].firstWhere((p) => p.id == item.id);
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, PhoneProfilePage.routeName,
                              arguments: {
                                "id": product.id,
                              });
                        },
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                  child: SizedBox(
                                    height: 65,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              product.phoneName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                height: 1.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                              alignment: Alignment.topRight,
                                              child: Text(
                                                'x${order.orderProduct.first.quantity}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  height: 1.0,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${NumberFormat("#,###", "en_US").format(product.phonePrice)}đ',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                                decoration:
                                                    TextDecoration.lineThrough,
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
                                                letterSpacing: 0.38,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  ),
                  Divider(
                    color: const Color.fromARGB(255, 233, 233, 233),
                    thickness: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Thành tiền: ',
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        '${NumberFormat("#,###", "en_US").format(order.totalPrice)}đ',
                        style: TextStyle(
                          letterSpacing: 0.38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bạn cần hỗ trợ?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.message, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          'Liên hệ Shop',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    Divider(
                      color: const Color.fromARGB(255, 233, 233, 233),
                      thickness: 1,
                    ),
                    Row(
                      children: [
                        Icon(Icons.help_outline, color: Colors.grey),
                        SizedBox(width: 10),
                        Text(
                          'Trung tâm hỗ trợ',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
