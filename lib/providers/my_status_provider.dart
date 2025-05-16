import 'package:mau_friend/utilities/location_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/utilities/location_helper.dart';

@riverpod
class MyStatusTextProvider extends Notifier<String> {
  @override
  String build() => '';

  //keep user's basic profile
  void updateMyStatus(UserStatus status)  {
    //save to riverpod
    print('updating state to ${status.status}');
    state = status.status;
    print('updated state to ${state}');
  }
}

final myStatusTextProvider = NotifierProvider<MyStatusTextProvider, String>(
  MyStatusTextProvider.new,
);

@riverpod
class MyStatusIconProvider extends Notifier<String> {
  @override
  String build() => '';

  //keep user's basic profile
  void updateMyStatus(UserStatus status)  {
    //save to riverpod
    print('updating state to ${status.status}');
    state = status.icon;
    print('updated state to ${state}');
  }
}

final myStatusIconProvider = NotifierProvider<MyStatusIconProvider, String>(
  MyStatusIconProvider.new,
);
