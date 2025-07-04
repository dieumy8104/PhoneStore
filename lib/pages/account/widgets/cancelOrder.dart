import 'package:flutter/material.dart';

class CancelOrderPage extends StatelessWidget {
  const CancelOrderPage({super.key});
  static String routeName = '/cancelOrder';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.keyboard_backspace,
            color: Color.fromRGBO(203, 89, 128, 1),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Icon(
              Icons.done_outline_rounded,
              size: 90,
              color: Color.fromRGBO(203, 89, 128, 1),
            ),
            Text('Hủy đơn thành công')
          ],
        ),
      ),
    );
  }
}
