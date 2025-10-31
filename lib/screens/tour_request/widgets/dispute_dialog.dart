import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/common/ui.dart';
import 'package:homy/models/tour/fetch_property_tour.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:io' show Platform, File;
import 'package:flutter/foundation.dart' show kIsWeb;

class DisputeDialog extends StatelessWidget {
  final FetchPropertyTourData tourData;
  final TextEditingController reasonController = TextEditingController();
  final Rx<XFile?> evidenceFile = Rx<XFile?>(null);
  final RxString evidenceFileName = ''.obs;

  DisputeDialog({
    Key? key,
    required this.tourData,
  }) : super(key: key);

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (kIsWeb) {
          // For web platform
          if (file.bytes != null) {
            evidenceFile.value = XFile.fromData(
              file.bytes!,
              name: file.name,
              mimeType: file.extension,
            );
            evidenceFileName.value = file.name;
          }
        } else {
          // For mobile platform
          if (file.path != null) {
            evidenceFile.value = XFile(file.path!);
            evidenceFileName.value = file.name;
          }
        }
      }
    } catch (e) {
      Get.showSnackbar(CommonUI.ErrorSnackBar(
        message: 'Error picking file: ${e.toString()}',
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Get.theme.colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.gavel_rounded,
                    color: Get.theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Open Dispute',
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Reason for Dispute',
              style: Get.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Explain your reason for dispute...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Get.theme.colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Get.theme.colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
                filled: true,
                fillColor: Get.theme.colorScheme.surface,
              ),
              maxLines: 4,
              style: Get.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Get.theme.colorScheme.outline.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file_rounded,
                      color: Get.theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Attach Evidence',
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: Get.theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => evidenceFile.value == null
                ? const SizedBox.shrink()
                : Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Get.theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.insert_drive_file_rounded,
                          color: Get.theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            evidenceFileName.value,
                            style: Get.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            evidenceFile.value = null;
                            evidenceFileName.value = '';
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: Get.theme.colorScheme.error,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  )),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: Get.theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (reasonController.text.trim().isEmpty) {
                        Get.showSnackbar(CommonUI.ErrorSnackBar(
                          message: 'Please provide a reason for the dispute',
                        ));
                        return;
                      }
                      // if (evidenceFile.value == null) {
                      //   Get.showSnackbar(CommonUI.ErrorSnackBar(
                      //     message: 'Please attach evidence for the dispute',
                      //   ));
                      //   return;
                      // }

                      // Verify file data
                      try {
                        if (kIsWeb) {
                          final bytes = await evidenceFile.value!.readAsBytes();
                          if (bytes.isEmpty) {
                            Get.showSnackbar(CommonUI.ErrorSnackBar(
                              message: 'Selected file is empty',
                            ));
                            return;
                          }
                        } else {
                          final file = File(evidenceFile.value!.path);
                          if (!await file.exists() || await file.length() == 0) {
                            Get.showSnackbar(CommonUI.ErrorSnackBar(
                              message: 'Selected file is empty or does not exist',
                            ));
                            return;
                          }
                        }
                      } catch (e) {
                        // Get.showSnackbar(CommonUI.ErrorSnackBar(
                        //   message: 'Error verifying file: ${e.toString()}',
                        // ));
                        // return;
                      }

                      Get.back(result: {
                        'reason': reasonController.text,
                        'evidence': evidenceFile.value,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Get.theme.colorScheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Submit',
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: Get.theme.colorScheme.onError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 