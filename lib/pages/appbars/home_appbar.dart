import 'package:flutter/material.dart';
import 'package:phone_store/pages/shopping_page/shopping_page.dart';

class AppBarHome extends StatefulWidget {
  const AppBarHome({super.key});

  @override
  State<AppBarHome> createState() => _AppBarHomeState();
}

class _AppBarHomeState extends State<AppBarHome> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              alignment: Alignment.center,
              height: 34,
              width: 90,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                color: const Color(0xffEF6A62),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_open_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Menu',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          const Text(
            'ZendVN',
            style: TextStyle(
              fontSize: 34,
              color: Color(0xffEF6A62),
              fontFamily: 'Sniglet',
            ),
          ),
          GestureDetector(
            onTap: () {
            Navigator.pushNamed(context, ShoppingPage.routeName);
            },
            child: Image.asset('assets/img/shopping-cart.png'),
          ),
        ],
      ),
    );
  }
}
