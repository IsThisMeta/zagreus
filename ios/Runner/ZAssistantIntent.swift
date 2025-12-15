import AppIntents

/// Send a command to Z Assistant
@available(iOS 16.0, *)
struct ZAssistantIntent: AppIntent {
    static var title: LocalizedStringResource = "Zagreus"
    static var description = IntentDescription("Send a command to control your home server")
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Command")
    var command: String

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let client = ZAssistantClient()

        do {
            let response = try await client.chat(message: command)
            return .result(dialog: IntentDialog(stringLiteral: response))
        } catch ZAssistantClient.ZError.missingCredentials {
            return .result(dialog: "Please open the Zagreus app first to set up Z Assistant")
        } catch ZAssistantClient.ZError.serverError(let msg) {
            return .result(dialog: "Z Assistant error: \(msg)")
        } catch {
            return .result(dialog: "Sorry, I couldn't reach Z Assistant right now. \(error.localizedDescription)")
        }
    }
}
