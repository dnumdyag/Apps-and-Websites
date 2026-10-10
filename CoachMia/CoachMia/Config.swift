import Foundation

enum Config {
    /// Optional: paste an Anthropic API key here so Coach Mia AI works out of the box.
    /// You can also enter it at runtime in More > Settings.
    /// Leave empty to use the built-in offline demo replies.
    /// NOTE: for the App Store build, move AI calls behind your own backend; never ship a key in the app.
    static let anthropicAPIKey = ""

    static let model = "claude-opus-5-5"
    static let currency = "$"
    static let supportEmail = "hello@coachmia.com"
    static let websiteURL = URL(string: "https://coachmia.com")!
}
