//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Umikaze on 10/2/25.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            // Check if we have a media URL to download
            if let mediaURLString = bestAttemptContent.userInfo["media_url"] as? String,
               let mediaURL = URL(string: mediaURLString) {

                downloadImage(from: mediaURL) { attachment in
                    if let attachment = attachment {
                        bestAttemptContent.attachments = [attachment]
                    }
                    contentHandler(bestAttemptContent)
                }
            } else {
                // No media URL, just deliver the notification as-is
                contentHandler(bestAttemptContent)
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func downloadImage(from url: URL, completion: @escaping (UNNotificationAttachment?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            guard let location = location, error == nil else {
                print("Failed to download image: \(error?.localizedDescription ?? "unknown error")")
                completion(nil)
                return
            }

            // Get the file extension from the response
            var fileExtension = "jpg"
            if let mimeType = response?.mimeType {
                if mimeType.contains("png") {
                    fileExtension = "png"
                } else if mimeType.contains("jpeg") || mimeType.contains("jpg") {
                    fileExtension = "jpg"
                }
            }

            // Create a temporary file URL
            let tempDirectory = FileManager.default.temporaryDirectory
            let fileName = UUID().uuidString + "." + fileExtension
            let tempFileURL = tempDirectory.appendingPathComponent(fileName)

            do {
                // Move the downloaded file to the temp location
                try FileManager.default.moveItem(at: location, to: tempFileURL)

                // Create the attachment
                let attachment = try UNNotificationAttachment(identifier: "image", url: tempFileURL, options: nil)
                completion(attachment)
            } catch {
                print("Failed to create attachment: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
