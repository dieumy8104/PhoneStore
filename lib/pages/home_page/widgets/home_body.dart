import 'package:flutter/material.dart';
import 'package:phone_store/pages/home_page/widgets/bestSellerItem.dart';
import 'package:phone_store/pages/home_page/widgets/big_carousel.dart';
import 'package:phone_store/pages/home_page/widgets/phoneItems.dart';
import 'package:phone_store/pages/home_page/widgets/searchbar.dart';

class HomeBody extends StatelessWidget {
  static const routeName = '/homeBody';
  HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SearchBarWidget(),
            BigCarouselWidget(),
            PhoneItemsWidget(),
            BestSellerItem(),
          ],
        ),
      ),
    );
  }
}
