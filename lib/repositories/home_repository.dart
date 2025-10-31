import 'package:homy/models/homeslider_model.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';

class HomeRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

    // Future<List<Category>> getCategories() async {
    //   final response = await apiClient.getData('categories');
    // }

    Future<List<HomeSlider>> getSliders() async {
      final response = await apiClient.getData('sliders');
      final List<HomeSlider> slidersList = [];
      response.body['data'].forEach((data) {
        print(HomeSlider.fromJson(data));
        slidersList.add(HomeSlider.fromJson(data));
      });
      return slidersList;
    }
}
