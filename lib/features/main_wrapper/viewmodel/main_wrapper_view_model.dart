import 'package:flutter/material.dart';

class MainWrapperViewModel extends ChangeNotifier {
  static const int homeTabIndex = 0;
  static const int mapTabIndex = 1;
  static const int notificationsTabIndex = 2;
  static const int profileTabIndex = 3;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (index < homeTabIndex || index > profileTabIndex) {
      return;
    }
    if (_currentIndex == index) {
      return;
    }
    _currentIndex = index;
    notifyListeners();
  }

  void setIndexByTabKey(String? tabKey) {
    final normalized = tabKey?.trim().toLowerCase();
    switch (normalized) {
      case 'home':
      case 'ana_sayfa':
        setIndex(homeTabIndex);
        return;
      case 'map':
      case 'harita':
        setIndex(mapTabIndex);
        return;
      case 'notifications':
      case 'notification':
      case 'bildirim':
      case 'bildirimler':
        setIndex(notificationsTabIndex);
        return;
      case 'profile':
      case 'profil':
        setIndex(profileTabIndex);
        return;
      default:
        setIndex(notificationsTabIndex);
    }
  }
}
