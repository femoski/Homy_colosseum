// import 'package:get/get.dart';
// import 'package:homy/models/property_model.dart';
// import 'package:homy/widgets/like_button_widget.dart';

// class FavoriteController extends GetxController {
//   final RxSet<String> _favorites = <String>{}.obs;

//   bool isFavorite(String propertyId) => _favorites.contains(propertyId);

//   void toggleFavorite(PropertyModel property, FavoriteType type) {
//     if (type == FavoriteType.add) {
//       _favorites.add(property.id!);
//       property.isFavorite = true;
//     } else {
//       _favorites.remove(property.id!);
//       property.isFavorite = false;
//     }
//     update();
//     // Here you would typically make an API call to update the server
//   }
// // } 