import SwiftUI
import PhotosUI

struct CoachView: View {
    @EnvironmentObject var state: AppState

    @State private var messages: [ChatMessage] = []
    @State private var input = ""
    @State private var isTyping = false
    @State private var attachedImage: Data?
    @State private var pickerItem: PhotosPickerItem?
    @State private var showPicker = false
    @State private var showUpgrade = false
    @FocusState private var inputFocused: Bool

    private let quickPrompts = [
        "I'm feeling nervous about approaching",
        "I'd like support with texting",
        "Help me plan a first date",
        "Growing my confidence",
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(messages) { message in
                            bubble(message)
                                .id(message.id)
                        }
                        if isTyping {
                            typingIndicator.id("typing")
                        }
                        if messages.count <= 1 {
                            quickPromptSection
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: messages.count) { _, _ in
                    if let id = messages.last?.id {
                        withAnimation { proxy.scrollTo(id, anchor: .bottom) }
                    }
                }
                .onChange(of: isTyping) { _, typing in
                    if typing { withAnimation { proxy.scrollTo("typing", anchor: .bottom) } }
                }
            }
            inputBar
        }
        .miaBackground()
        .photosPicker(isPresented: $showPicker, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { @MainActor in
                if let data = try? await item.loadTransferable(type: Data.self) {
                    attachedImage = ImageUtil.prepareForUpload(data)
                }
                pickerItem = nil
            }
        }
        .onAppear {
            if messages.isEmpty {
                messages = [ChatMessage(role: .assistant, text: "Hi \(state.firstName). I'm here whenever you need to talk. What's on your heart today?")]
            }
            consumePendingPrompt()
        }
        .onChange(of: state.pendingMiaPrompt) { _, _ in consumePendingPrompt() }
        .sheet(isPresented: $showUpgrade) { MembershipView().environmentObject(state) }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 14) {
            MiaAvatar(size: 46)
            VStack(alignment: .leading, spacing: 4) {
                Text("Mia")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(Theme.text)
                HStack(spacing: 6) {
                    Circle().fill(Color.green.opacity(0.7)).frame(width: 7, height: 7)
                    Text("Here whenever you need")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Theme.textMuted)
                }
            }
            Spacer()
            if state.profile.isPremium {
                Pill(text: "Unlimited")
            } else {
                Pill(text: "\(state.aiMessagesLeft) left this month", tint: Theme.textSoft)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(Theme.bgTop.opacity(0.85))
        .overlay(alignment: .bottom) {
            Rectangle().fill(Theme.border.opacity(0.35)).frame(height: 1)
        }
    }

    // MARK: Messages

    private func bubble(_ message: ChatMessage) -> some View {
        let isUser = message.role == .user
        return HStack {
            if isUser { Spacer(minLength: 50) }
            VStack(alignment: .leading, spacing: 10) {
                if let data = message.imageData, let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(.system(size: 15, weight: isUser ? .regular : .light))
                        .lineSpacing(3)
                        .foregroundStyle(isUser ? Theme.bgTop : Theme.text)
                        .textSelection(.enabled)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                isUser ? AnyShapeStyle(Theme.goldFill) : AnyShapeStyle(Theme.cardFill),
                in: RoundedRectangle(cornerRadius: 22, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Theme.border.opacity(isUser ? 0 : 0.3))
            )
            if !isUser { Spacer(minLength: 50) }
        }
    }

    private var typingIndicator: some View {
        HStack {
            TypingDots()
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(Theme.cardFill, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            Spacer()
        }
    }

    private var quickPromptSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("If you'd like")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Theme.textMuted)
            FlowLayout {
                ForEach(quickPrompts, id: \.self) { prompt in
                    Button(prompt) { input = prompt; inputFocused = true }
                        .buttonStyle(ChipButtonStyle())
                }
                Button {
                    input = "Can you review this conversation and tell me what to send next?"
                    showPicker = true
                } label: {
                    Label("Review my texts", systemImage: "text.bubble")
                }
                .buttonStyle(ChipButtonStyle())
                Button {
                    input = "Can you review my dating profile and tell me how to improve it?"
                    showPicker = true
                } label: {
                    Label("Review my dating profile", systemImage: "person.crop.square")
                }
                .buttonStyle(ChipButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    // MARK: Input

    private var inputBar: some View {
        VStack(spacing: 10) {
            if let data = attachedImage, let image = UIImage(data: data) {
                HStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .overlay(alignment: .topTrailing) {
                            Button {
                                attachedImage = nil
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Theme.text, Theme.bgTop)
                            }
                            .offset(x: 6, y: -6)
                        }
                    Text("Screenshot attached")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Theme.textMuted)
                    Spacer()
                }
            }
            HStack(alignment: .bottom, spacing: 10) {
                Button {
                    showPicker = true
                } label: {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                        .frame(width: 44, height: 44)
                        .background(Theme.chip.opacity(0.5), in: Circle())
                }
                TextField("", text: $input, prompt: Text("Share what's on your heart...").foregroundColor(Theme.textMuted), axis: .vertical)
                    .lineLimit(1...5)
                    .focused($inputFocused)
                    .font(.system(size: 15, weight: .light))
                    .foregroundStyle(Theme.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Theme.chip.opacity(0.5), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Theme.border.opacity(0.35)))
                Button(action: send) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.bgTop)
                        .frame(width: 44, height: 44)
                        .background(Theme.goldFill, in: Circle())
                }
                .disabled(!canSend)
                .opacity(canSend ? 1 : 0.4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(Theme.bgBottom.opacity(0.95))
    }

    private var canSend: Bool {
        !isTyping && (!input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || attachedImage != nil)
    }

    private func consumePendingPrompt() {
        if let prompt = state.pendingMiaPrompt {
            input = prompt
            state.pendingMiaPrompt = nil
        }
    }

    private func send() {
        guard canSend else { return }
        if !state.profile.isPremium && state.aiMessagesLeft == 0 {
            showUpgrade = true
            return
        }
        let message = ChatMessage(role: .user,
                                  text: input.trimmingCharacters(in: .whitespacesAndNewlines),
                                  imageData: attachedImage)
        messages.append(message)
        input = ""
        attachedImage = nil
        isTyping = true
        state.recordAIMessage()

        let history = messages
        let apiKey = state.apiKey
        let name = state.firstName
        let goals = state.profile.goals
        Task { @MainActor in
            let replyText: String
            do {
                replyText = try await MiaAI.reply(to: history, apiKey: apiKey, userName: name, goals: goals)
            } catch {
                replyText = "Sorry, I couldn't connect just now (\(error.localizedDescription)). Please try again in a moment."
            }
            isTyping = false
            messages.append(ChatMessage(role: .assistant, text: replyText))
        }
    }
}

private struct TypingDots: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Theme.textSoft)
                    .frame(width: 7, height: 7)
                    .opacity(animating ? 0.9 : 0.25)
                    .animation(.easeInOut(duration: 0.6).repeatForever().delay(Double(i) * 0.2), value: animating)
            }
        }
        .onAppear { animating = true }
    }
}
