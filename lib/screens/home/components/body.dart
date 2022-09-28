import 'package:wonderjoys/constants.dart';
import 'package:wonderjoys/models/Product.dart';
import 'package:wonderjoys/screens/cart/cart_screen.dart';
import 'package:wonderjoys/screens/category_products/category_products_screen.dart';
import 'package:wonderjoys/screens/product_details/product_details_screen.dart';
import 'package:wonderjoys/screens/search_result/search_result_screen.dart';
import 'package:wonderjoys/services/authentification/authentification_service.dart';
import 'package:wonderjoys/services/data_streams/all_products_stream.dart';
import 'package:wonderjoys/services/data_streams/favourite_products_stream.dart';
import 'package:wonderjoys/services/database/product_database_helper.dart';
import 'package:wonderjoys/size_config.dart';
import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:logger/logger.dart';
import '../../../utils.dart';
import '../components/home_header.dart';
import 'product_type_box.dart';
import 'products_section.dart';

const String? ICON_KEY = "icon";
const String? TITLE_KEY = "titolo";
const String? PRODUCT_TYPE_KEY = "Tipologia di prodotto";

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final productCategories = <Map>[
    <String, dynamic>{
      ICON_KEY!: "assets/icons/Electronics.svg",
      TITLE_KEY!: "Elettronica",
      PRODUCT_TYPE_KEY!: ProductType.Elettronica,
    },
    <String, dynamic>{
      ICON_KEY!: "assets/icons/Books.svg",
      TITLE_KEY!: "Food",
      PRODUCT_TYPE_KEY!: ProductType.Food,
    },
    <String, dynamic>{
      ICON_KEY!: "assets/icons/Fashion.svg",
      TITLE_KEY!: "Moda",
      PRODUCT_TYPE_KEY!: ProductType.Moda,
    },
    <String, dynamic>{
      ICON_KEY!: "assets/icons/Groceries.svg",
      TITLE_KEY!: "Bellezza",
      PRODUCT_TYPE_KEY!: ProductType.Bellezza,
    },
    <String, dynamic>{
      ICON_KEY!: "assets/icons/Art.svg",
      TITLE_KEY!: "Servizi",
      PRODUCT_TYPE_KEY!: ProductType.Servizi,
    },
    <String, dynamic>{
      ICON_KEY!: "assets/icons/Others.svg",
      TITLE_KEY!: "Altre",
      PRODUCT_TYPE_KEY!: ProductType.Altre,
    },
  ];

  final FavouriteProductsStream favouriteProductsStream =
      FavouriteProductsStream();
  final AllProductsStream allProductsStream = AllProductsStream();

  @override
  void initState() {
    super.initState();
    favouriteProductsStream.init();
    allProductsStream.init();
  }

  @override
  void dispose() {
    favouriteProductsStream.dispose();
    allProductsStream.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshPage,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(screenPadding)),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: getProportionateScreenHeight(15)),
                HomeHeader(
                  onSearchSubmitted: (value) async {
                    final query = value.toString();
                    if (query.length <= 0) return;
                    List<dynamic> searchedProductsId;
                    try {
                      searchedProductsId = await ProductDatabaseHelper()
                          .searchInProducts(query.toLowerCase());
                      if (searchedProductsId != null) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultScreen(
                              searchQuery: query,
                              searchResultProductsId: searchedProductsId as dynamic,
                              searchIn: "Tutti i Prodotti",
                            ),
                          ),
                        );
                        await refreshPage();
                      } else {
                        throw "Impossibile eseguire la ricerca per motivi sconosciuti";
                      }
                    } catch (e) {
                      final error = e.toString();
                      Logger().e(error);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("$error"),
                        ),
                      );
                    }
                  },
                  onCartButtonPressed: () async {
                    bool allowed =
                        AuthentificationService().currentUserVerified;
                    if (!allowed) {
                      final reverify = await showConfirmationDialog(context,
                          "Non hai verificato il tuo indirizzo email. Questa azione è consentita solo per gli utenti verificati.",
                          positiveResponse: "Invia nuovamente email di verifica",
                          negativeResponse: "Torna indietro");
                      if (reverify) {
                        final future = AuthentificationService()
                            .sendVerificationEmailToCurrentUser();
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return FutureProgressDialog(
                              future,
                              message: Text("Reinvio dell'email di verifica"),
                            );
                          },
                        );
                      }
                      return;
                    }
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(),
                      ),
                    );
                    await refreshPage();
                  },
                ),
                SizedBox(height: getProportionateScreenHeight(15)),
                SizedBox(
                  height: SizeConfig.screenHeight! * 0.1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      children: [
                        ...List.generate(
                          productCategories.length,
                          (index) {
                            return ProductTypeBox(
                              icon: productCategories[index][ICON_KEY],
                              title: productCategories[index][TITLE_KEY],
                              onPress: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CategoryProductsScreen(
                                      productType: productCategories[index]
                                          [PRODUCT_TYPE_KEY],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                SizedBox(
                  height: SizeConfig.screenHeight! * 0.5,
                  child: ProductsSection(
                    sectionTitle: "Prodotti che ti piacciono",
                    productsStreamController: favouriteProductsStream,
                    emptyListMessage: "Aggiungi prodotto ai preferiti",
                    onProductCardTapped: onProductCardTapped,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                SizedBox(
                  height: SizeConfig.screenHeight! * 0.8,
                  child: ProductsSection(
                    sectionTitle: "Esplora tutti i prodotti",
                    productsStreamController: allProductsStream,
                    emptyListMessage: "Sembra che tutti i negozi siano chiusi",
                    onProductCardTapped: onProductCardTapped,
                  ),
                ),
                SizedBox(height: getProportionateScreenHeight(80)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> refreshPage() {
    favouriteProductsStream.reload();
    allProductsStream.reload();
    return Future<void>.value();
  }

  void onProductCardTapped(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsScreen(productId: productId),
      ),
    ).then((_) async {
      await refreshPage();
    });
  }
}
