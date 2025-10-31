import 'package:homy/common/ui.dart';
import 'package:homy/models/agent_model.dart';
import 'package:homy/models/category.dart';
import 'package:homy/models/city_model.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/models/tour/fetch_property_tour.dart';
import 'package:homy/providers/api_client.dart';
import 'package:homy/utils/constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PropertiesRepository {
  final apiClient = ApiClient(appBaseUrl: Constants.baseUrl);

  Future<List<Category>> getCategories() async {
    final response = await apiClient.getData('categories');
    if (response.statusCode == 200) {
      final List<dynamic> categoriesData = response.body['data'];
      return categoriesData
          .map((category) => Category.fromJson(category))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
  
  Future<List<PropertyData>> getProperties({Map<String, dynamic>? params}) async {
    Get.log('params: $params');
      final response = await apiClient.getData('properties', query: params,handleError: false);
    if (response.statusCode == 200) {
      final List<dynamic> propertiesData = response.body['data'];
      return propertiesData
          .map((property) => PropertyData.fromJson(property))
          .toList();
    } else if (response.statusCode == 400) {
      throw 'No more properties found';
    } else {
      Get.log('propertiesData: ${response.statusCode}');
      Get.snackbar('Error', response.body['message'] ?? 'Failed to load properties');
      throw Exception(response.statusText);
    }
   
  }

    Future<List<CityModel>> getPopularCity({Map<String, dynamic>? params}) async {
    Get.log('params: $params');
    final response = await apiClient.getData('popular-areas', query: params);
    if (response.statusCode == 200) {
      final List<dynamic> popularCity = response.body['data'];
      return popularCity
          .map((city) => CityModel.fromJson(city))
          .toList();
    } else {
      throw Exception('Failed to load Popular City');
    }
  }

  Future<dynamic> addProperty({
    required Map<String, dynamic> param,
    required Map<String, List<XFile>> filesMap,
  }) async {
    try {
      final bool isEdit = param.containsKey('property_id');
      final String url = isEdit ? '/properties/update' : '/properties';

      final response = await apiClient.multiPartRequestWeb(
        url: url,
        filesMap: filesMap,
        fields: param,
      );
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success', 
          isEdit ? 'Property updated successfully' : 'Property added successfully',
          snackPosition: SnackPosition.TOP,
        );
        final responseData = response.body['data'];
        if (responseData is String) {
          return int.tryParse(responseData) ?? responseData;
        }
        return responseData;
      } else {
        Get.snackbar(
          'Error',
          'Failed to ${isEdit ? 'update' : 'add'} property',
          snackPosition: SnackPosition.TOP,
        );
        throw Exception('Failed to ${isEdit ? 'update' : 'add'} property');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
      );
      //  throw Exception('Failed to ${ ? 'update' : 'add'} property');
    }
  }

  Future<List<AgentModel>> getFeaturedAgents({Map<String, dynamic>? params}) async {
    final response = await apiClient.getData('featured-agents', query: params);
    if (response.statusCode == 200) {
      final List<dynamic> agentsData = response.body['data'];
      Get.log('agentsData: $agentsData');
      return agentsData.map((agent) => AgentModel.fromJson(agent)).toList();
    } else {
      throw Exception('Failed to load featured agents');
    }
  }

  Future<PropertyData> fetchPropertyDetail(int propertyId) async {
    try{
    final response = await apiClient.getData('properties/details/$propertyId',handleError: false);

    print('response: ${response.body['message']}');
    if (response.statusCode == 200) {
      return PropertyData.fromJson(response.body['data']);
    } else {
      throw response.body['message'];
    }
    }
    catch(e){
     print('responseaaaaa: ${e.toString()}');

      throw e.toString();
    }
  }


  Future<List<PropertyData>> getUserProperties(int userId) async {
    final response = await apiClient.getData('properties/user/$userId');
    if (response.statusCode == 200) {
      final List<dynamic> propertiesData = response.body['data'];
      return propertiesData
          .map((property) => PropertyData.fromJson(property))
          .toList();
    } else {
      throw Exception('Failed to load user properties');
    }
  }

  Future<List<PropertyData>> fetchMyProperties({Map<String, dynamic>? map}) async {
    try { 
      final response = await apiClient.getData('my-properties', query: map);
      // return response.body['data'].map((property) => PropertyData.fromJson(property)).toList();
      if (response.statusCode == 200) {
        final List<dynamic> propertiesData = response.body['data'];
        return propertiesData
            .map((property) => PropertyData.fromJson(property))
            .toList();
      } else {
        throw Exception('Failed to load user properties');
      }
    } catch (e) {
      throw Exception('Failed to load user properties');
    }

  }

  Future<Map<String, dynamic>> scheduleTour({Map<String, dynamic>? params}) async {
    try {
      final response = await apiClient.postData('schedule-tour',params,handleError: false);

      if (response.statusCode == 200||response.statusCode == 201) {
        // print(response.body['data']);
      return response.body['data'];
    } else if (response.statusCode == 400) {
      return response.body;
    } else {
      throw Exception(response.statusText);
    }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> verifyPayment(String reference) async {
    final response = await apiClient.getData(
      'verify-payment',
      query: {'reference': reference},
    );
    
    if (response.statusCode == 200) {
      return response.body['data'];
    } else {
      throw Exception('Failed to verify payment');
    }
  }

  Future<List<FetchPropertyTourData>> fetchPropertyReceiveTourList(String userId, String type, int offset, int limit) async {
    final response = await apiClient.getData('tour-requests/$userId?type=$type&offset=$offset&limit=$limit');
    final List<dynamic> tourData = response.body['data'];
    return tourData.map((data) => FetchPropertyTourData.fromJson(data)).toList();
    // return response.body['data'].map((property) => FetchPropertyTourData.fromJson(property)).toList();
  }

  Future<Map<String, dynamic>> confirmPropertyTour(Map<String, dynamic> params) async {
    final response = await apiClient.postData('tour-requests/status/${params['tour_id']}',params,handleError: false);
    if(response.statusCode == 200){
      return response.body['data'];
    }
    else{
      throw Exception(response.statusText);
    }
  }

  Future<Map<String, dynamic>> cancelPropertyTour(Map<String, dynamic> params) async {
    final response = await apiClient.postData('tour-requests/cancel/${params['tour_id']}',params);
    return response.body['data'];
  }

  Future<Map<String, dynamic>> markPropertyTourAsCompleted(String tourId) async {
    final response = await apiClient.postData('tour-requests/complete/$tourId',{'status':'completed'});
    return response.body['data'];
  }

  Future<Map<String, dynamic>> refundPropertyTour(String tourId) async {
    try{  
    final response = await apiClient.postData('tour-requests/refund/$tourId',{},handleError: false);
    if(response.statusCode == 200){
      return response.body['data'];
    }
    if(response.statusCode == 400){
      // Get.showSnackbar(CommonUI.ErrorSnackBar(message: response.body['message'].toString()));
      throw response.body['message'];
    }
    else{
      throw Exception(response.statusText);
    }
    }
    catch(e){
      throw Exception(e.toString());
    }
  }

  Future<Map<String, dynamic>> getTourRequest(String tourId) async {
    final response = await apiClient.getData('tour-requests/$tourId');
    return response.body['data'];
  }

  Future<Map<String, dynamic>> autoCompleteTour(String tourId) async {
    final response = await apiClient.postData('tour-requests/auto-complete/$tourId', {});
    return response.body['data'];
  }

  Future<Map<String, dynamic>> confirmTourCompletion(String tourId) async {
    final response = await apiClient.postData('tour-requests/confirm-completion/$tourId', {});
    return response.body['data'];
  }

  Future<Map<String, dynamic>> deleteProperty({required int id}) async {
    final response = await apiClient.deleteData('properties/details/$id');
    // return response.body['data'];
    if(response.statusCode == 200){
      return response.body['data'];
    }
    else{
      throw Exception(response.statusText);
    } 
  }

  Future<Map<String, dynamic>> updateProperty(int id, Map<String, dynamic> params) async {
    final response = await apiClient.putData('properties/details/$id',params);
    if(response.statusCode == 200){
      return response.body['data'];
    }
    else{
      throw Exception(response.statusText);
    }
  } 

  Future<List<PropertyData>> likeProperty(int id, String type) async {
    final response = await apiClient.postData('/properties/$id/like', {'type': type});
    return response.body['data'].map((property) => PropertyData.fromJson(property)).toList();
  } 

  Future<List<PropertyData>> unlikeProperty(int id) async {
    final response = await apiClient.postData('/properties/$id/unlike', {});
    return response.body['data'].map((property) => PropertyData.fromJson(property)).toList();
  }
}
