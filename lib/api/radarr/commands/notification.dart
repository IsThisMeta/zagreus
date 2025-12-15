part of radarr_commands;

/// Facilitates notification-related API calls.
///
/// [RadarrCommandHandlerNotification] gives access to notification (webhooks, connections, etc.) API calls.
class RadarrCommandHandlerNotification {
  final Dio _client;

  /// Create a notification command handler using an initialized [Dio] client.
  RadarrCommandHandlerNotification(this._client);

  /// Get all notifications.
  ///
  /// Returns a list of all notifications (connections) configured in Radarr.
  Future<List<RadarrNotification>> getAll() async {
    Response response = await _client.get('notification');
    return (response.data as List).map((notification) => RadarrNotification.fromJson(notification)).toList();
  }

  /// Get a single notification by its database ID.
  ///
  /// Required Parameters:
  /// - `notificationId`: Database ID for the notification
  Future<RadarrNotification> get({
    required int notificationId,
  }) async {
    Response response = await _client.get('notification/$notificationId');
    return RadarrNotification.fromJson(response.data);
  }

  /// Create a new notification.
  ///
  /// Required Parameters:
  /// - `notification`: The notification to be created
  ///
  /// Returns the created [RadarrNotification] object.
  Future<RadarrNotification> create({
    required RadarrNotification notification,
  }) async {
    Response response = await _client.post(
      'notification',
      data: notification.toJson(),
    );
    return RadarrNotification.fromJson(response.data);
  }

  /// Update a notification.
  ///
  /// Required Parameters:
  /// - `notification`: The notification with updated values (must include ID)
  ///
  /// Returns the updated [RadarrNotification] object.
  Future<RadarrNotification> update({
    required RadarrNotification notification,
  }) async {
    assert(notification.id != null, 'Notification ID is required for update');
    Response response = await _client.put(
      'notification/${notification.id}',
      data: notification.toJson(),
    );
    return RadarrNotification.fromJson(response.data);
  }

  /// Delete a notification.
  ///
  /// Required Parameters:
  /// - `notificationId`: Database ID for the notification
  ///
  /// Returns `true` if the notification was deleted successfully.
  Future<bool> delete({
    required int notificationId,
  }) async {
    Response response = await _client.delete('notification/$notificationId');
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Test a notification.
  ///
  /// Required Parameters:
  /// - `notification`: The notification to test
  ///
  /// Returns `true` if the test was successful.
  Future<bool> test({
    required RadarrNotification notification,
  }) async {
    Response response = await _client.post(
      'notification/test',
      data: notification.toJson(),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  /// Get notification schema.
  ///
  /// Required Parameters:
  /// - `implementation`: The notification implementation (e.g., 'Webhook')
  ///
  /// Returns the schema for the specified notification type.
  Future<List<RadarrNotificationField>> getSchema({
    required String implementation,
  }) async {
    Response response = await _client.get('notification/schema', queryParameters: {
      'implementation': implementation,
    });
    return (response.data as List).map((field) => RadarrNotificationField.fromJson(field)).toList();
  }
}