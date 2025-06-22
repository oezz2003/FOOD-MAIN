import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healthy_food/config/constants.dart';
import 'package:healthy_food/config/margin.dart';
import 'package:healthy_food/config/navigator.dart';
import 'package:healthy_food/views/screens/item_details_screen.dart';


class ItemCard extends StatelessWidget {
  ItemCard({
    required this.itemName,
    required this.image,
    required this.price,
    required this.time,
    this.description,
  });

  final String itemName;
  final String time;
  final String price;
  final String image;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          navigator(
            context: context,
            screen: ItemDetailsScreen(
              itemName: itemName,
              time: time,
              price: price,
              image: image,
              item: {
                "description": description ?? "",
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
                  children: [
                    Text(
                      itemName,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "$time min",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        5.w,
                        const Icon(
                          Icons.access_time_rounded,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$price LE",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    if (description != null && description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          description!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              20.w,
              _buildImage(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Image.asset(
      "assets/images/$image.png",
      width: context.screenWidth / 3,
      height: context.screenWidth / 3,
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.broken_image, color: Colors.white, size: 50);
      },
    );
  }
}

