import 'package:BookMyTeacher/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/notification_item.dart';
import '../services/teacher_api_service.dart';


/// GET notifications + count
final notificationProvider = FutureProvider<NotificationResponse>((ref) async {
  return await ApiService().fetchNotifications();
});

/// MARK AS READ
final markNotificationReadProvider =
FutureProvider.family<bool, int>((ref, id) async {
  return await ApiService().markNotificationRead(id);
});