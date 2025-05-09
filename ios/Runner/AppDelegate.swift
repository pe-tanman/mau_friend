import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let apiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"] {
      GMSServices.provideAPIKey(apiKey)
    } else {
      fatalError("Google Maps API key not found in environment variables")
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
