import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Set self as UNUserNotificationCenter delegate to handle foreground notifications
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    // Clear badge on app launch
    UIApplication.shared.applicationIconBadgeNumber = 0
    
    // Set up method channel for notification permissions
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app.zagreus/notifications",
                                        binaryMessenger: controller.binaryMessenger)
      
      channel.setMethodCallHandler { (call, result) in
        switch call.method {
        case "requestPermission":
          print("Zagreus: Method channel received requestPermission")
          self.requestNotificationPermission { granted in
            print("Zagreus: Returning permission result: \(granted)")
            result(granted)
          }
        case "checkPermission":
          self.checkNotificationPermission { allowed in
            result(allowed)
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
    print("Zagreus: Requesting notification permission")
    if #available(iOS 10.0, *) {
      // First check current authorization status
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Zagreus: Current auth status: \(settings.authorizationStatus.rawValue)")
        if settings.authorizationStatus == .notDetermined {
          print("Zagreus: Status is notDetermined, showing permission dialog")
        } else if settings.authorizationStatus == .denied {
          print("Zagreus: Permissions were previously denied")
        } else if settings.authorizationStatus == .authorized {
          print("Zagreus: Permissions already granted")
        }
      }
      
      UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        print("Zagreus: Permission granted: \(granted), error: \(String(describing: error))")
        DispatchQueue.main.async {
          if granted {
            print("Zagreus: Registering for remote notifications")
            UIApplication.shared.registerForRemoteNotifications()
          }
          completion(granted)
        }
      }
    } else {
      let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
      UIApplication.shared.registerUserNotificationSettings(settings)
      UIApplication.shared.registerForRemoteNotifications()
      completion(true)
    }
  }
  
  private func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        completion(settings.authorizationStatus == .authorized)
      }
    } else {
      completion(UIApplication.shared.currentUserNotificationSettings?.types != [])
    }
  }
  
  // Handle receiving the device token
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
    let token = tokenParts.joined()
    print("Zagreus: Received device token: \(token)")
    
    // Send token to Flutter
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app.zagreus/notifications",
                                        binaryMessenger: controller.binaryMessenger)
      channel.invokeMethod("onToken", arguments: token)
      print("Zagreus: Sent token to Flutter")
    } else {
      print("Zagreus: Failed to get FlutterViewController")
    }
  }
  
  // Handle registration failure
  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    print("Failed to register for remote notifications: \(error)")
  }
  
  // Clear badge when app becomes active
  override func applicationDidBecomeActive(_ application: UIApplication) {
    UIApplication.shared.applicationIconBadgeNumber = 0
  }

  // MARK: - UNUserNotificationCenterDelegate

  // Handle notifications when app is in foreground
  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    print("Zagreus: Received notification in foreground")

    // Extract notification data
    let userInfo = notification.request.content.userInfo
    print("Zagreus: Notification data: \(userInfo)")

    // Send notification to Flutter for display as toast
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app.zagreus/notifications",
                                        binaryMessenger: controller.binaryMessenger)

      // Create message data for Flutter
      var messageData: [String: Any] = [:]
      messageData["title"] = notification.request.content.title
      messageData["body"] = notification.request.content.body

      // Add custom data
      if let module = userInfo["module"] as? String {
        messageData["module"] = module
      }
      if let event = userInfo["event"] as? String {
        messageData["event"] = event
      }

      channel.invokeMethod("onMessage", arguments: messageData)
      print("Zagreus: Sent foreground notification to Flutter")
    }

    // Don't show system notification banner since we'll show our own toast
    completionHandler([])
  }

  // Handle notification taps
  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    print("Zagreus: User tapped notification")

    // Let Flutter handle the tap
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "app.zagreus/notifications",
                                        binaryMessenger: controller.binaryMessenger)

      let userInfo = response.notification.request.content.userInfo
      channel.invokeMethod("onMessageOpenedApp", arguments: userInfo)
    }

    completionHandler()
  }
}
