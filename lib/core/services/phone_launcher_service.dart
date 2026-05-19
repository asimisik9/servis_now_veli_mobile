import 'package:url_launcher/url_launcher.dart';

class PhoneLauncherService {
  Future<bool> call(String phoneNumber) async {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final uri = Uri.parse('tel:$cleaned');
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
