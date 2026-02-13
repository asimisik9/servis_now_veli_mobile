import 'package:url_launcher/url_launcher.dart';

class PhoneLauncherService {
  Future<bool> call(String phoneNumber) async {
    final launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await canLaunchUrl(launchUri)) {
      return false;
    }

    return launchUrl(launchUri);
  }
}
