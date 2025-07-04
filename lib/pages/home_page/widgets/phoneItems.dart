import 'package:flutter/material.dart';
import 'package:phone_store/pages/categoryItem/category.dart';
import 'package:phone_store/provider/category_provider.dart';
import 'package:provider/provider.dart';

class PhoneItemsWidget extends StatelessWidget {
  PhoneItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return SizedBox(
      height: size.width / 3,
      child: StreamBuilder(
        stream: Provider.of<CategoryProvider>(context, listen: false)
            .streamCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No categories available',
                style: TextStyle(color: Colors.red));
          } else {
            final categoryItem = snapshot.data!;
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Danh mục sản phẩm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Tất cả ( ${categoryItem.length} )',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xff939394),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryItem.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            CategoryPage.routeName,
                            arguments: {
                              "categoryId": categoryItem[index].id,
                              "categoryName": categoryItem[index].categoryName,
                            },
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              width: size.width / 7.5,
                              height: size.width / 6,
                              margin: index != categoryItem.length - 1
                                  ? const EdgeInsets.only(right: 10)
                                  : const EdgeInsets.only(right: 0),
                              child: Expanded(
                                child: Container(
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      categoryItem[index].categoryImage,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              categoryItem[index].categoryName,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
