import 'package:flutter/material.dart';
import 'package:phone_store/pages/favorite/widget/favoriteItem.dart';
import 'package:phone_store/provider/favorite_provider.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    var favoriteProvider = Provider.of<FavoriteProvider>(context);
    var favoriteItem = favoriteProvider.favorite;
    if (favoriteItem.isEmpty) {
      return Center(
        child: Text(
          'Chưa có sản phẩm nào được yêu thích!',
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 5,
          childAspectRatio: 0.7,
        ),
        itemCount: favoriteItem.length,
        itemBuilder: (BuildContext context, int index) {
          return Dismissible(
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Delete Product'),
                    content: const Text('Are you sure to delete this item?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
            key: ValueKey<String>(favoriteItem[index]),
            onDismissed: (direction) {
              setState(() {
                favoriteProvider.handleRemove(favoriteItem[index]);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Complete!'),
                ),
              );
            },
            child: FavoriteItem(id: favoriteItem[index]),
          );
        },
      ),
    );
  }
}
