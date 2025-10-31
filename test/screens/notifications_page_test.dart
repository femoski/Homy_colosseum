import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:homy/controllers/notifications_controller.dart';
import 'package:homy/models/notifications/notification_model.dart';
import 'package:homy/screens/notifications/notifications_page.dart';

void main() {
  group('NotificationsPage', () {
    late NotificationsController mockController;

    setUp(() {
      Get.testMode = true;
      mockController = Get.put(NotificationsController());
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('should display app bar with title', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: const NotificationsPage(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should display tab bar with General and Personal tabs', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: const NotificationsPage(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
    });

    testWidgets('should display empty state when no notifications', (WidgetTester tester) async {
      // Arrange
      mockController.generalNotifications.clear();
      mockController.personalNotifications.clear();

      await tester.pumpWidget(
        GetMaterialApp(
          home: const NotificationsPage(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No General Notifications'), findsOneWidget);
    });

    testWidgets('should display loading state when loading', (WidgetTester tester) async {
      // Arrange
      mockController.isLoading.value = true;

      await tester.pumpWidget(
        GetMaterialApp(
          home: const NotificationsPage(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should display notifications list when notifications exist', (WidgetTester tester) async {
      // Arrange
      final notification = NotificationModel(
        id: 1,
        type: NotificationType.general,
        title: 'Test Notification',
        message: 'Test message',
        createdAt: DateTime.now(),
      );

      mockController.generalNotifications.add(notification);

      await tester.pumpWidget(
        GetMaterialApp(
          home: const NotificationsPage(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Notification'), findsOneWidget);
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('should show error state when error occurs', (WidgetTester tester) async {
      // Arrange
      mockController.error.value = 'Test error message';

      await tester.pumpWidget(
        GetMaterialApp(
          home: const NotificationsPage(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Test error message'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('should display unread count badge when unread notifications exist', (WidgetTester tester) async {
      // Arrange
      mockController.unreadCount.value = 5;

      await tester.pumpWidget(
        GetMaterialApp(
          home: const NotificationsPage(),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should show popup menu when more button is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: const NotificationsPage(),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Mark All Read'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('should switch tabs when tab is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        GetMaterialApp(
          home: const NotificationsPage(),
        ),
      );

      // Act
      await tester.tap(find.text('Personal'));
      await tester.pumpAndSettle();

      // Assert
      expect(mockController.selectedTab, 1);
    });
  });
}
