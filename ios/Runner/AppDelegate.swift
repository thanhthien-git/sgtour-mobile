import UIKit
import Flutter
import WebKit

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *) {
      let registrar = self.registrar(forPlugin: "webview_flutter_wkwebview")
      let factory = registrar?.value(forKey: "webViewFactory") as? NSObject

      factory?.setValue(false, forKey: "requiresUserActionForMediaPlayback")
      factory?.setValue(true, forKey: "allowsInlineMediaPlayback")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
