import 'package:firebase_database/firebase_database.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/utilities/database_helper.dart';

class Notification {
  final String message;
  final String iconLink;
  final DateTime timestamp;
  Notification(this.message, this.iconLink, this.timestamp);
}

@riverpod
class NotificationProvider extends Notifier<List<Notification>> {
  @override
  List<Notification> build() => [];

  void addNotification(String message, String iconLink) {
    final newNotification = Notification(message, iconLink, DateTime.now());
    state = [...state, newNotification];
    ref.read(unreadNotificationProvider.notifier).addUnreadNotification();
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
