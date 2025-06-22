import 'package:flutter/material.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/config/margin.dart';
import 'package:healthy_food/config/navigator.dart';
import 'package:healthy_food/views/screens/item_details_screen.dart';


class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    this.itemName,
    this.image,
    this.price,
    this.time,
    this.description,
  });

  final String? itemName;
  final String? time;
  final String? price;
  final String? image;
  final String? description;

  @override
  Widget build(BuildContext context) {
    // Ensure we have valid values for required fields
    final validItemName = itemName ?? 'Untitled Item';
    final validImage = image ?? 'default_food';
    final validPrice = price ?? '0';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          navigator(
            context: context,
            screen: ItemDetailsScreen(
              itemName: validItemName,
              time: time ?? '',
              price: validPrice,
              image: validImage,
              item: {
                'name': validItemName,
                'image': validImage,
                'price': validPrice,
                'time': time ?? '',
                'description': description ?? '',
              },
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          width: context.screenWidth / 1.2,
          decoration: BoxDecoration(
            color: kPrimaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      validItemName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          "${time ?? 'N/A'} min",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        5.w,
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white,
                        )
                      ],
                    ),
                    Text(
                      "$validPrice LE",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              20.w,
              _buildImage(context, validImage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String imageAsset) {
    return Image.asset(
      "assets/images/$imageAsset.png",
      width: context.screenWidth / 3,
      height: context.screenWidth / 3,
    );
  }
} 