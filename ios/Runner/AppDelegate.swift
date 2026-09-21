import Flutter
import GoogleMaps
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "com.example.draaxi/google_api_keys"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
    }

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: channelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "getKeys":
          let mapsApiKey =
            (Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String) ?? ""
          let placesApiKey =
            (Bundle.main.object(forInfoDictionaryKey: "GooglePlacesApiKey") as? String) ?? mapsApiKey
          result(["mapsApiKey": mapsApiKey, "placesApiKey": placesApiKey])
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
