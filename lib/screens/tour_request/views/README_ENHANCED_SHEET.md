# Enhanced Tour Request Sheet

## Overview

The `EnhancedTourRequestSheet` is a comprehensive tour request detail view that provides detailed information about booking, agent, payment, and status tracking with modern UI/UX features.

## Features

### 🏠 Property Information
- **High-quality property images** with proper aspect ratio
- **Property details** including title, address, bedrooms, bathrooms, and area
- **Visual property features** with icons for beds, baths, and square footage

### 👤 Agent Information
- **Agent profile** with avatar, name, and contact details
- **Verification status** indicator (verified/unverified)
- **Contact agent** button for direct communication
- **Agent statistics** (followers, following)

### 💰 Payment Details
- **Tour fee breakdown** with platform fees
- **Total amount calculation**
- **Payment status** indicator
- **Transparent pricing** display

### 📅 Booking Details
- **Tour date and time** information
- **Request creation date**
- **Time zone** information
- **Formatted date display**

### 📊 Status Timeline
- **Visual timeline** showing tour progress
- **Status indicators** with icons and colors
- **Progress tracking** from request to completion
- **Interactive status updates**

### 🎨 Modern UI Features
- **Backdrop blur** effect for modern look
- **Smooth animations** and transitions
- **Responsive design** that adapts to screen size
- **Material Design 3** color scheme
- **Custom status chips** with dynamic colors

### ⚡ Interactive Actions
- **Accept/Decline** tour requests (for agents)
- **Mark as completed** functionality
- **Open disputes** with evidence upload
- **View dispute status** tracking
- **Navigate to property details**

## Usage

### Basic Implementation

```dart
// In your controller
void onPropertyCardClick(FetchPropertyTourData data, TourRequestsController controller) {
  Get.bottomSheet(
    EnhancedTourRequestSheet(
      data: data,
      controller: controller,
    ),
    isScrollControlled: true,
  );
}
```

### Demo Implementation

```dart
// Navigate to demo screen
Get.to(() => const EnhancedTourDemo());
```

## Data Structure

The sheet expects a `FetchPropertyTourData` object with the following key properties:

```dart
class FetchPropertyTourData {
  int? id;                    // Tour request ID
  int? userId;                // User who booked
  int? propertyId;            // Property ID
  int? propertyUserId;        // Agent ID
  String? timeZone;           // Tour timezone
  int? tourStatus;            // Current status (0=pending, 1=confirmed, etc.)
  String? tourStatusText;     // Human-readable status
  String? createdAt;          // Request creation date
  String? tourTime;           // Scheduled tour time
  String? completionStatus;   // Completion status
  PropertyData? property;     // Property details
}
```

## Status Types

| Status | Code | Description |
|--------|------|-------------|
| Pending | 0 | Waiting for agent response |
| Confirmed | 1 | Tour has been confirmed |
| Completed | 2 | Tour has been completed |
| Declined | 3 | Tour request was declined |
| Disputed | 4 | Dispute has been opened |
| Refunded | 7 | Tour has been refunded |

## Completion Status Types

| Status | Description |
|--------|-------------|
| pending | Tour is pending completion |
| agent_marked | Agent marked as completed, waiting for user confirmation |
| user_confirmed | User confirmed completion |
| disputed | Dispute opened |
| auto_confirmed | Automatically confirmed after time period |

## Customization

### Colors and Themes
The sheet automatically adapts to your app's theme using `Get.theme.colorScheme`.

### Status Colors
- **Pending**: Orange
- **Confirmed**: Green  
- **Completed**: Blue
- **Disputed**: Red
- **Refunded**: Blue

### Action Buttons
Buttons are dynamically shown based on tour status and user role (agent vs user).

## Cool Features

### 🎯 Smart Status Tracking
- Real-time status updates
- Visual progress indicators
- Timeline-based status display

### 💬 Agent Communication
- Direct contact options
- Agent verification badges
- Professional agent profiles

### 💳 Payment Transparency
- Clear fee breakdown
- Platform fee disclosure
- Payment status indicators

### 📱 Responsive Design
- Adapts to different screen sizes
- Smooth scrolling experience
- Touch-friendly interface

### 🎨 Modern Animations
- Backdrop blur effects
- Smooth transitions
- Loading states

## Integration

1. **Import the enhanced sheet**:
```dart
import 'package:homy/screens/tour_request/views/enhanced_tour_request_sheet.dart';
```

2. **Update your controller** to use the enhanced sheet:
```dart
Get.bottomSheet(
  EnhancedTourRequestSheet(data: data, controller: controller),
);
```

3. **Test with demo data**:
```dart
Get.to(() => const EnhancedTourDemo());
```

## Dependencies

- `flutter/material.dart`
- `get/get.dart`
- `intl/intl.dart`
- Custom models: `FetchPropertyTourData`, `PropertyData`, `UserData`
- Common widgets: `ImageWidget`, `CommonUI`

## Future Enhancements

- [ ] Add real-time chat integration
- [ ] Implement push notifications for status updates
- [ ] Add tour scheduling calendar integration
- [ ] Include property virtual tour links
- [ ] Add payment method selection
- [ ] Implement tour rating and review system 