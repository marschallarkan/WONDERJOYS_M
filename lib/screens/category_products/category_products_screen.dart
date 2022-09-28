import 'package:wonderjoys/models/Product.dart';

import 'package:flutter/material.dart';

import 'components/body.dart';

class CategoryProductsScreen extends StatelessWidget {
  final ProductType? productType;

  const CategoryProductsScreen({
    Key? key,
     this.productType,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        productType: productType!,
      ),
    );
  }
}
