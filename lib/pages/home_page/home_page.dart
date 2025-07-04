import 'package:flutter/material.dart';
import 'package:phone_store/pages/appbars/favorite_appbar.dart';
import 'package:phone_store/pages/appbars/setting_appbar.dart';
import 'package:phone_store/pages/appbars/notification_appbar.dart';
import 'package:phone_store/pages/favorite/favorite.dart';
import 'package:phone_store/pages/appbars/home_appbar.dart';
import 'package:phone_store/pages/home_page/widgets/hamburger_menu.dart';
import 'package:phone_store/pages/home_page/widgets/home_body.dart';
import 'package:phone_store/pages/setting/setting_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/homePage';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

List<Widget> screens = [
  HomeBody(),
  NotificationAppbar(),
  FavoritePage(),
  SettingPage(),
];

List<Widget> appbars = [
  AppBarHome(),
  NotificationAppbar(),
  FavoriteAppbar(),
  SettingAppbar(),
];

class _HomePageState extends State<HomePage> {
  String route = '/';

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: HamburgerBar(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: IndexedStack(
          index: _currentPage,
          children: appbars,
        ),
      ),
      body: IndexedStack(
        index: _currentPage,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) {
          setState(() {
            _currentPage = value;
          });
        },
        height: 60,
        elevation: 5,
        indicatorColor: const Color.fromARGB(161, 159, 203, 238),
        selectedIndex: _currentPage,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: const Color.fromARGB(255, 165, 165, 165),
            ),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.notifications,
              color: const Color.fromARGB(255, 128, 128, 128),
            ),
            label: 'Thông báo',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.favorite,
              color: const Color.fromARGB(255, 128, 128, 128),
            ),
            label: 'Yêu thích',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.settings,
              color: const Color.fromARGB(255, 128, 128, 128),
            ),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}
