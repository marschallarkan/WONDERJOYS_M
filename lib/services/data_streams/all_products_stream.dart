import 'package:wonderjoys/services/data_streams/data_stream.dart';
import 'package:wonderjoys/services/database/product_database_helper.dart';

class AllProductsStream extends DataStream<List<dynamic>> {
  @override
  void reload() {
    final allProductsFuture = ProductDatabaseHelper().allProductsList;
    allProductsFuture.then((favProducts) {
      addData(favProducts);
    }).catchError((e) {
      addError(e);
    });
  }
}
