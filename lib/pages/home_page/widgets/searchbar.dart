import 'package:flutter/material.dart';
import 'package:phone_store/pages/search/search_page.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SearchPage()),
        );
      },
      child: Hero(
        tag: 'search-bar',
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 45,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: const Color.fromARGB(255, 207, 207, 207),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.search,
                    size: 20,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    'Tìm kiếm',
                    style:
                        TextStyle(color: const Color.fromARGB(255, 82, 82, 82)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
