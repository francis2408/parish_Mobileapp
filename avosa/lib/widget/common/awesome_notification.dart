import 'package:avosa/widget/theme_color/theme_color.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class MyNotificationService {
  static Future<void> init() async {
    AwesomeNotifications().initialize(
      'resource://drawable/app_icon',
      [
        NotificationChannel(
          channelKey: 'my_topic_channel_id',
          channelName: 'My Topic Channel Name',
          channelDescription: 'Channel for news notifications',
          defaultColor: whiteColor,
          ledColor: greenColor,
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
        id: 0,
        channelKey: 'your_channel_key',
        title: title,
        body: body,
      ),
    );
  }
}
