import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserReportDialog extends StatefulWidget {
  final String userId;
  final String userName;

  const UserReportDialog({
    Key? key,
    required this.userId,
    required this.userName,
  }) : super(key: key);

  @override
  State<UserReportDialog> createState() => _UserReportDialogState();
}

class _UserReportDialogState extends State<UserReportDialog> {
  final _reasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedReason;
  bool _isSubmitting = false;

  final List<String> _reportReasons = [
    'Inappropriate Content',
    'Harassment',
    'False Information',
    'Spam',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: const Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.report_problem_outlined, 
                       color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Report ${widget.userName}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Why are you reporting this user?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  labelText: 'Select Reason',
                  prefixIcon: const Icon(Icons.warning_amber_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a reason';
                  }
                  return null;
                },
                items: _reportReasons
                    .map((reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reason),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedReason = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  labelText: 'Additional Details',
                  hintText: 'Please provide more information...',
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (_selectedReason == 'Other' && 
                      (value == null || value.trim().length < 10)) {
                    return 'Please provide at least 10 characters of detail';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, 
                        vertical: 12,
                      ),
                    ),
                    child: Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting 
                        ? null 
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _isSubmitting = true;
                              });
                              
                              // Simulate API call
                              // await Future.delayed(
                              //   const Duration(seconds: 1),
                              // );
                              
                              Get.back(result: {
                                'reason': _selectedReason,
                                'details': _reasonController.text,
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, 
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Submit Report'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
} 