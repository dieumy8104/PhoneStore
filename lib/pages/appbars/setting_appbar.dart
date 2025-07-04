import 'package:flutter/material.dart';

class SettingAppbar extends StatefulWidget {
  const SettingAppbar({super.key});

  @override
  State<SettingAppbar> createState() => _SettingAppbarState();
}

class _SettingAppbarState extends State<SettingAppbar> {
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
        'Cài đặt',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }
}
