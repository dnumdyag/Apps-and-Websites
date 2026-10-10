import Foundation
import UIKit

struct ChatMessage: Identifiable, Equatable {
    enum Role { case user, assistant }

    let id = UUID()
    let role: Role
    let text: String
    var imageData: Data? = nil
}

enum MiaAIError: LocalizedError {
    case api(String)

    var errorDescription: String? {
        switch self {
        case .api(let message): return message
        }
    }
}

/// Talks to Claude through the Anthropic Messages API (raw HTTP, no dependencies).
/// If no API key is set, returns warm canned replies so the demo always works.
enum MiaAI {
    static func systemPrompt(userName: String, goals: [String]) -> String {
        """
        You are Coach Mia, a warm, grounded and professional dating and relationship coach for men. \
        You speak like a caring coach texting a client: short paragraphs, encouraging, honest, practical. \
        Keep replies under 150 words unless the user asks for detail. End with one gentle question or a concrete next step.

        Principles: confidence comes from self-worth, not tricks. Authenticity over pickup lines. \
        Respect and consent always. Never encourage manipulation, pressure or disrespect toward women. \
        If the user shares a screenshot of a conversation, give specific feedback on tone, timing and what to send next. \
        If they share a dating profile, give specific feedback on photos, bio and prompts. \
        If someone seems in crisis, be kind and suggest talking to a professional or a trusted friend.

        The user's name is \(userName). Their goals: \(goals.isEmpty ? "not shared yet" : goals.joined(separator: ", ")).
        """
    }

    static func reply(to history: [ChatMessage], apiKey: String, userName: String, goals: [String]) async throws -> String {
        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty else {
            try await Task.sleep(nanoseconds: 1_200_000_000)
            return offlineReply(for: history.last)
        }

        // The API expects the conversation to start with a user turn, so skip Mia's greeting.
        let turns = history.drop(while: { $0.role == .assistant })
        let messages: [[String: Any]] = turns.map { message in
            var content: [[String: Any]] = []
            if let data = message.imageData {
                content.append([
                    "type": "image",
                    "source": [
                        "type": "base64",
                        "media_type": "image/jpeg",
                        "data": data.base64EncodedString(),
                    ],
                ])
            }
            let text = message.text.isEmpty ? "Please review this screenshot." : message.text
            content.append(["type": "text", "text": text])
            return ["role": message.role == .user ? "user" : "assistant", "content": content]
        }

        let body: [String: Any] = [
            "model": Config.model,
            // Thinking is always on for Opus 5.5 and counts toward this cap, so leave headroom.
            "max_tokens": 16000,
            "system": systemPrompt(userName: userName, goals: goals),
            "messages": messages,
            "output_config": ["effort": "low"],
            "fallbacks": "default",
        ]

        var request = URLRequest(url: URL(string: "https://api.anthropic.com/v1/messages")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 90
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(key, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.setValue("server-side-fallback-2026-07-01", forHTTPHeaderField: "anthropic-beta")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            let message = (json["error"] as? [String: Any])?["message"] as? String ?? "HTTP \(http.statusCode)"
            throw MiaAIError.api(message)
        }

        if json["stop_reason"] as? String == "refusal" {
            return "I'm not able to help with that one, but I'm here for anything else on your mind."
        }

        let blocks = json["content"] as? [[String: Any]] ?? []
        let text = blocks
            .filter { $0["type"] as? String == "text" }
            .compactMap { $0["text"] as? String }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? "Tell me a little more?" : text
    }

    // MARK: - Offline demo replies

    static func offlineReply(for message: ChatMessage?) -> String {
        guard let message else { return "I'm here. What's on your mind?" }
        if message.imageData != nil {
            return """
            Thanks for sharing this. A few things stand out:

            1. Your opener is friendly, but it's easy to answer with one word. Ask something that invites a story.
            2. You're replying quickly and at length. Match her energy and leave a little space.
            3. The conversation is ready for a next step. Suggest a specific plan: "I know a great little wine bar on Thursday, fancy it?"

            Want me to help you write that next message?
            """
        }
        let t = message.text.lowercased()
        if t.contains("nervous") || t.contains("approach") || t.contains("anxiety") {
            return "I hear you. Approach anxiety is completely normal, it's your mind trying to protect you. Let's make it smaller: today, just say hello to one person with no goal at all. What part of approaching feels the scariest for you?"
        }
        if t.contains("text") || t.contains("message") || t.contains("reply") {
            return "Texting is for building a little anticipation, not for having the whole relationship over chat. Keep it light, match her energy, and move toward a plan. Are you starting a conversation or keeping one going? You can also share a screenshot with the photo button."
        }
        if t.contains("date") {
            return "A great first date is about connection, not perfection. Pick somewhere you can actually talk, keep it to an hour or two, and have a fun second spot in mind if it's going well. Tell me a bit about her, what does she enjoy?"
        }
        if t.contains("profile") || t.contains("hinge") || t.contains("tinder") || t.contains("bumble") {
            return "Your profile is a trailer, not the full movie. Lead with a clear photo where you're smiling, add one that shows your life, and write prompts that are easy to reply to. Share a screenshot and I'll give you specific feedback."
        }
        if t.contains("breakup") || t.contains("my ex") || t.contains("heartbreak") {
            return "I'm sorry, breakups hurt, and it's okay to feel it. Healing isn't linear. For now: lean on your friends, move your body, and limit checking her socials. What's the hardest part of your day right now?"
        }
        if t.contains("confiden") {
            return "Real confidence starts from within. It's built by keeping small promises to yourself. Pick one tiny brave action this week and do it. Which area of confidence would you like to work on first?"
        }
        return "Thank you for sharing that with me. Let's take it step by step. What outcome would feel like a win for you here?"
    }
}

enum ImageUtil {
    /// Downscale and compress screenshots so uploads stay small and fast.
    static func prepareForUpload(_ data: Data, maxDimension: CGFloat = 1568) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let size = image.size
        let scale = min(1, maxDimension / max(size.width, size.height))
        let target = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let resized = UIGraphicsImageRenderer(size: target, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
        return resized.jpegData(compressionQuality: 0.7)
    }
}
