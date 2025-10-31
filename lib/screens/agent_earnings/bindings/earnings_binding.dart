import 'package:get/get.dart';
import 'package:homy/screens/agent_earnings/controllers/earnings_controller.dart';

class EarningsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EarningsController>(() => EarningsController());
  }
} 