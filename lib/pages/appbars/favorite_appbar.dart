import 'package:flutter/material.dart'; 

class FavoriteAppbar extends StatefulWidget {
  const FavoriteAppbar({super.key});

  @override
  State<FavoriteAppbar> createState() => _FavoriteAppbarState();
}

class _FavoriteAppbarState extends State<FavoriteAppbar> {
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
        'Yêu thích',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }
}
