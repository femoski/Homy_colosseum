import 'package:get/get.dart';
import 'package:homy/models/dispute/dispute_model.dart';
import 'package:homy/repositories/dispute_repository.dart';

class DisputeListController extends GetxController {
  final RxList<Dispute> disputes = <Dispute>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<String?> error = Rx<String?>(null);
  final DisputeRepository _disputeRepository = DisputeRepository();
  @override
  void onInit() {
    super.onInit();
    fetchDisputes();
  }

  Future<void> fetchDisputes() async {
    try {
      isLoading.value = true;
      error.value = null;
      final response = await _disputeRepository.getDisputes();
      print(response);
      disputes.value = response;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void onDisputeTap(Dispute dispute) {
    Get.toNamed('/dispute/communication/${dispute.id}');
  }
} 