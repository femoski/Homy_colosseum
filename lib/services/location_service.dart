import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:homy/models/place_model.dart';

class LocationService extends GetxService {
  GetStorage storage = GetStorage();
  final place = PlaceModel(placeId: '', description: '').obs; 
  @override
  void onInit() {
    super.onInit();
    // storage = GetStorage();
    init();
  }


    // Static helper method to get config service and ensure it's initialized
  static Future<LocationService> getLocation() async {
    if (!Get.isRegistered<LocationService>()) {
      await Get.putAsync(() => LocationService().init());
    }
    return Get.find<LocationService>();
  }


  Future<LocationService> init() async {
    place.listen((PlaceModel _place) {
      storage.write('selected_place', _place.toJson());
    });
    await getCurrentPlace();
    return this;
  }

  Future getCurrentPlace() async {
    final placeJson = storage.read('selected_place');
    if (placeJson == null) return null;
    place.value = PlaceModel.fromJson(placeJson);
  }

  String get description => place.value.description;
  String get placeId => place.value.placeId;
  String get formattedAddress => place.value.formattedAddress ?? '';
  String get city => place.value.city ?? '';
  String get state => place.value.state ?? '';
  String get country => place.value.country ?? '';
  String get latitude => place.value.latitude ?? '';
  String get longitude => place.value.longitude ?? '';

} 
