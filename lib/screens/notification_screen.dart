import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/notification_provider.dart';


class NotificationScreen extends ConsumerStatefulWidget {
  static const String routeName = '/notification';
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
   List notifications = [];


  
  @override
  Widget build(BuildContext context) {
     
   
   

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ref.watch(notificationProvider).isEmpty
          ? const Center(
              child: Text('No notifications available'),
            )
          : ListView.builder(
              itemCount: ref.watch(notificationProvider).length,
                itemBuilder: (context, index) {
                int backIndex = ref.watch(notificationProvider).length - 1 - index;
                final notification = ref.watch(notificationProvider)[backIndex];
                final shortenTimestamp = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';

                return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                title: Text(notification.message),
                subtitle: Text(shortenTimestamp),
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(notification.iconLink),
                ),
                );
                },
            ),
    );
  }
}