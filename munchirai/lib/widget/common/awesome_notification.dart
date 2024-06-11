import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:munchirai/widget/theme_color/theme_color.dart';

class MyNotificationService {
  static Future<void> init() async {
    AwesomeNotifications().initialize(
      'resource://drawable/app_icon',
      [
        NotificationChannel(
          channelKey: 'my_topic_channel_id',
          channelName: 'My Topic Channel Name',
          channelDescription: 'Channel for news notifications',
          defaultColor: buttonLabel,
          ledColor: buttonGreen,
          enableLights: true,
          enableVibration: true,
        ),
      ],
    );
  }

  static void showNotification({
    required String title,
    required String body,
    required String payload,
    List<NotificationActionButton>? actionButtons,
  }) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0, // Notification ID (can be any unique ID)
        channelKey: 'your_channel_key', // Replace with your own channel key
        title: title, // Notification title
        body: body, // Notification body
      ),
    );
  }
}
