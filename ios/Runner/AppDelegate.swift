import Flutter
import UIKit
import WebKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure WebView for media playback without user gesture
    if #available(iOS 15.0, *) {
      let preferences = WKPreferences()
      preferences.javaScriptEnabled = true
      
      let configuration = WKWebViewConfiguration()
      configuration.preferences = preferences
      configuration.allowsInlineMediaPlayback = true
      configuration.mediaTypesRequiringUserActionForPlayback = []
    } else if #available(iOS 10.0, *) {
      let preferences = WKPreferences()
      preferences.javaScriptEnabled = true
      
      let configuration = WKWebViewConfiguration()
      configuration.preferences = preferences
      configuration.allowsInlineMediaPlayback = true
      configuration.mediaPlaybackRequiresUserGesture = false
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
