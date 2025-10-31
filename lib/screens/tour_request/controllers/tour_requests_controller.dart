import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/property/tour_request_model.dart';
import 'package:homy/models/tour/fetch_property_tour.dart';
import 'package:homy/repositories/properties_respository.dart';
import 'package:homy/screens/tour_request/views/tour_request_sheet.dart';
import 'package:homy/screens/tour_request/views/tour_request_user_sheet.dart';
import 'package:homy/screens/tour_request/views/enhanced_tour_request_sheet.dart';
import 'package:homy/services/auth_service.dart';
import 'package:homy/repositories/dispute_repository.dart';
import 'package:homy/screens/tour_request/widgets/dispute_dialog.dart';
import 'package:homy/screens/tour_request/widgets/cancel_request_dialog.dart';
import 'package:homy/screens/tour_request/widgets/refund_request_dialog.dart';
import 'package:homy/screens/tour_request/widgets/confirm_tour_completion_dialog.dart';
import 'package:homy/screens/tour_request/widgets/accept_request_dialog.dart';
import 'package:homy/screens/tour_request/widgets/decline_request_dialog.dart';
import 'package:homy/screens/tour_request/widgets/mark_tour_completed_dialog.dart';
import 'package:homy/common/common_funtions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:homy/Helper/AuthHelper.dart';
import 'package:homy/screens/chat_screen/message_box.dart';
import 'package:flutter/services.dart';



import '../../../models/chat/chat_list.dart';

class TourRequestsController extends GetxController {
  int selectedTab = 0;
  ScrollController scrollController = ScrollController();
  int screenType;
  List<FetchPropertyTourData> tourData = [];
  List<FetchPropertyTourData> tourDataList = [];

  bool isLoading = false;
  RxBool isRequestLoading = false.obs;
  bool isFirst = false;
  int cPaginationLimit = 10;

  final propertiesRepository = PropertiesRepository();
  final _authservice = Get.find<AuthService>();

  TourRequestsController(this.screenType, this.selectedTab);

  @override
  void onReady() {
    onTypeChange(selectedTab);
    fetchScrollData();
    tourRequestReceivedApiCall();
    super.onReady();
  }

  void onTypeChange(int index) {
    if (isFirst) {
      if (selectedTab == index) {
        return;
      }
    }
    if(index==0 || index==1)
    {
      tourData = tourDataList.where((element) => element.tourStatus == index).toList();
    }
    else
    {
      tourData = tourDataList.where((element) => element.tourStatus == index || element.tourStatus == 3
      || element.tourStatus == 4 || element.tourStatus == 5  || element.tourStatus == 6  || element.tourStatus == 7).toList();

    }

    // if(index == 2){
    // }
    // else{
    //   tourData = tourDataList.where((element) => element.tourStatus == index).toList();
    // }

    isFirst = true;
    selectedTab = index;
    isLoading = false;
    // tourData = [];
    // tourRequestReceivedApiCall();
    update();
  }

  void tourRequestReceivedApiCall() {
   isLoading = true;
    update();
String status = selectedTab == 0 ? 'waiting' : 'upcoming';
String type = screenType == 0 ? 'received' : 'sent';

    propertiesRepository.fetchPropertyReceiveTourList(_authservice.id.toString(), type, tourData.length, cPaginationLimit).then((value) {
      tourDataList.addAll(value);

        tourData = tourDataList.where((element) => element.tourStatus == selectedTab).toList();

      isLoading = false;
      update();
    });
  }

  void fetchScrollData() {
    scrollController.addListener(
      () {
        if (scrollController.offset >= scrollController.position.maxScrollExtent) {
          if (!isLoading) {
            // tourRequestReceivedApiCall();
          }
        }
      },
    );
  }

  void onPropertyCardClick(FetchPropertyTourData data, TourRequestsController controller) {
    if (screenType == 0) {
       Get.bottomSheet(
          TourRequestSheet(data: data, controller: controller),
        );
      // if (selectedTab <= 1) {

        
      //   Get.bottomSheet(
      //     TourRequestSheet(data: data, controller: controller),
      //   );
      // } else {
        
      //   Get.to(() => PropertyDetailScreen(propertyId: data.property?.id ?? -1));
      // }
    } else {

     Get.bottomSheet(
  TourRequestUserSheet(data: data, controller: controller),
);

      Get.toNamed('/property-details/:id/${data.property?.id ?? -1}', arguments: {
        'propertyId': data.property?.id,
        'propertiesList': [],
        'fromMyProperty': false,
      });
    }
  }

