import SwiftUI
import PhotosUI

struct CoachView: View {
    @EnvironmentObject var state: AppState

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
        "First date thoughts",
        "Growing my confidence",
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        Text("Today")
                            .font(Theme.sans(11.5, .semibold))
                            .foregroundStyle(Color(hex: 0x3F4C45))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Theme.pill, in: Capsule())
                            .padding(.bottom, 6)

                        ForEach(state.chatMessages) { message in
                            bubble(message).id(message.id)
                        }
                        if isTyping {
                            typingIndicator.id("typing")
                        }
                        if state.chatMessages.count <= 1 && !isTyping {
                            quickPromptSection
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 18)
                    .padding(.bottom, 12)
                }
                .scrollDismissesKeyboard(.interactively)
                // The chat scrolls under the message bar, so its glass has something to refract.
                .safeAreaInset(edge: .bottom, spacing: 0) { inputBar }
                .onChange(of: state.chatMessages.count) { _, _ in
                    if let id = state.chatMessages.last?.id {
                        withAnimation { proxy.scrollTo(id, anchor: .bottom) }
                    }
                }
                .onChange(of: isTyping) { _, typing in
                    if typing { withAnimation { proxy.scrollTo("typing", anchor: .bottom) } }
                }
            }
        }
        .screenBackground()
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
        .onChange(of: inputFocused) { _, focused in
            withAnimation(.easeOut(duration: 0.2)) { state.hideTabBar = focused }
        }
        .onAppear {
            if state.chatMessages.isEmpty {
                state.chatMessages = [ChatMessage(role: .assistant, text: "Hi \(state.firstName). I'm here whenever you need to talk. What's on your heart today?")]
            }
            consumePendingPrompt()
        }
        .onDisappear { state.hideTabBar = false }
        .onChange(of: state.pendingMiaPrompt) { _, _ in consumePendingPrompt() }
        .sheet(isPresented: $showUpgrade) { MembershipView().environmentObject(state) }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                RoundPhoto(name: "mia_avatar", size: 50)
                Circle()
                    .fill(Theme.online)
                    .frame(width: 13, height: 13)
                    .overlay(Circle().stroke(Theme.surface, lineWidth: 2.5))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Mia")
                    .font(Theme.serif(28, .semibold))
                    .foregroundStyle(Theme.ink)
                Text("AI coach · Here whenever you need")
                    .font(Theme.sans(12.5))
                    .foregroundStyle(Theme.muted)
            }
            Spacer()
            if !state.profile.isPremium {
                Text("\(state.aiMessagesLeft) left")
                    .font(Theme.sans(11.5, .semibold))
                    .foregroundStyle(Theme.goldText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Theme.pill, in: Capsule())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(Theme.surface.ignoresSafeArea(edges: .top))
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.divider).frame(height: 1) }
    }

    // MARK: Messages

    private func bubble(_ message: ChatMessage) -> some View {
        let isUser = message.role == .user
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 20,
            bottomLeadingRadius: isUser ? 20 : 6,
            bottomTrailingRadius: isUser ? 6 : 20,
            topTrailingRadius: 20,
            style: .continuous
        )
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
                        .font(Theme.sans(15))
                        .lineSpacing(3)
                        .foregroundStyle(isUser ? Theme.onGreen : Theme.ink)
                        .textSelection(.enabled)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(isUser ? Theme.green : Theme.surface, in: shape)
            if !isUser { Spacer(minLength: 50) }
        }
    }

    private var typingIndicator: some View {
        HStack {
            TypingDots()
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(Theme.surface, in: UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 6,
                                                                      bottomTrailingRadius: 20, topTrailingRadius: 20))
            Spacer()
        }
    }

    private var quickPromptSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("If you'd like")
            FlowLayout {
                ForEach(quickPrompts, id: \.self) { prompt in
                    Button(prompt) { send(prompt) }
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
        .padding(.top, 16)
    }

    // MARK: Input

    private var inputBar: some View {
        VStack(spacing: 10) {
            if let data = attachedImage, let image = UIImage(data: data) {
                HStack(spacing: 12) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Text("Screenshot attached")
                        .font(Theme.sans(12.5, .medium))
                        .foregroundStyle(Theme.muted)
                    Spacer()
                    Button {
                        attachedImage = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.faint)
                    }
                    .accessibilityLabel("Remove screenshot")
                }
            }
            GlassGroup(spacing: 10) {
                HStack(alignment: .bottom, spacing: 10) {
                    HStack(alignment: .bottom, spacing: 0) {
                        TextField("", text: $input, prompt: Text("Share what's on your heart...").foregroundColor(Theme.faint), axis: .vertical)
                            .lineLimit(1...5)
                            .focused($inputFocused)
                            .font(Theme.sans(15))
                            .foregroundStyle(Theme.ink)
                            .padding(.leading, 20)
                            .padding(.vertical, 14)
                        Button {
                            showPicker = true
                        } label: {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 19))
                                .foregroundStyle(Theme.muted)
                                .frame(width: 44, height: 44)
                        }
                        .padding(4)
                        .accessibilityLabel("Attach a screenshot")
                    }
                    .liquidGlass(in: RoundedRectangle(cornerRadius: 26, style: .continuous)) {
                        $0.background(Theme.surface, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).stroke(Theme.outline, lineWidth: 1.5))
                    }

                    Button { send() } label: {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Theme.goldInk)
                            .frame(width: 52, height: 52)
                            .liquidGlass(in: Circle(), tint: Color(hex: 0xD4B066), interactive: true) {
                                $0.background(Theme.goldFill, in: Circle())
                            }
                    }
                    .disabled(!canSend)
                    .opacity(canSend ? 1 : 0.5)
                    .accessibilityLabel("Send")
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(hasLiquidGlass ? Color.clear : Theme.background)
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

    private func send(_ preset: String? = nil) {
        if let preset { input = preset }
        guard canSend else { return }
        if !state.profile.isPremium && state.aiMessagesLeft == 0 {
            showUpgrade = true
            return
        }
        let message = ChatMessage(role: .user,
                                  text: input.trimmingCharacters(in: .whitespacesAndNewlines),
                                  imageData: attachedImage)
        state.chatMessages.append(message)
        input = ""
        attachedImage = nil
        isTyping = true
        state.recordAIMessage()

        let history = state.chatMessages
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
            state.chatMessages.append(ChatMessage(role: .assistant, text: replyText))
        }
    }
}

private struct TypingDots: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill([Theme.green, Color(hex: 0x6FA08C), Color(hex: 0xB5CFC3)][i])
                    .frame(width: 7, height: 7)
                    .offset(y: animating ? -3 : 2)
                    .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.15), value: animating)
            }
        }
        .onAppear { animating = true }
    }
}
