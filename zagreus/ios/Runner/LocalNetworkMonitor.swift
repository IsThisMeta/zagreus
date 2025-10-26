import Foundation
import Network
import SystemConfiguration.CaptiveNetwork
import Flutter
import UIKit

/// Observes the current Wi-Fi SSID and notifies Flutter when it changes.
final class LocalNetworkMonitor {
  static let shared = LocalNetworkMonitor()

  private let monitor = NWPathMonitor()
  private let queue = DispatchQueue(label: "app.zagreus.localNetwork")
  private var channel: FlutterMethodChannel?
  private var lastEmittedSsid: String?
  private var isMonitoring = false

  private init() {}

  func startMonitoring(with channel: FlutterMethodChannel) {
    self.channel = channel

    guard !isMonitoring else {
      sendCurrentSsid()
      return
    }

    isMonitoring = true

    monitor.pathUpdateHandler = { [weak self] _ in
      self?.sendCurrentSsid()
    }

    monitor.start(queue: queue)
    sendCurrentSsid()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }

  @objc
  private func handleDidBecomeActive() {
    sendCurrentSsid()
  }

  func stopMonitoring() {
    guard isMonitoring else { return }
    monitor.cancel()
    isMonitoring = false
    NotificationCenter.default.removeObserver(self)
  }

  private func sendCurrentSsid() {
    guard let channel = channel else { return }

    let ssid = Self.currentSsid()

    // Avoid spamming Flutter with duplicate values
    if ssid == lastEmittedSsid { return }
    lastEmittedSsid = ssid

    DispatchQueue.main.async {
      channel.invokeMethod("ssidChanged", arguments: ssid)
    }
  }

  private static func currentSsid() -> String? {
    guard
      let interfaces = CNCopySupportedInterfaces() as? [String],
      !interfaces.isEmpty
    else { return nil }

    for interface in interfaces {
      if
        let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interface as CFString),
        let networkInfo = unsafeInterfaceData as? [String: AnyObject],
        let ssid = networkInfo[kCNNetworkInfoKeySSID as String] as? String
      {
        return ssid
      }
    }

    return nil
  }
}
