import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homy/models/tour/fetch_property_tour.dart';
import 'package:homy/models/property/property_data.dart';
import 'package:homy/models/users/fetch_user.dart';
import 'package:homy/models/media.dart';
import 'package:homy/screens/tour_request/views/enhanced_tour_request_sheet.dart';
import 'package:homy/screens/tour_request/controllers/tour_requests_controller.dart';

class EnhancedTourDemo extends StatelessWidget {
  const EnhancedTourDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Tour Request Demo'),
        backgroundColor: Get.theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDemoCard(
              'Pending Tour Request',
              'View a tour request that is waiting for agent response',
              Colors.orange,
              () => _showDemoSheet(0),
            ),
            const SizedBox(height: 16),
            _buildDemoCard(
              'Confirmed Tour Request',
              'View a tour request that has been confirmed by the agent',
              Colors.green,
              () => _showDemoSheet(1),
            ),
            const SizedBox(height: 16),
            _buildDemoCard(
              'Completed Tour Request',
              'View a tour request that has been completed',
              Colors.blue,
              () => _showDemoSheet(2),
            ),
            const SizedBox(height: 16),
            _buildDemoCard(
              'Disputed Tour Request',
              'View a tour request with an open dispute',
              Colors.red,
              () => _showDemoSheet(3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(String title, String description, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.home_work_outlined,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDemoSheet(int status) {
    final demoData = _createDemoData(status);
    final controller = TourRequestsController(0, 0);
    
    Get.bottomSheet(
      EnhancedTourRequestSheet(
        data: demoData,
        controller: controller,
      ),
      isScrollControlled: true,
    );
  }

  FetchPropertyTourData _createDemoData(int status) {
    final property = PropertyData(
      id: 1,
      title: "Luxury 3-Bedroom Apartment with Sea View",
      address: "123 Ocean Drive, Miami Beach, FL 33139",
      bedrooms: 3,
      bathrooms: 2,
      area: 1500.0,
      tourBookingFee: "1500",
      media: [
        Media(
          id: 1,
          content: "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&q=80",
          mediaTypeId: 1,
        ),
      ],
      user: UserData(
        id: 1,
        fullname: "Sarah Johnson",
        email: "sarah.johnson@realestate.com",
        avatar: "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&q=80",
        verificationStatus: 1,
        followers: 250,
        following: 180,
      ),
    );

    String completionStatus = 'pending';
    if (status == 2) {
      completionStatus = 'agent_marked';
    } else if (status == 3) {
      completionStatus = 'disputed';
    }

    return FetchPropertyTourData(
      id: 101,
      userId: 201,
      propertyId: 1,
      propertyUserId: 1,
      timeZone: "2024-03-20 14:30:00",
      tourStatus: status,
      tourStatusText: _getStatusText(status),
      createdAt: "2024-03-15T10:30:00Z",
      updatedAt: "2024-03-15T10:30:00Z",
      tourTime: "2:30 PM",
      completionStatus: completionStatus,
      property: property,
    );
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'Pending';
      case 1:
        return 'Confirmed';
      case 2:
        return 'Completed';
      case 3:
        return 'Disputed';
      default:
        return 'Unknown';
    }
  }
} 