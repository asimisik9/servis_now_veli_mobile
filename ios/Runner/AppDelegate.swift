import Flutter
import UIKit
import GoogleMaps
import Firebase
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }
#if !DEBUG
    if let bundleId = Bundle.main.bundleIdentifier, bundleId.hasPrefix("com.example.") {
      fatalError("Release build requires non-placeholder iOS bundle identifier.")
    }
#endif
    if let mapsApiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_MAPS_API_KEY") as? String,
       !mapsApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      GMSServices.provideAPIKey(mapsApiKey)
    } else {
      assertionFailure("GOOGLE_MAPS_API_KEY is missing in Info.plist")
    }
    GeneratedPluginRegistrant.register(with: self)

    // Push notification registration
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
