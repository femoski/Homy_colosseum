// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:homy/screens/auth/controllers/auth_controller.dart';
// import 'package:hugeicons/hugeicons.dart';
// import '../../../../../utils/constants/sizes.dart';
// import '../../../../../utils/constants/text_strings.dart';


// class MLoginForm extends  GetView<AuthController> {
  
//   const MLoginForm({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // final controller = Get.put(SignupController());
//     controller.loginFormKey = GlobalKey<FormState>();

//     return Form(
//       key: controller.loginFormKey,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
//         child: Column(
//           children: [
//             TextFormField(
            
//               decoration: InputDecoration(
//                   prefixIcon: Icon(HugeIcons.strokeRoundedInbox,), labelText: 'Email or Username'),
//             ),
//             SizedBox(height: AppSizes.xl),
//             Obx(
//                   () => TextFormField(
//                 controller: controller.password,
//                 obscureText: controller.hidePassword.value,
                
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(HugeIcons.strokeRoundedLockPassword),
//                   labelText: MTexts.password,
//                   suffixIcon: IconButton(
//                     onPressed: () => controller.hidePassword.value =
//                     !controller.hidePassword.value,
//                     icon: Icon(controller.hidePassword.value
//                         ? HugeIcons.strokeRoundedView
//                         : HugeIcons.strokeRoundedViewOffSlash),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: AppSizes.sm),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(''),
//                 // TextButton(
//                 //   onPressed: () => Get.to(() => ForgotPasswordScreen()),
//                 //   child: Text(MTexts.forgotPassword),
//                 // )
//               ],
//             ),
//             SizedBox(height: AppSizes.sm),
//             SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                      onPressed: () async {

//                         // await Future.delayed(Duration(seconds: 10));

//                         // await controller.login();
//                       },
                      
//                   child: Text(MTexts.signIn))),
//             SizedBox(height: AppSizes.md),
//             SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                     onPressed: () => null,
//                     child: Text(MTexts.createAccount))),
//             SizedBox(height: AppSizes.sm),
//           ],
//         ),
//       ),
//     );
//   }
// }
