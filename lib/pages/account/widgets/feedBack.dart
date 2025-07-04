import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_store/models/feedBack.dart';
import 'package:phone_store/pages/profile/phone_profile.dart';
import 'package:phone_store/provider/order_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; 

class FeedBackPage extends StatefulWidget {
  const FeedBackPage({super.key});
  static const routeName = "/feedBackPage";
  @override
  State<FeedBackPage> createState() => _FeedBackPageState();
}

class _FeedBackPageState extends State<FeedBackPage> {
  Map<String, TextEditingController> feedbackControllers = {};
  Map<String, int> votes = {};
  String userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void dispose() {
    for (var controller in feedbackControllers.values) {
      controller.dispose(); // tránh leak bộ nhớ
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments as Map;
    final order = data['order'];
    final productList = data['product'];
    for (var item in order.orderProduct) {
      final product = productList.firstWhere((p) => p.id == item.id);
      votes.putIfAbsent(product.id, () => 5);
      feedbackControllers.putIfAbsent(
          product.id, () => TextEditingController());
    }
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Đánh giá sản phẩm"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...order.orderProduct.map(
              (item) {
                final product = productList.firstWhere((p) => p.id == item.id);
                final List<ValueNotifier<bool>> isTrue =
                    List.generate(5, (_) => ValueNotifier<bool>(true));

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, PhoneProfilePage.routeName,
                        arguments: {
                          "id": product.id,
                        });
                  },
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.network(
                                product.phoneImage,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 10),
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
                          ],
                        ),
                        Divider(
                          color: const Color.fromARGB(255, 222, 222, 222),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Đánh giá sản phẩm",
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            ...List.generate(
                              5,
                              (index) => ValueListenableBuilder(
                                valueListenable: isTrue[index],
                                builder: (context, value, child) =>
                                    GestureDetector(
                                  onTap: () {
                                    for (int i = 0; i < isTrue.length; i++) {
                                      if (i <= index) {
                                        isTrue[i].value = true;
                                      } else {
                                        isTrue[i].value = false;
                                      }
                                    }
                                    votes[product.id] = index + 1;
                                  },
                                  child: Icon(
                                    Icons.star_rate_rounded,
                                    color: isTrue[index].value
                                        ? Colors.amber
                                        : const Color.fromARGB(255, 95, 95, 95),
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 100,
                          child: TextField(
                            controller: feedbackControllers[product.id],
                            maxLength: 50,
                            maxLines: 4,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText:
                                  "Hãy chia sẻ nhận xét cho sản phẩm này bạn nhé!",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: ElevatedButton(
        onPressed: () {
          votes.forEach((productId, rating) {
            final feedbackText = feedbackControllers[productId]?.text ?? '';
            final feedB = FeedBackModal(
                id: Uuid().v4(),
                userId: userId,
                vote: rating,
                feedBackText: feedbackText,
                time: Timestamp.now());
            Provider.of<OrderProvider>(context, listen: false)
                .feedBackOrder(productId, feedB);
          });
          Provider.of<OrderProvider>(context, listen: false)
              .updateOrder(order.id, 'Đánh giá');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Phản hồi đã được gửi!")),
          );
          Future.delayed(Duration(seconds: 2000));
          Navigator.pop(context);
        },
        child: const Text("Gửi Phản Hồi"),
      ),
    );
  }
}