  void refundSheetButtonClick(FetchPropertyTourData data, int btnClick) async {
    if (btnClick == 0) {
      // Show cancel confirmation dialog
      final result = await Get.dialog(
        CancelRequestDialog(
          propertyTitle: data.property?.title ?? 'Property',
          tourDate: _formatDate(data.createdAt),
          onConfirm: () async {
            Get.back(); // Close dialog
            await _processCancelRequest(data);
          },
          isLoading: isRequestLoading.value,
        ),
      );
    } else if (btnClick == 1) {
      // Show refund confirmation dialog
      final result = await Get.dialog(
        RefundRequestDialog(
          propertyTitle: data.property?.title ?? 'Property',
          tourDate: _formatDate(data.createdAt),
          tourFee: '₦${data.property?.tourBookingFee ?? '1000'}',
          onConfirm: () async {
            Get.back(); // Close dialog
            await _processRefundRequest(data);
          },
          isLoading: isRequestLoading.value,
        ),
      );
    }
  }

  void showConfirmCompletionDialog(FetchPropertyTourData data) async {
    final result = await Get.dialog(
      ConfirmTourCompletionDialog(
        propertyTitle: data.property?.title ?? 'Property',
        tourDate: _formatDate(data.createdAt),
        onConfirm: () async {
          Get.back(); // Close dialog
          await confirmTourCompletion(data);
        },
        isLoading: isRequestLoading.value,
      ),
    );
  }

  void showAcceptRequestDialog(FetchPropertyTourData data) async {
    final result = await Get.dialog(
      AcceptRequestDialog(
        propertyTitle: data.property?.title ?? 'Property',
        tourDate: _formatDate(data.createdAt),
        clientName: data.client?.name ?? 'Client',
        onConfirm: () async {
          Get.back(); // Close dialog
          await onWaitingSheetButtonClick(data, 0, 'accept');
        },
        isLoading: isRequestLoading.value,
      ),
    );
  }

  void showDeclineRequestDialog(FetchPropertyTourData data) async {
    final result = await Get.dialog(
      DeclineRequestDialog(
        propertyTitle: data.property?.title ?? 'Property',
        tourDate: _formatDate(data.createdAt),
        clientName: data.client?.name ?? 'Client',
        onConfirm: () async {
          Get.back(); // Close dialog
          await onWaitingSheetButtonClick(data, 1, 'decline');
        },
        isLoading: isRequestLoading.value,
      ),
    );
  }

  void showMarkTourCompletedDialog(FetchPropertyTourData data) async {
    final result = await Get.dialog(
      MarkTourCompletedDialog(
        propertyTitle: data.property?.title ?? 'Property',
        tourDate: _formatDate(data.createdAt),
        clientName: data.client?.name ?? 'Client',
        onConfirm: () async {
          Get.back(); // Close dialog
          await onWaitingSheetButtonClick(data, 2, 'complete');
        },
        isLoading: isRequestLoading.value,
      ),
    );
  }

