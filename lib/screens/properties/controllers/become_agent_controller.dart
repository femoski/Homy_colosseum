import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/repositories/user_repository.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/agent_registration_success_dialog.dart';

class BecomeAgentController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final businessNameController = TextEditingController();
  final businessAddressController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalIdController = TextEditingController();

  // Add new controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final experienceController = TextEditingController();
  final websiteController = TextEditingController();

  final UserRepository _userRepository = UserRepository();
  bool isLoading = false;
  bool isRegistrationPending = false;

  // Add controllers for new fields
  XFile? cacDocument;
  XFile? agencyLogo;
  XFile? idCardPhoto;
  XFile? idCardSelfiePhoto;

  final ImagePicker _picker = ImagePicker();

  // Add loading state for initial check
  bool isCheckingRegistration = false;

  bool showIdCardError = false;
  bool showIdCardSelfieError = false;

  // Add this property to track the current step
  int currentStep = 0;

  // Add these form keys for each step
  final personalInfoFormKey = GlobalKey<FormState>();
  final businessDetailsFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    checkExistingRegistration();
  }

  Future<void> checkExistingRegistration() async {
    try {
      isCheckingRegistration = true;
      update();
      
      final response = await _userRepository.checkAgentRegistration();
      
      if (response['status'] == 'pending') {
        isRegistrationPending = true;
          //  Get.back(); // Go back to previous screen
        // Get.showSnackbar(CommonUI.infoSnackBar(
        //   message: 'You already have a pending agent registration. Please wait for approval.',
        // ));
        update();
      }
    } catch (e) {
      // Handle error or continue if no existing registration
    } finally {
      isCheckingRegistration = false;
      update();
    }
  }

  Future<void> pickCACDocument() async {
    try {
      final XFile? document = await _picker.pickImage(source: ImageSource.gallery);
      if (document != null) {
        cacDocument = document;
        update();
      }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Error picking CAC document',
      ));
    }
  }

  Future<void> captureIdWithSelfie() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
      );
      if (photo != null) {
        idCardSelfiePhoto = photo;
        showIdCardSelfieError = false;
        update();
      }
    } catch (e) {
      print('Error capturing ID with selfie: $e');
    }
  }

  Future<void> pickAgencyLogo() async {
    try {
      final XFile? logo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (logo != null) {
        agencyLogo = logo;
        update();
      }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Error picking agency logo',
      ));
    }
  }

  Future<void> submitRegistration() async {


    // if (formKey.currentState!.validate()) {
          Get.log('submitRegistration');
      if (idCardPhoto == null) {
        showIdCardError = true;
        update();
      }
      if (idCardSelfiePhoto == null) {
        showIdCardSelfieError = true;
        update();
      }
      if (idCardPhoto == null && idCardSelfiePhoto == null) {
        return;
      }
      try {
        isLoading = true;
        update();

        final Map<String, dynamic> data = {
          'business_name': businessNameController.text,
          'business_address': businessAddressController.text,
          'license_number': licenseNumberController.text,
          'business_phone': phoneController.text,
          'full_name': fullNameController.text,
          'email': emailController.text,
          'experience': experienceController.text,
          'nin': nationalIdController.text,
          'website': websiteController.text,
        };

        if (cacDocument != null) {
          data['cac_document'] = cacDocument!.path;
        }

        // Add both ID card photos to the data
        data['id_card_photo'] = idCardPhoto!.path;
        data['id_card_selfie_photo'] = idCardSelfiePhoto!.path;

        Map<String, List<XFile>> filesMap = {};

        if (cacDocument != null) {
          filesMap['cac_document'] = [cacDocument!];
        }

        // Add both ID card photos to the files map
        filesMap['id_card_photo'] = [idCardPhoto!];
        filesMap['id_card_selfie_photo'] = [idCardSelfiePhoto!];

        final response = await _userRepository.registerAsAgent(data, filesMap);

        if (response['status'] == 200) {
          Get.dialog(
            const AgentRegistrationSuccessDialog(),
            barrierDismissible: false,
          );
        } else {
          Get.showSnackbar(CommonUI.ErrorSnackBar(
            message: response['message'] ?? 'Registration failed',
          ));
        }
      } catch (e) {
        Get.showSnackbar(CommonUI.ErrorSnackBar(
          message: 'An error occurred. Please try again. $e',
        ));
      } finally {
        isLoading = false;
        update();
      }
    
  }

  // Add a separate method for capturing ID card photo
  Future<void> captureIdCard() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        idCardPhoto = photo;
        showIdCardError = false;
        update();
      }
    } catch (e) {
      print('Error capturing ID card: $e');
    }
  }

  // Add method to validate current step
  bool validateCurrentStep() {
    switch (currentStep) {
      case 0:
        return personalInfoFormKey.currentState?.validate() ?? false;
      case 1:
        return businessDetailsFormKey.currentState?.validate() ?? false;
      case 2:
        // For document upload step, check required documents
        bool isValid = true;
        if (idCardPhoto == null) {
          showIdCardError = true;
          isValid = false;
        }
        if (idCardSelfiePhoto == null) {
          showIdCardSelfieError = true;
          isValid = false;
        }
        update();
        return isValid;
      default:
        return false;
    }
  }

  // Method to handle step continuation
  void goToNextStep() {
    if (validateCurrentStep()) {
      if (currentStep < 2) {
        currentStep++;
        update();
      } else {
        submitRegistration();
      }
    }
  }

  @override
  void onClose() {
    businessNameController.dispose();
    businessAddressController.dispose();
    licenseNumberController.dispose();
    phoneController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    experienceController.dispose();
    websiteController.dispose();
    super.onClose();
  }
} 