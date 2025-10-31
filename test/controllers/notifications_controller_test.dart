import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:homy/controllers/notifications_controller.dart';
import 'package:homy/models/notifications/notification_model.dart';
import 'package:homy/repositories/notifications/notifications_repository.dart';
import 'package:homy/services/notifications/notification_storage_service.dart';

import 'notifications_controller_test.mocks.dart';

@GenerateMocks([NotificationsRepository, NotificationStorageService])
void main() {
  group('NotificationsController', () {
    late NotificationsController controller;
    late MockNotificationsRepository mockRepository;
    late MockNotificationStorageService mockStorageService;

    setUp(() {
      mockRepository = MockNotificationsRepository();
      mockStorageService = MockNotificationStorageService();
      
      // Initialize GetX
      Get.testMode = true;
      
      controller = NotificationsController();
      // In a real implementation, you would inject these dependencies
    });

    tearDown(() {
      Get.reset();
    });

    group('loadNotifications', () {
      test('should load notifications from repository', () async {
        // Arrange
        final mockNotifications = [
          NotificationModel(
            id: 1,
            type: NotificationType.general,
            title: 'Test Notification',
            message: 'Test message',
            createdAt: DateTime.now(),
          ),
        ];

        when(mockRepository.getGeneralNotifications())
            .thenAnswer((_) async => NotificationResponse(
                  data: mockNotifications,
                  meta: NotificationMeta(page: 1, limit: 20, total: 1, totalPages: 1),
                ));

        when(mockRepository.getPersonalNotifications())
            .thenAnswer((_) async => NotificationResponse(
                  data: [],
                  meta: NotificationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
                ));

        // Act
        await controller.loadNotifications();

        // Assert
        expect(controller.generalNotifications.length, 1);
        expect(controller.generalNotifications.first.title, 'Test Notification');
      });
    });

    group('markAsRead', () {
      test('should mark notification as read', () async {
        // Arrange
        final notification = NotificationModel(
          id: 1,
          type: NotificationType.general,
          title: 'Test Notification',
          message: 'Test message',
          createdAt: DateTime.now(),
          isRead: false,
        );

        when(mockRepository.markAsRead(any))
            .thenAnswer((_) async {});

        when(mockStorageService.markAsRead(any))
            .thenAnswer((_) async {});

        // Act
        await controller.markAsRead(notification);

        // Assert
        verify(mockRepository.markAsRead(1)).called(1);
        verify(mockStorageService.markAsRead(1)).called(1);
      });
    });

    group('deleteNotification', () {
      test('should delete notification', () async {
        // Arrange
        final notification = NotificationModel(
          id: 1,
          type: NotificationType.general,
          title: 'Test Notification',
          message: 'Test message',
          createdAt: DateTime.now(),
        );

        when(mockRepository.deleteNotification(any))
            .thenAnswer((_) async {});

        when(mockStorageService.markAsDeleted(any))
            .thenAnswer((_) async {});

        // Act
        await controller.deleteNotification(notification);

        // Assert
        verify(mockRepository.deleteNotification(1)).called(1);
        verify(mockStorageService.markAsDeleted(1)).called(1);
      });
    });

    group('changeTab', () {
      test('should change selected tab', () {
        // Arrange
        expect(controller.selectedTab, 0);

        // Act
        controller.changeTab(1);

        // Assert
        expect(controller.selectedTab, 1);
      });
    });

    group('addNotification', () {
      test('should add new notification to appropriate list', () async {
        // Arrange
        final notification = NotificationModel(
          id: 1,
          type: NotificationType.general,
          title: 'New Notification',
          message: 'New message',
          createdAt: DateTime.now(),
        );

        when(mockStorageService.addNotification(any))
            .thenAnswer((_) async {});

        // Act
        await controller.addNotification(notification);

        // Assert
        expect(controller.generalNotifications.length, 1);
        expect(controller.generalNotifications.first.title, 'New Notification');
        verify(mockStorageService.addNotification(notification)).called(1);
      });
    });

    group('refreshNotifications', () {
      test('should refresh notifications and reset pagination', () async {
        // Arrange
        when(mockRepository.getGeneralNotifications())
            .thenAnswer((_) async => NotificationResponse(
                  data: [],
                  meta: NotificationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
                ));

        when(mockRepository.getPersonalNotifications())
            .thenAnswer((_) async => NotificationResponse(
                  data: [],
                  meta: NotificationMeta(page: 1, limit: 20, total: 0, totalPages: 0),
                ));

        when(mockRepository.getUnreadCount())
            .thenAnswer((_) async => 0);

        // Act
        await controller.refreshNotifications();

        // Assert
        expect(controller.currentGeneralPage, 1);
        expect(controller.currentPersonalPage, 1);
        expect(controller.hasMoreGeneral, true);
        expect(controller.hasMorePersonal, true);
      });
    });
  });
}
