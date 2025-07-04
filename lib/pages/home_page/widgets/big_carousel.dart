import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';

class BigCarouselWidget extends StatefulWidget {
  BigCarouselWidget({super.key});

  @override
  State<BigCarouselWidget> createState() => _BigCarouselWidgetState();
}

class Carousel {
  String carouselPhone;
  String carouselImage;
  Carousel({
    required this.carouselPhone,
    required this.carouselImage,
  });
}

List<Carousel> carouselProduct = [
  Carousel(
    carouselImage: 'assets/img/elegant_design.png',
    carouselPhone: 'Thiết kế linh hoạt',
  ),
  Carousel(
    carouselImage: 'assets/img/elegant_design.png',
    carouselPhone: 'Thiết kế mỏng nhẹ',
  ),
  Carousel(
    carouselImage: 'assets/img/elegant_design.png',
    carouselPhone: 'Thiết kế thể thao',
  ),
  Carousel(
    carouselImage: 'assets/img/elegant_design.png',
    carouselPhone: 'Thiết kế hiện đại',
  ),
  Carousel(
    carouselImage: 'assets/img/elegant_design.png',
    carouselPhone: 'Thiết kế thể thao',
  ),
];

class _BigCarouselWidgetState extends State<BigCarouselWidget> { 
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 131,
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: 20,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        color: const Color.fromRGBO(238, 238, 238, 1),
      ),
      child: Swiper(
        itemBuilder: (context, index) {
          return ImagePlaceholder(
            carouselPhone: carouselProduct[index].carouselPhone,
            carouselImage: carouselProduct[index].carouselImage,
            index: index,
          );
        },
        itemCount: carouselProduct.length,
        autoplay: true,
        pagination: SwiperPagination(
          alignment: Alignment.bottomRight,
          builder: DotSwiperPaginationBuilder(
            color: Colors.white,
            activeColor: Color.fromRGBO(203, 109, 128, 1),
          ),
        ),
      ),
    );
  }
}

class ImagePlaceholder extends StatelessWidget {
  final String carouselPhone;
  final String carouselImage;
  final int index;
  ImagePlaceholder({
    super.key,
    required this.carouselPhone,
    required this.carouselImage,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          carouselProduct[index].carouselImage,
          width: screenWidth * 0.4,
          fit: BoxFit.contain,
        ),
        Flexible(
          child: Text(
            carouselProduct[index].carouselPhone,
            style: const TextStyle(
              fontSize: 24,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}


// Container(
//       margin: EdgeInsets.only(
//         bottom: 30,
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
//       width: double.infinity,
//       height: 131,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(13),
//         color: const Color.fromRGBO(238, 238, 238, 1),
//       ),
//       child: Column(
//         children: [
//           Stack(
//             children: [
//               SizedBox(
//                 width: double.infinity,
//                 height: 121,
//                 child: PageView(
//                   controller: _pageController,
//                   onPageChanged: (index) {
//                     updateCurrentPage(index);
//                   },
//                   children: List.generate(
//                     carouselProduct.length,
//                     (index) => ImagePlaceholder(
//                       carouselPhone: carouselProduct[index].carouselPhone,
//                       carouselImage: carouselProduct[index].carouselImage,
//                       index: index,
//                     ),
//                   ),
//                 ),
//               ),
//               Positioned(
//                 bottom: 10,
//                 right: 15,
//                 child: Container(
//                   color: Colors.transparent,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: List.generate(
//                       carouselProduct.length,
//                       (index) => Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 2),
//                         child: InkWell(
//                           onTap: () {
//                             _pageController.jumpToPage(index);
//                           },
//                           child: Icon(
//                             Icons.circle,
//                             size: 10,
//                             color: _currentPage == index
//                                 ? const Color(0xffb23f56)
//                                 : const Color(0xffffffff),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );