import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  static String routeName = '/setting_page';
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isOn = false;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Switch(
        value: isOn,
        onChanged: (value) {
          setState(() {
            isOn = value;
          });
        },
      ),
    );
  }
}
