import 'package:flutter/material.dart';
import 'package:phone_store/pages/shopping_page/shopping_page.dart';

class ProfileAppbar extends StatefulWidget {
  const ProfileAppbar({super.key});

  @override
  State<ProfileAppbar> createState() => _ProfileAppbarState();
}

class _ProfileAppbarState extends State<ProfileAppbar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                prefixIcon: Icon(
                  Icons.search,
                  size: 16,
                  color: Colors.black,
                ),
                hintText: 'Tìm kiếm',
                hintStyle: TextStyle(fontSize: 11),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, ShoppingPage.routeName);
            },
            icon: Icon(
              Icons.shopping_cart_outlined,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
