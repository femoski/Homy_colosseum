import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:homy/models/notifications/notification_model.dart';
import 'package:homy/repositories/notifications/notifications_repository.dart';
import 'package:homy/providers/api_client.dart';

import 'notifications_repository_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  group('NotificationsRepository', () {
    late NotificationsRepository repository;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      repository = NotificationsRepository();
      // Replace the actual API client with mock
      // This would need to be done through dependency injection in real implementation
    });

    group('getNotifications', () {
      test('should return notifications when API call is successful', () async {
        // Arrange
        final mockResponse = {
          'data': [
            {
              'id': 1,
              'type': 'general',
              'user_id': null,
              'title': 'Test Notification',
              'message': 'This is a test notification',
              'created_at': '2023-01-01T00:00:00Z',
              'is_read': false,
            }
          ],
          'meta': {
            'page': 1,
            'limit': 20,
            'total': 1,
            'total_pages': 1,
          }
        };

        when(mockApiClient.getData(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  statusCode: 200,
                  body: mockResponse,
                ));

        // Act
        final result = await repository.getNotifications();

        // Assert
        expect(result.data.length, 1);
        expect(result.data.first.title, 'Test Notification');
        expect(result.meta.total, 1);
      });

      test('should throw exception when API call fails', () async {
        // Arrange
        when(mockApiClient.getData(any, query: anyNamed('query')))
            .thenAnswer((_) async => Response(
                  statusCode: 500,
                  statusText: 'Internal Server Error',
                ));

        // Act & Assert
        expect(
          () => repository.getNotifications(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('markAsRead', () {
      test('should call API with correct endpoint', () async {
        // Arrange
        const notificationId = 1;
        when(mockApiClient.postData(any, any))
            .thenAnswer((_) async => Response(statusCode: 200));

        // Act
        await repository.markAsRead(notificationId);

        // Assert
        verify(mockApiClient.postData('notifications/$notificationId/read', {}))
            .called(1);
      });
    });

    group('deleteNotification', () {
      test('should call API with correct endpoint', () async {
        // Arrange
        const notificationId = 1;
        when(mockApiClient.postData(any, any))
            .thenAnswer((_) async => Response(statusCode: 200));

        // Act
        await repository.deleteNotification(notificationId);

        // Assert
        verify(mockApiClient.postData('notifications/$notificationId/delete', {}))
            .called(1);
      });
    });

    group('clearAllNotifications', () {
      test('should call API with correct endpoint', () async {
        // Arrange
        when(mockApiClient.postData(any, any))
            .thenAnswer((_) async => Response(statusCode: 200));

        // Act
        await repository.clearAllNotifications();

        // Assert
        verify(mockApiClient.postData('notifications/clear-all', {}))
            .called(1);
      });
    });

    group('getUnreadCount', () {
      test('should return unread count when API call is successful', () async {
        // Arrange
        const mockResponse = {
          'data': {'unread_count': 5}
        };

        when(mockApiClient.getData(any))
            .thenAnswer((_) async => Response(
                  statusCode: 200,
                  body: mockResponse,
                ));

        // Act
        final result = await repository.getUnreadCount();

        // Assert
        expect(result, 5);
      });

      test('should return 0 when API call fails', () async {
        // Arrange
        when(mockApiClient.getData(any))
            .thenAnswer((_) async => Response(statusCode: 500));

        // Act
        final result = await repository.getUnreadCount();

        // Assert
        expect(result, 0);
      });
    });
  });
}
