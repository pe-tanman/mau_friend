import 'package:shared_preferences/shared_preferences.dart';

class PrefsHelper {
  Future<void> addNotificationPrefs(String friendUID) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notificationList = await getNotificationPrefs();
    notificationList.add(friendUID);
    await prefs.setStringList('notificationList', notificationList);
  }

  Future<void> removeNotificationPrefs(String friendUID) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notificationList = await getNotificationPrefs();
    notificationList.remove(friendUID);
    await prefs.setStringList('notificationList', notificationList);
  }

  Future<List<String>> getNotificationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notificationList =
        prefs.getStringList('notificationList') ?? [];
    return notificationList;
  }

  Future<void> addEmergencyPrefs(String friendUID) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> emergencyList = await getEmergencyPrefs();
    emergencyList.add(friendUID);
    await prefs.setStringList('emergencyList', emergencyList);
  }

  Future<List<String>> getEmergencyPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> emergencyList = prefs.getStringList('emergencyList') ?? [];
    return emergencyList;
  }
  Future<void> removeEmergencyPrefs(String friendUID) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> emergencyList = await getEmergencyPrefs();
    emergencyList.remove(friendUID);
    await prefs.setStringList('emergencyList', emergencyList);
  }
}
