import 'package:flutter/material.dart';
import 'category_card.dart';

class Categories extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {"icon": "assets/icons/Flash Icon.svg", "text": "Offerta lampo"},
    {"icon": "assets/icons/Bill Icon.svg", "text": "Conto"},
    {"icon": "assets/icons/Game Icon.svg", "text": "Gioco"},
    {"icon": "assets/icons/Gift Icon.svg", "text": "Regalo Quotidiano"},
    {"icon": "assets/icons/Discover.svg", "text": "Di più"},
  ];
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        categories.length,
        (index) => CategoryCard(
          icon: categories[index]["icon"],
          text: categories[index]["text"],
          press: () {},
        ),
      ),
    );
  }
}
