import 'package:flutter/material.dart';

class NotificationAppbar extends StatefulWidget {
  const NotificationAppbar({super.key});

  @override
  State<NotificationAppbar> createState() => _NotificationAppbarState();
}

class _NotificationAppbarState extends State<NotificationAppbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Text(
        'Thông báo',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }
}
