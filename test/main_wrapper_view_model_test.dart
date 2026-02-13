import 'package:flutter_test/flutter_test.dart';
import 'package:servis_now_veli_mobile/features/main_wrapper/viewmodel/main_wrapper_view_model.dart';

void main() {
  group('MainWrapperViewModel', () {
    test('starts on home tab', () {
      final vm = MainWrapperViewModel();
      expect(vm.currentIndex, MainWrapperViewModel.homeTabIndex);
    });

    test('maps target tab keys to indexes', () {
      final vm = MainWrapperViewModel();

      vm.setIndexByTabKey('map');
      expect(vm.currentIndex, MainWrapperViewModel.mapTabIndex);

      vm.setIndexByTabKey('bildirimler');
      expect(vm.currentIndex, MainWrapperViewModel.notificationsTabIndex);

      vm.setIndexByTabKey('profile');
      expect(vm.currentIndex, MainWrapperViewModel.profileTabIndex);

      vm.setIndexByTabKey('unknown_key');
      expect(vm.currentIndex, MainWrapperViewModel.notificationsTabIndex);
    });
  });
}
