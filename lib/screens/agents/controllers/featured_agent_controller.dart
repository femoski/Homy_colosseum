import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:homy/repositories/properties_respository.dart';

import '../../../common/ui.dart';
import '../../../models/agent_model.dart';
import '../../../models/property/property_data.dart';

class FeaturedAgentController extends GetxController {
  // final agent = Get.arguments['agent'];
final PropertiesRepository propertiesRepository = PropertiesRepository();

  List<PropertyData> properties = [];
  bool isLoading = false;
  bool hasMoreData = true;
  int currentPage = 1;
  static const int itemsPerPage = 10;
  late ScrollController scrollController;

  FeaturedAgentController(){
    scrollController = ScrollController();
  }
  bool _isFirstLoad = true;
    final AgentModel? agent = Get.arguments;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
        loadAgentProperties();

  }


  // @override
  // void onInit() {
  //   super.onInit();
  //   // ();
  // }


  Future<void> loadMoreProperties() async {
    if (!hasMoreData || isLoading) return;

    try {
      isLoading = true;
      update(['agent']);

      Map<String, dynamic> params = {
        'user_id': agent!.id.toString(),
        'after_id': properties.last.id.toString(),
        'per_page': itemsPerPage.toString(),
      };

      final newProperties = await propertiesRepository.getProperties(params: params);

      if (newProperties.isEmpty) {
        hasMoreData = false;
      }
      properties.addAll(newProperties);

    } catch (e) {
      Get.showSnackbar(CommonUI.infoSnackBar(message: e.toString()));
    } finally {
      isLoading = false;
        update(['agent']);
    }
  }

  Future<void> loadAgentProperties() async {
    if (isLoading) return;
    try {
      isLoading = true;
      update(['agent']);

      Map<String, dynamic> params = {
        'user_id': agent!.id.toString(),
        'page': currentPage.toString(),
        'per_page': itemsPerPage.toString(),
      };

      final newProperties = await propertiesRepository.getProperties(params: params);

      if (newProperties.isNotEmpty) {
        properties.addAll(newProperties);
        currentPage++;
      } else {
        hasMoreData = false;
      }

    } catch (e) {
      Get.showSnackbar(CommonUI.infoSnackBar(message: e.toString()));
    } finally {
      isLoading = false;
        update(['agent']);
    }
  }
  

    void _onScroll() {

    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      loadAgentProperties();
    }
  }

  Future<void> loadAgent() async {
    try {
      Map<String, dynamic> params = {
        'agent_id': '1',
      };
      final agent = await propertiesRepository.getProperties(params: params);
      update();
    } catch (e) {
      print('Error loading agent: $e');
    }
  }

   Future<void> refresh() async {
    currentPage = 1;
    hasMoreData = true;
    properties.clear();
      // await loadMoreProperties();
  }

}