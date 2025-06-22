import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/config/margin.dart';
import 'package:healthy_food/config/navigator.dart';
import 'package:healthy_food/main.dart';

import 'package:healthy_food/views/screens/cart_screen.dart';
import 'package:healthy_food/views/screens/home_screen.dart';

class ItemDetailsScreen extends ConsumerWidget {
  ItemDetailsScreen({
    required this.itemName,
    required this.image,
    required this.price,
    this.time,
    required Map<String, dynamic> item,
  });

  final String itemName;
  final String? time;
  final String price;
  final String image;
  final counterProvider = StateProvider<int>((ref) => 1);
  final totalProvider = StateProvider<String>((ref) => "0");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(totalProvider.notifier).state =
          (ref.read(counterProvider) * num.parse(price)).toStringAsFixed(2);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFE6E6E6),
      body: Stack(
        children: [
          SizedBox(
            width: context.screenWidth,
            child: SvgPicture.asset(
              "assets/icons/item_details.svg",
              width: context.screenWidth,
              height: context.screenHeight,
              fit: BoxFit.fill,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                40.h,
                Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    onTap: () {
                      navigator(context: context, screen: HomeScreen());
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                40.h,
                Image.asset(
                  "assets/images/$image.png",
                  width: context.screenWidth,
                  fit: BoxFit.fill,
                ),
                40.h,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          itemName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final counter = ref.watch(counterProvider);
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (counter > 1) {
                                        ref.read(counterProvider.notifier).state--;
                                        ref.read(totalProvider.notifier).state =
                                            (counter * num.parse(price))
                                                .toStringAsFixed(2);
                                      }
                                    },
                                    child: const Icon(
                                      Icons.remove,
                                      color: Colors.black,
                                    ),
                                  ),
                                  10.w,
                                  Text(counter.toString()),
                                  10.w,
                                  InkWell(
                                    onTap: () {
                                      ref.read(counterProvider.notifier).state++;
                                      ref.read(totalProvider.notifier).state =
                                          ((counter + 1) * num.parse(price))
                                              .toStringAsFixed(2);
                                    },
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    30.h,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Description",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$price LE",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "Pizza & Chicken & Tomatoes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    30.h,
                    const Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amberAccent,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "4.9",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "450 calories",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Consumer(
                  builder: (context, ref, child) {
                    final total = ref.watch(totalProvider);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total",
                          style: TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          "$total LE",
                          style: const TextStyle(
                            color: kPrimaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                20.h,
                Consumer(
                  builder: (context, ref, child) {
                    return InkWell(
                      onTap: () {
                        CartScreen.cart.add({
                          "name": itemName,
                          "image": image,
                          "price": price,
                          "count": ref.read(counterProvider),
                        });
                      },
                      child: Container(
                        width: context.screenWidth,
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shopping_cart),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Checkout",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    40.w,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
