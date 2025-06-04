import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsController extends GetxController {
  static NotificationsController get to => Get.find();
  
  final RxBool _notificationsEnabled = false.obs;
  bool get notificationsEnabled => _notificationsEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _loadNotificationsState();
  }

  Future<void> _loadNotificationsState() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled.value = prefs.getBool('notifications_enabled') ?? false;
  }

  Future<void> toggleNotifications() async {
    _notificationsEnabled.value = !_notificationsEnabled.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled.value);
  }
} 