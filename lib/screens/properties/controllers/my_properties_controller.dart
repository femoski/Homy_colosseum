import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/common/widgets/confirmation_dialog.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/repositories/properties_respository.dart';
import 'package:homy/screens/properties/add_edit_property.dart';
import 'package:homy/screens/search_screen/controllers/search_controller.dart';


class MyPropertiesScreenController extends SearchScreenController {
  bool isHideProperty = false;
  bool isInApi = false;
  List<PropertyData> propertyList = [];
  List<PropertyData> propertyListAll = [];
  int? type = 0;

  ScrollController scrollController = ScrollController();
  bool isFirst = false;
  bool isLoading = true;

  MyPropertiesScreenController(this.type);
final PropertiesRepository propertiesRepository = PropertiesRepository();

  @override
  void onReady() {
    fetchMyProperties();
    // onTypeChange(type ?? 0);
    // Get.log('onTypeChange: ${type ?? 0}');


    selectedType=type ?? 0;
    super.onReady();
  }

  @override
  void onTypeChange(int index) {
    if (isFirst) {
      if (type == index) {
        return;
      }
    }
    isFirst = true;
    type = index;
    propertyList = [];
    isInApi = false;
    scrollController.dispose();
    scrollController = ScrollController();
 
    // // fetchMyProperties(type: index);
    // fetchScrollData(type: index);
    

       if(type == 0){
        propertyList.clear();
      propertyList.addAll(propertyListAll);
    }
    if(type == 1){
      propertyList.clear();
     propertyList.addAll(propertyListAll
        .where((property) => property.propertyType == 'Rent')
        .toList());
    }
    if(type == 2){
      propertyList.clear();
    propertyList.addAll(propertyListAll
        .where((property) => property.propertyType == 'Sales')
        .toList());
    }
        update();
        super.onTypeChange(index); 
  }



  void fetchMyProperties() async {
    if (isInApi) return;
      isLoading = true;
    isInApi = true;
    update();
    try{
    propertyListAll= await propertiesRepository.fetchMyProperties();
    isLoading = false;
    }catch(e){
      isLoading = false;
      isInApi = false;
      update();
    }

    
    // propertyListAll = MockPropertyData.properties.values.toList();

    if(type == 0){
      propertyList.addAll(propertyListAll);
    }
    if(type == 1){
      propertyList.addAll(propertyListAll
        .where((property) => property.propertyType == 'Rent')
        .toList());

    }
    if(type == 2){
      propertyList.addAll(propertyListAll
        .where((property) => property.propertyType == 'Sales')
        .toList());
    }
    // propertyList.addAll(MockPropertyData.properties.values.toList());

    update();

  
  }

  void allproperties()
  {
    propertyList.addAll(propertyListAll);
  }


  void rentproperties()
  {
     propertyList.addAll(propertyListAll
        .where((property) => property.propertyAvailableFor == 1)
        .toList());
          update();
  }

 void buyproperties()
  {
     propertyList.addAll(propertyListAll
        .where((property) => property.propertyAvailableFor == 2)
        .toList());
        update();
  }

  void onPropertyEnable(PropertyData? data) async {
    int value = data?.isHidden == 0 ? 1 : 0;
    isHideProperty = true;
    update();
    Map<String, dynamic> res = await propertiesRepository.updateProperty(data?.id ?? 0, {'isHidden': value});
    if(res['status'] == true){

      var index = propertyList.indexWhere((element) => element.id == data?.id);
      if (index != -1) {
        propertyList[index] = PropertyData.fromJson(res['property']);
        Get.log('propertyList: ${propertyList[index]}');
      }

        var indexAll = propertyListAll.indexWhere((element) => element.id == data?.id);
      if (indexAll != -1) {
        propertyListAll[indexAll] = PropertyData.fromJson(res['property']);
        Get.log('propertyListAll: ${propertyListAll[indexAll]}');
      }
         update();
    }
          isHideProperty = false;

    update();
    // ApiService().multiPartCallApi(
    //   url: UrlRes.editProperty,
    //   param: {uUserId: data?.userId.toString(), uPropertyId: data?.id.toString(), uIsHidden: value.toString()},
    //   filesMap: {},
    //   completion: (response) {
    //     PropertyData? data = FetchPropertyDetail.fromJson(response).data;
    //     if (data != null) {
    //       propertyList[propertyList.indexWhere((element) => element.id == data.id)] = data;
    //       isHideProperty = false;
    //       update();
    //     }
    //   },
    // );
  }

  void fetchScrollData({required int type}) {
    if (!scrollController.hasClients) {
      scrollController = ScrollController()
        ..addListener(
          () {
            if (scrollController.offset >= scrollController.position.maxScrollExtent) {
              if (!isInApi) {
                fetchMyProperties();
              }
            }
          },
        );
    }
  }

  onEditBtnClick(PropertyData data) {
    Get.to(() => const AddEditPropertyScreen(screenType: 1), arguments: data)?.then((value) {
      if (value != null) {
        PropertyData d = value;
        propertyList[propertyList.indexWhere((element) => element.id == d.id)] = d;
        update();
      }
    });
  }

  void onDeleteProperty(int id)  {
    if (id != -1) {
      Get.dialog(
        ConfirmationDialog(
          title1: 'Delete',
          title2: 'Are you sure you want to delete your property?',
          aspectRatio: 1.8,
          onPositiveTap: () async {
            Get.back();
            CommonUI.loader();
          Map<String, dynamic> res = await propertiesRepository.deleteProperty(id: id);
           Get.back();
            Get.showSnackbar(CommonUI.SuccessSnackBar(message: res['message']));
     
if(res['status'] == true){
  propertyList.removeWhere((element) => element.id == id);
       propertyListAll.removeWhere((element) => element.id == id);
    
  onTypeChange(type ?? 0);
}
   update();
            
            // ApiService().call(
            //   url: UrlRes.deleteMyProperty,
            //   param: {uUserId: PrefService.id.toString(), uPropertyId: id.toString()},
            //   completion: (response) async {
            //     Get.back();
            //     Status status = Status.fromJson(response);
            //     if (status.status == true) {
            //       CommonUI.materialSnackBar(title: status.message!);
            //       onTypeChange(type);
            //     }
            //   },
            // );
          },
        ),
      );
    } else {
      CommonUI.snackBar(title: 'Property ID not found');
    }
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchProperties();
  // }

  // Future<void> fetchProperties() async {
  //   isLoading = true;
  //   update();
  //   fetchMyProperties();
  //   isLoading = false;
  //   update();
  // }
}