  Future<void> _processCancelRequest(FetchPropertyTourData data) async {
    Map<String, dynamic> params = {
      'tour_id': data.id.toString(),
      'status': 'cancel',
    };
    
    isRequestLoading.value = true;

    try {
      final response = await propertiesRepository.cancelPropertyTour(params);
      Get.back();
      Get.back();
      tourData.removeWhere((element) => element.id == data.id);
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        title: 'Tour Request',
        message: response['message'].toString(),
      ));
    } catch(e) {
      Get.back();
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    } finally {
      isRequestLoading.value = false;
    }
  }

  Future<void> _processRefundRequest(FetchPropertyTourData data) async {
    isRequestLoading.value = true;

    try {
      final response = await propertiesRepository.refundPropertyTour(data.id.toString());
      Get.back();
      Get.back();
      tourData.removeWhere((element) => element.id == data.id);
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        title: 'Tour Request',
        message: response['message'].toString(),
      ));
    } catch(e) {
      Get.back();
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    } finally {
      isRequestLoading.value = false;
    }
  }

  Future<void> _processTourCompletion(FetchPropertyTourData data) async {
    isRequestLoading.value = true;

    try {
      final response = await propertiesRepository.markPropertyTourAsCompleted(data.id.toString());
      Get.back();
      Get.back();
      tourData.removeWhere((element) => element.id == data.id);
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        title: 'Tour Request',
        message: response['message'].toString(),
      ));
    } catch(e) {
      Get.back();
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    } finally {
      isRequestLoading.value = false;
    }
  }

  Future<void> _processAcceptRequest(FetchPropertyTourData data) async {
    Map<String, dynamic> params = {
      'tour_id': data.id.toString(),
      'status': 'confirmed',
    };
    
    isRequestLoading.value = true;

    try {
      final response = await propertiesRepository.confirmPropertyTour(params);
      Get.back();
      Get.back();
      tourData.removeWhere((element) => element.id == data.id);
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        title: 'Tour Request',
        message: response['message'].toString(),
      ));
    } catch(e) {
      Get.back();
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    } finally {
      isRequestLoading.value = false;
    }
  }

  Future<void> _processDeclineRequest(FetchPropertyTourData data) async {
    Map<String, dynamic> params = {
      'tour_id': data.id.toString(),
      'status': 'declined',
    };
    
    isRequestLoading.value = true;

    try {
      final response = await propertiesRepository.cancelPropertyTour(params);
      Get.back();
      Get.back();
      tourData.removeWhere((element) => element.id == data.id);
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        title: 'Tour Request',
        message: response['message'].toString(),
      ));
    } catch(e) {
      Get.back();
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    } finally {
      isRequestLoading.value = false;
    }
  }

  String _formatDate(String? date) {
    if (date == null) return 'Not available';
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Future<void> onWaitingSheetButtonClick(FetchPropertyTourData data, int btnClick,status) async {
    CommonUI.loader();


  Map<String, dynamic> params = {
      'tour_id': data.id.toString(),
      'status': btnClick == 0 ? 'confirmed' : 'declined',
    };

    try {
      if (btnClick == 0) {
        final response = await propertiesRepository.confirmPropertyTour(params);
        Get.back();
        Get.back();
        tourData.removeWhere((element) => element.id == data.id);
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          title: 'Tour Request',
          message: response['message'].toString(),
        ));
      } else if (btnClick == 1) {
       final response = await propertiesRepository.cancelPropertyTour(params);
        Get.back();
        Get.back();
        tourData.removeWhere((element) => element.id == data.id);
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          title: 'Tour Request',
          message: response['message'].toString(),
        ));
      }
      else if (btnClick == 2) {
       final response = await propertiesRepository.markPropertyTourAsCompleted(data.id.toString());
        Get.back();
        Get.back();
        tourData.removeWhere((element) => element.id == data.id);
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          title: 'Tour Request',
          message: response['message'].toString(),
        ));
      }
      update();
    } catch (e) {
      Get.back();
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    }
  

    // try {
    //   if (btnClick == 2) { // Mark as completed
    //     final response = await propertiesRepository.markPropertyTourAsCompleted(data.id.toString());
        
    //     // Start 24-hour timer for auto-completion
    //     startCompletionTimer(data.id.toString());
        
    //     Get.back();
    //     Get.back();
    //     tourData.removeWhere((element) => element.id == data.id);
    //     Get.showSnackbar(CommonUI.SuccessSnackBar(
    //       title: 'Tour Request',
    //       message: response['message'].toString(),
    //     ));
    //   }
    //   // ... existing code for other cases ...
      
    //   update();
    // } catch (e) {
    //   Get.back();
    //   Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    // }
  }

  void startCompletionTimer(String tourId) {
    Future.delayed(const Duration(hours: 24), () async {
      try {
        final tour = await propertiesRepository.getTourRequest(tourId);
        if (!tour['user_confirmed_complete'] && tour['status'] != TourRequestStatus.disputed) {
          await propertiesRepository.autoCompleteTour(tourId);
          // Transfer funds to agent's wallet
        }
      } catch (e) {
        print('Error in completion timer: $e');
      }
    });
  }

  Future<void> openDispute(FetchPropertyTourData data) async {
    final result = await Get.dialog(
      DisputeDialog(
        tourData: data,
      ),
    );

    if (result != null) {
      try {
        CommonUI.loader();

        final Map<String, dynamic> paramdata = {
          'reason': result['reason'],
        };

        Map<String, List<XFile>> filesMap = {};

        if (result['evidence'] != null) {
          final XFile evidence = result['evidence'];
          
          // Verify file data before sending
          if (kIsWeb) {
            final bytes = await evidence.readAsBytes();
            if (bytes.isEmpty) {
              throw Exception('Selected file is empty');
            }
          } else {
            final file = File(evidence.path);
            if (!await file.exists() || await file.length() == 0) {
              throw Exception('Selected file is empty or does not exist');
            }
          }
          
          filesMap['evidence'] = [evidence];
        } else {
          // throw Exception('No evidence file selected');
        }
        
        final response = await DisputeRepository().openDispute(
          data.id.toString(),
          paramdata,
          filesMap
        );
        Get.back();
        Get.showSnackbar(CommonUI.SuccessSnackBar(
          title: 'Dispute Opened',
          message: response['message'].toString(),
        ));
        update();
      } catch (e) {
        Get.back();
        Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
      }
    }
  }

  Future<void> viewDisputeStatus(FetchPropertyTourData data) async {
   
   Get.toNamed('disputes');
  }

  Future<void> confirmTourCompletion(FetchPropertyTourData data) async {
    try {
      CommonUI.loader();
      final response = await propertiesRepository.confirmTourCompletion(data.id.toString());
      Get.back();
      Get.back();
      tourData.removeWhere((element) => element.id == data.id);
      Get.showSnackbar(CommonUI.SuccessSnackBar(
        title: 'Tour Request',
        message: response['message'].toString(),
      ));
      update();
    } catch (e) {
      Get.back();
      Get.showSnackbar(CommonUI.ErrorSnackBar(message: e.toString()));
    }
  }





    void onMessageClick(FetchPropertyTourData data) {
    String convId = CommonFun.getConversationId(
      AuthHelper.getUserId(), data.client?.id as int);

    ChatListItem? conversation = ChatListItem(
      chatTime: 0,
      unreadCount: 0,
      isTyping: false,
      user: ChatUsers(
        userId: data.client?.id.toString() ?? '',
        username: data.client?.name ?? '',
        email: data.client?.email ?? '',
        avatar: data.client?.avatar ?? '',
        name: data.client?.name ?? '',
      ),
    );

    List<String> propertyImage = [];
    data.property?.media?.forEach((element) {
      if (element.mediaTypeId != 7) {
        propertyImage.add(element.content ?? '');
      }
    });

    Get.to(
      () => MessageBox(
        conversation: conversation,
        screen: 1,
        onUpdateUser: (blockUnBlock) {
          update();
        },
      ),
    )?.then((value) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });

  }


      void onMessageClickAgent(FetchPropertyTourData data) {
    String convId = CommonFun.getConversationId(
      AuthHelper.getUserId(), data.property?.user?.id as int);

    ChatListItem? conversation = ChatListItem(
      chatTime: 0,
      unreadCount: 0,
      isTyping: false,
      user: ChatUsers(
        userId: data.property?.user?.id.toString() ?? '',
        username: data.property?.user?.username ?? '',
        email: data.property?.user?.email ?? '',
        avatar: data.property?.user?.avatar ?? '',
        name: data.property?.user?.fullname ?? '',
      ),
    );

    List<String> propertyImage = [];
    data.property?.media?.forEach((element) {
      if (element.mediaTypeId != 7) {
        propertyImage.add(element.content ?? '');
      }
    });

    Get.to(
      () => MessageBox(
        conversation: conversation,
        screen: 1,
        onUpdateUser: (blockUnBlock) {
          update();
        },
      ),
    )?.then((value) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });

  }

}
