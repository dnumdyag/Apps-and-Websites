import SwiftUI
import PhotosUI

/// The Mia page. The member either picks a guided session (Mia asks three quick questions with
/// tappable answers, then gives a personal plan) or simply talks to her.
struct CoachView: View {
    @EnvironmentObject var state: AppState

    @State private var input = ""
    @State private var isTyping = false
    /// Shown beside the typing dots while Mia prepares a plan.
    @State private var typingNote: String?
    @State private var attachedImage: Data?
    @State private var pickerItem: PhotosPickerItem?
    @State private var showPicker = false
    @State private var showUpgrade = false
    @FocusState private var inputFocused: Bool

    // The guided session in progress.
    @State private var session: MiaSession?
    @State private var sessionStep = 0
    @State private var answers: [String] = []
    @State private var sharedPhoto = false
    @State private var choicesVisible = false
    @State private var followUps: [MiaSession.FollowUp] = []
    /// Changes when a session ends early, so Mia's queued messages for it are dropped.
    @State private var flowID = UUID()
    @State private var didAppear = false

    private var isFreshChat: Bool { state.chatMessages.count <= 1 && session == nil && !isTyping }

    var body: some View {
        VStack(spacing: 0) {
            header
            if let session {
                sessionStrip(session)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        Text("Today")
                            .font(Theme.sans(11, .semibold))
                            .foregroundStyle(Color(hex: 0x3F4C45))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(Theme.pill, in: Capsule())
                            .padding(.bottom, 6)

                        ForEach(state.chatMessages.indices, id: \.self) { index in
                            let message = state.chatMessages[index]
                            row(message, showAvatar: isLastOfMiaRun(index))
                                .id(message.id)
                                .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity),
                                                        removal: .opacity))
                        }
                        if isTyping {
                            typingRow
                                .id("typing")
                                .transition(.opacity)
                        }
                        if isFreshChat {
                            sessionGrid
                                .transition(.opacity)
                        }
                        Color.clear.frame(height: 2).id("end")
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 12)
                }
                .scrollDismissesKeyboard(.interactively)
                // The chat scrolls under the message bar, so its glass has something to refract.
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    VStack(spacing: 0) {
                        choicePanel
                        inputBar
                    }
                }
                .onChange(of: state.chatMessages.count) { _, count in
                    if count > 1 { scrollToEnd(proxy) }
                }
                .onChange(of: isTyping) { _, _ in scrollToEnd(proxy) }
                .onChange(of: choicesVisible) { _, _ in scrollToEnd(proxy) }
            }
        }
        .screenBackground()
        .photosPicker(isPresented: $showPicker, selection: $pickerItem, matching: .images)
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { @MainActor in
                let data = (try? await item.loadTransferable(type: Data.self)).flatMap { ImageUtil.prepareForUpload($0) }
                pickerItem = nil
                guard let data else { return }
                if session != nil && choicesVisible {
                    answer("Here's my screenshot", image: data)
                } else {
                    attachedImage = data
                }
            }
        }
        .onChange(of: inputFocused) { _, focused in
            withAnimation(.easeOut(duration: 0.2)) { state.hideTabBar = focused }
        }
        .onAppear {
            if state.chatMessages.isEmpty {
                state.chatMessages = [ChatMessage(role: .assistant, text: "Hi \(state.firstName). What would you like to work on today? Choose a session, or just tell me what's on your mind.")]
            }
            consumePendingPrompt()
            #if DEBUG
            if !didAppear { prefillForScreenshot() }
            #endif
            didAppear = true
        }
        .onDisappear { state.hideTabBar = false }
        .onChange(of: state.pendingMiaPrompt) { _, _ in consumePendingPrompt() }
        .sheet(isPresented: $showUpgrade) { MembershipView().environmentObject(state) }
    }

    private func scrollToEnd(_ proxy: ScrollViewProxy) {
        withAnimation(.easeOut(duration: 0.35)) { proxy.scrollTo("end", anchor: .bottom) }
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                RoundPhoto(name: "mia_avatar", size: 44)
                    .padding(2)
                    .overlay(Circle().strokeBorder(Theme.metalGold, lineWidth: 1.5))
                Circle()
                    .fill(Theme.online)
                    .frame(width: 13, height: 13)
                    .overlay(Circle().stroke(Theme.surface, lineWidth: 2.5))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Mia")
                    .font(Theme.serif(30, .semibold))
                    .foregroundStyle(Theme.ink)
                Text("AI coach · Here whenever you need")
                    .font(Theme.sans(12))
                    .foregroundStyle(Theme.muted)
            }
            Spacer()
            if !state.profile.isPremium {
                Text("\(state.aiMessagesLeft) left")
                    .font(Theme.sans(11, .semibold))
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

    /// Under the header while a session runs: which session, how far along, and a way out.
    private func sessionStrip(_ session: MiaSession) -> some View {
        let total = session.questions.count
        return VStack(spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: session.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.goldOnGreen)
                    .frame(width: 28, height: 28)
                    .background(Theme.greenFill, in: Circle())
                Text(session.title)
                    .font(Theme.sans(13, .semibold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text(sessionStep < total ? "\(sessionStep + 1) of \(total)" : "Your plan")
                    .font(Theme.sans(12, .semibold))
                    .foregroundStyle(Theme.goldText)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Button(action: endSession) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Theme.muted)
                        .frame(width: 28, height: 28)
                        .background(Theme.pill, in: Circle())
                }
                .accessibilityLabel("End session")
            }
            ProgressLine(value: Double(sessionStep) / Double(total), track: Theme.track, fill: Theme.green, height: 3)
                .animation(.easeInOut(duration: 0.5), value: sessionStep)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(Theme.surface)
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.divider).frame(height: 1) }
    }

    // MARK: Messages

    private func isLastOfMiaRun(_ index: Int) -> Bool {
        let messages = state.chatMessages
        guard messages[index].role == .assistant, messages[index].plan == nil else { return false }
        if index == messages.count - 1 { return !isTyping }
        return messages[index + 1].role != .assistant || messages[index + 1].plan != nil
    }

    @ViewBuilder private func row(_ message: ChatMessage, showAvatar: Bool) -> some View {
        if let plan = message.plan {
            planCard(plan)
        } else {
            bubble(message, showAvatar: showAvatar)
        }
    }

    private func bubble(_ message: ChatMessage, showAvatar: Bool) -> some View {
        let isUser = message.role == .user
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: 20,
            bottomLeadingRadius: isUser ? 20 : 6,
            bottomTrailingRadius: isUser ? 6 : 20,
            topTrailingRadius: 20,
            style: .continuous
        )
        return HStack(alignment: .bottom, spacing: 8) {
            if isUser {
                Spacer(minLength: 50)
            } else {
                RoundPhoto(name: "mia_avatar", size: 28)
                    .opacity(showAvatar ? 1 : 0)
            }
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
            .background {
                if isUser {
                    shape.fill(Theme.greenFill)
                        .overlay(shape.strokeBorder(LinearGradient(colors: [.white.opacity(0.2), .clear],
                                                                   startPoint: .top, endPoint: .bottom), lineWidth: 1))
                } else {
                    shape.fill(Theme.surface)
                        .shadow(color: Theme.green.opacity(0.07), radius: 8, y: 3)
                }
            }
            if !isUser { Spacer(minLength: 40) }
        }
    }

    /// The plan Mia gives at the end of a session: numbered gold steps on her green card.
    private func planCard(_ plan: SessionPlan) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(plan.label)
                    .font(Theme.sans(11, .semibold))
                    .tracking(2)
                    .foregroundStyle(Theme.goldOnGreen)
                Text(plan.title)
                    .font(Theme.serif(26, .semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }
            VStack(alignment: .leading, spacing: 14) {
                ForEach(plan.steps.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(i + 1)")
                            .font(Theme.sans(12, .bold))
                            .foregroundStyle(Theme.goldInk)
                            .frame(width: 24, height: 24)
                            .background(Theme.goldFill, in: Circle())
                        Text(plan.steps[i])
                            .font(Theme.sans(14))
                            .lineSpacing(3)
                            .foregroundStyle(Theme.onGreen)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            if let note = plan.note {
                Rectangle().fill(.white.opacity(0.14)).frame(height: 1)
                Text(note)
                    .font(Theme.sans(12))
                    .lineSpacing(2)
                    .foregroundStyle(Theme.onGreenMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .greenCard(padding: 22)
        .padding(.vertical, 6)
    }

    private var typingRow: some View {
        HStack(alignment: .bottom, spacing: 8) {
            RoundPhoto(name: "mia_avatar", size: 28)
            HStack(spacing: 10) {
                TypingDots()
                if let typingNote {
                    Text(typingNote)
                        .font(Theme.sans(13))
                        .foregroundStyle(Theme.muted)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .background(Theme.surface, in: UnevenRoundedRectangle(topLeadingRadius: 20, bottomLeadingRadius: 6,
                                                                  bottomTrailingRadius: 20, topTrailingRadius: 20,
                                                                  style: .continuous))
            Spacer()
        }
    }

    // MARK: Sessions

    /// On a fresh chat: every guided session as a card.
    private var sessionGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Sessions with Mia")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(MiaSessions.all) { session in
                    Button { start(session) } label: { sessionCard(session) }
                        .buttonStyle(PressScaleStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    private func sessionCard(_ session: MiaSession) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: session.icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.goldOnGreen)
                .frame(width: 40, height: 40)
                .background(Theme.greenFill, in: Circle())
                .padding(.bottom, 14)
            Text(session.title)
                .font(Theme.serif(22, .semibold))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Text(session.subtitle)
                .font(Theme.sans(12))
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.leading)
                .lineLimit(2, reservesSpace: true)
                .padding(.top, 4)
            HStack {
                Text("3 QUESTIONS")
                    .font(Theme.sans(10, .semibold))
                    .tracking(1.5)
                    .foregroundStyle(Theme.goldText)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.green)
            }
            .padding(.top, 12)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Theme.green.opacity(0.06), radius: 10, y: 4)
    }

    /// Above the message bar: the answers to Mia's question, follow ups after a plan, or the
    /// sessions as a row of shortcuts.
    @ViewBuilder private var choicePanel: some View {
        Group {
            if let session, choicesVisible, sessionStep < session.questions.count {
                let question = session.questions[sessionStep]
                FlowLayout {
                    if let photo = question.photoOption {
                        Button { showPicker = true } label: { Label(photo, systemImage: "photo") }
                            .buttonStyle(ChipButtonStyle(selected: true))
                    }
                    ForEach(question.options, id: \.self) { option in
                        Button(option) { answer(option) }
                            .buttonStyle(ChipButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else if session == nil, !isTyping, !followUps.isEmpty {
                chipRow {
                    ForEach(followUps, id: \.label) { followUp in
                        Button(followUp.label) { send(followUp.label) }
                            .buttonStyle(ChipButtonStyle())
                    }
                    Button { withAnimation { followUps = [] } } label: {
                        Label("Another session", systemImage: "square.grid.2x2")
                    }
                    .buttonStyle(ChipButtonStyle(selected: true))
                }
            } else if session == nil, !isTyping, !isFreshChat, !inputFocused {
                chipRow {
                    ForEach(MiaSessions.all) { session in
                        Button { start(session) } label: { Label(session.title, systemImage: session.icon) }
                            .buttonStyle(ChipButtonStyle())
                    }
                }
            }
        }
        .padding(.top, 18)
        .background {
            LinearGradient(stops: [.init(color: Theme.background.opacity(0), location: 0),
                                   .init(color: Theme.background, location: 0.3)],
                           startPoint: .top, endPoint: .bottom)
                .allowsHitTesting(false)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func chipRow<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) { content() }
                .padding(.vertical, 1)
        }
        .scrollIndicators(.hidden)
        .contentMargins(.horizontal, 20, for: .scrollContent)
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
                        .font(Theme.sans(12, .medium))
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
                        TextField("", text: $input,
                                  prompt: Text(session != nil && choicesVisible ? "Or type your own answer..." : "Share what's on your heart...")
                                      .foregroundColor(Theme.faint),
                                  axis: .vertical)
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
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(hasLiquidGlass ? Color.clear : Theme.background)
    }

    private var hasDraft: Bool {
        !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || attachedImage != nil
    }

    private var canSend: Bool {
        !isTyping && hasDraft && (session == nil || choicesVisible)
    }

    private func consumePendingPrompt() {
        if let prompt = state.pendingMiaPrompt {
            input = prompt
            state.pendingMiaPrompt = nil
        }
    }

    // MARK: Guided session flow

    private func start(_ chosen: MiaSession) {
        guard session == nil, !isTyping else { return }
        inputFocused = false
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
            followUps = []
            session = chosen
            sessionStep = 0
            answers = []
            sharedPhoto = false
            state.chatMessages.append(ChatMessage(role: .user, text: chosen.title))
        }
        miaSays([chosen.opener, chosen.questions[0].text])
    }

    private func answer(_ text: String, image: Data? = nil) {
        guard let current = session, choicesVisible else { return }
        withAnimation(.easeInOut(duration: 0.2)) { choicesVisible = false }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            state.chatMessages.append(ChatMessage(role: .user, text: text, imageData: image))
            answers.append(text)
            sessionStep += 1
        }
        if image != nil { sharedPhoto = true }

        if sessionStep < current.questions.count {
            miaSays([current.questions[sessionStep].text])
            return
        }
        let plan = current.plan(answers)
        miaSays(["Thank you, \(state.firstName). Here's what I'd do."], thinking: 1.2, note: "Putting your plan together") {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.8)) {
                state.chatMessages.append(ChatMessage(role: .assistant, text: plan.asText, plan: plan))
                session = nil
            }
            if sharedPhoto {
                // Mia also looks at the screenshot (offline, a sample review).
                requestReply()
            } else {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85).delay(0.5)) { followUps = current.followUps }
            }
        }
    }

    private func endSession() {
        flowID = UUID()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            session = nil
            choicesVisible = false
            isTyping = false
            typingNote = nil
        }
        miaSays(["No problem. We can pick this up whenever you like."])
    }

    /// Mia types each message in turn (longer ones take a little longer), then her answer
    /// choices slide up.
    private func miaSays(_ texts: [String], thinking: Double = 0, note: String? = nil, then: (() -> Void)? = nil) {
        let token = flowID
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            for (i, text) in texts.enumerated() {
                guard token == flowID else { return }
                let last = i == texts.count - 1
                typingNote = last ? note : nil
                withAnimation(.easeOut(duration: 0.2)) { isTyping = true }
                let pause = min(1.3, 0.5 + Double(text.count) * 0.012) + (last ? thinking : 0)
                try? await Task.sleep(nanoseconds: UInt64(pause * 1_000_000_000))
                guard token == flowID else { return }
                withAnimation(.easeOut(duration: 0.15)) { isTyping = false }
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    state.chatMessages.append(ChatMessage(role: .assistant, text: text))
                }
                try? await Task.sleep(nanoseconds: 250_000_000)
            }
            guard token == flowID else { return }
            typingNote = nil
            then?()
            if session != nil {
                try? await Task.sleep(nanoseconds: 150_000_000)
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { choicesVisible = true }
            }
        }
    }

    // MARK: Free chat

    private func send(_ preset: String? = nil) {
        if let preset { input = preset }
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)

        // While Mia waits for an answer, anything typed is the answer.
        if session != nil {
            guard choicesVisible, hasDraft else { return }
            let image = attachedImage
            input = ""
            attachedImage = nil
            answer(text.isEmpty ? "Here's my screenshot" : text, image: image)
            return
        }

        guard canSend else { return }
        if !state.profile.isPremium && state.aiMessagesLeft == 0 {
            showUpgrade = true
            return
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            state.chatMessages.append(ChatMessage(role: .user, text: text, imageData: attachedImage))
            if followUps.contains(where: { $0.label == text }) {
                followUps.removeAll { $0.label == text }
            } else {
                followUps = []
            }
        }
        input = ""
        attachedImage = nil
        requestReply()
    }

    /// Asks Mia's AI to reply to the conversation so far. With no API key, a session follow up
    /// gets its written reply and anything else gets a sample one.
    private func requestReply() {
        if !state.profile.isPremium && state.aiMessagesLeft == 0 { return }
        withAnimation(.easeOut(duration: 0.2)) { isTyping = true }
        state.recordAIMessage()

        let history = state.chatMessages
        let apiKey = state.apiKey
        let name = state.firstName
        let goals = state.profile.goals
        let token = flowID
        Task { @MainActor in
            let replyText: String
            let lastText = history.last?.text ?? ""
            if apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
               let written = MiaSessions.followUpReply(for: lastText, name: name) {
                try? await Task.sleep(nanoseconds: 1_400_000_000)
                replyText = written
            } else {
                do {
                    replyText = try await MiaAI.reply(to: history, apiKey: apiKey, userName: name, goals: goals)
                } catch {
                    replyText = "Sorry, I couldn't connect just now (\(error.localizedDescription)). Please try again in a moment."
                }
            }
            guard token == flowID else { return }
            withAnimation(.easeOut(duration: 0.15)) { isTyping = false }
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                state.chatMessages.append(ChatMessage(role: .assistant, text: replyText))
            }
        }
    }

    // MARK: Screenshots

    #if DEBUG
    /// `-screen miaSession`: part way through a session. `-screen miaPlan`: a finished plan.
    private func prefillForScreenshot() {
        if state.screenshotScreen == "miaLive" {
            // Plays a whole session with real timing: picks the first answer each time, then a follow up.
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 800_000_000)
                start(MiaSessions.beforeADate)
                for _ in 0..<3 {
                    while !choicesVisible { try? await Task.sleep(nanoseconds: 100_000_000) }
                    try? await Task.sleep(nanoseconds: 400_000_000)
                    if let s = session { answer(s.questions[sessionStep].options[0]) }
                }
                while followUps.isEmpty { try? await Task.sleep(nanoseconds: 100_000_000) }
                try? await Task.sleep(nanoseconds: 600_000_000)
                send(followUps[0].label)
            }
            return
        }
        guard let screen = state.screenshotScreen, screen == "miaSession" || screen == "miaPlan" else { return }
        let demo = MiaSessions.beforeADate
        session = demo
        state.chatMessages += [ChatMessage(role: .user, text: demo.title),
                               ChatMessage(role: .assistant, text: demo.opener),
                               ChatMessage(role: .assistant, text: demo.questions[0].text),
                               ChatMessage(role: .user, text: "Tomorrow"),
                               ChatMessage(role: .assistant, text: demo.questions[1].text)]
        answers = ["Tomorrow"]
        sessionStep = 1
        if screen == "miaPlan" {
            answers += ["Drinks", "A little nervous"]
            let plan = demo.plan(answers)
            state.chatMessages += [ChatMessage(role: .user, text: "Drinks"),
                                   ChatMessage(role: .assistant, text: demo.questions[2].text),
                                   ChatMessage(role: .user, text: "A little nervous"),
                                   ChatMessage(role: .assistant, text: "Thank you, \(state.firstName). Here's what I'd do."),
                                   ChatMessage(role: .assistant, text: plan.asText, plan: plan)]
            session = nil
            followUps = demo.followUps
        } else {
            choicesVisible = true
        }
    }
    #endif
}

/// Cards that sink a touch under the finger.
private struct PressScaleStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

private struct TypingDots: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(i == 1 ? Theme.goldDot : Theme.green)
                    .frame(width: 7, height: 7)
                    .offset(y: animating ? -3 : 2)
                    .animation(.easeInOut(duration: 0.45).repeatForever().delay(Double(i) * 0.15), value: animating)
            }
        }
        .onAppear { animating = true }
    }
}
