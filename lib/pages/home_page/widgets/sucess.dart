import 'package:flutter/material.dart';

class CompleteOrder extends StatelessWidget {
  static const routeName = '/completeOrder';
  CompleteOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/homePage', (route) => false);
          },
        ),
        title: const Text(
          'Thanh toán',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 230, 77, 50),
      ),
      body: Center(
        child: Text(
          'Đơn hàng của bạn đã được đặt thành công!',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
