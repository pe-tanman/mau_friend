import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/utilities/database_helper.dart';

class Notification {
  final String body;
  final String iconLink;
  final DateTime timestamp;
  final String type;
  final String senderUID;
  final String? message;
  Notification(this.body, this.iconLink, this.timestamp, this.type, this.senderUID, {this.message});
}
@riverpod
class NotificationProvider extends Notifier<List<Notification>> {
  @override
  List<Notification> build() => [];

  void loadNotification() {
    FirestoreHelper().getNotifications().then((value) {
      List<Notification> result = [];
      for (var element in value) {
        var datetime = element['timestamp'].toDate();
        var type = element['type'] ?? 'General';
        result.add(
          Notification(
            element['body'],
            element['imageUrl'] ?? Statics.defaultIconLink,
            datetime,
            type,
            element['senderUID'],
            message: element['message'],
          ),
        );
      }
      state = result;
    });
  }
}

final notificationProvider =
    NotifierProvider<NotificationProvider, List<Notification>>(
      NotificationProvider.new,
    );

@riverpod
class UnreadNotificationProvider extends Notifier<int> {
  @override
  int build() => 0;

  void addUnreadNotification() {
    state = state + 1;
  }

  void resetUnreadNotification() {
    state = 0;
  }
}

final unreadNotificationProvider =
    NotifierProvider<UnreadNotificationProvider, int>(
      UnreadNotificationProvider.new,
    );
