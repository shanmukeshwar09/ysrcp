import 'dart:convert';

import 'package:http/http.dart';

class Notifications {
  static final Client client = Client();

  static const String serverKey =
      'AAAAhitRyVM:APA91bGKUlfXWUCHtxtxxALCZ8vG8SSi08Uxm8kNED_Ikx-evpWV99_WGGuJF4ZdtDJg0qVF-8k4SSMcRfQSWxeTAgX26GttN7Vbf53P1Tmef186JwF5pPuBO0Eff7rGI0ypAEsUHg5i';

  Future pushNotification(String title, String body, String topic) async {
    client.post(
      'https://fcm.googleapis.com/fcm/send',
      body: json.encode({
        'notification': {'body': '$body', 'title': '$title'},
        'data': {
          'title': '$title',
          'body': '$body',
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'to': '/topics/$topic',
      }),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
    );
  }
}
