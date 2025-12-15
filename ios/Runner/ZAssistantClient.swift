import Foundation

/// Client for communicating with Z Assistant backend
class ZAssistantClient {
    private let baseURL = "https://z-assistant.fly.dev"
    private let appGroupID = "group.app.zagreus"

    enum ZError: Error {
        case missingCredentials
        case invalidResponse
        case networkError(Error)
        case serverError(String)
    }

    /// Send a message to Z Assistant and get a response
    func chat(message: String) async throws -> String {
        // Read device ID from App Groups (HMAC not needed - backend handles auth)
        guard let deviceId = readFromAppGroups(key: "device_id") else {
            throw ZError.missingCredentials
        }

        // Build request body
        let requestBody: [String: Any] = [
            "message": message
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            throw ZError.invalidResponse
        }

        // Build request - simple device ID auth like Flutter
        var request = URLRequest(url: URL(string: "\(baseURL)/chat")!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceId, forHTTPHeaderField: "X-Device-Id")
        request.timeoutInterval = 30

        // Make request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw ZError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ZError.serverError("HTTP \(httpResponse.statusCode): \(errorMsg)")
            }

            // Parse response
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let responseText = json["response"] as? String else {
                throw ZError.invalidResponse
            }

            return responseText

        } catch let error as ZError {
            throw error
        } catch {
            throw ZError.networkError(error)
        }
    }

    /// Read value from App Groups
    private func readFromAppGroups(key: String) -> String? {
        guard let userDefaults = UserDefaults(suiteName: appGroupID) else {
            print("❌ Failed to access App Groups")
            return nil
        }
        return userDefaults.string(forKey: key)
    }
}
