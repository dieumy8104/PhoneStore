import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone_store/pages/profile/phone_profile.dart';
import 'package:phone_store/provider/product_provider.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatefulWidget {
  SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> productItem = [];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var product = Provider.of<ProductProvider>(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: AppBar(
            leadingWidth: size.width,
            leading: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xffb23f56),
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Hero(
                    tag: 'search-bar',
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        height: 45,
                        color: Colors.white,
                        child: TextFormField(
                          autofocus: true,
                          controller: _searchController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(10),
                            suffixIcon: Container(
                              child: IconButton(
                                icon: Icon(
                                  Icons.search,
                                  size: 20,
                                  color:
                                      const Color.fromARGB(255, 235, 235, 235),
                                ),
                                onPressed: () {
                                  setState(() {
                                    productItem =
                                        product.getList(_searchController.text);
                                  });
                                },
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xffb23f56),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(
                                    11,
                                  ),
                                  bottomRight: Radius.circular(
                                    11,
                                  ),
                                ),
                                border: Border.all(
                                  width: 1,
                                ),
                              ),
                            ),
                            hintText: 'Nhập từ khóa...',
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 1,
                                color: Color(0xffb23f56),
                              ),
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: productItem.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(10),
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 5,
                  childAspectRatio: 0.85,
                ),
                itemCount: productItem.length,
                itemBuilder: (BuildContext context, int index) {
                  final searchItem = productItem[index];
                  return GestureDetector(
                    onTap: (() {
                      Navigator.pushNamed(context, PhoneProfilePage.routeName,
                          arguments: {
                            "id": searchItem.id,
                          });
                    }),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Color.fromRGBO(225, 225, 225, 1),
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        color: Colors.white,
                      ),
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              child: Image.network(
                                searchItem.phoneImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${searchItem.phoneName}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${searchItem.phoneDescription}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      height: 1.5,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (index) => const Icon(
                                        Icons.star,
                                        color: Color(0xffFFD25D),
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${NumberFormat("#,###", "en_US").format(
                                              searchItem.phonePrice -
                                                  ((searchItem.phonePrice *
                                                          searchItem.phoneDiscount) /
                                                      100),
                                            )}đ',
                                            style: TextStyle(
                                              color: Color(0xffEF6A62),
                                              letterSpacing: 0.38,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            '${NumberFormat("#,###", "en_US").format(searchItem.phonePrice)}đ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                'Không có sản phẩm nào!',
              ),
            ),
    );
  }
}
