import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var state: AppState

    @State private var showEdit = false
    @State private var showMembership = false
    @State private var showAIKey = false
    @State private var confirmSignOut = false
    @State private var photoItem: PhotosPickerItem?

    private var monthsAsMember: Int {
        Calendar.current.dateComponents([.month], from: state.profile.joinedAt, to: Date()).month ?? 0
    }

    private var joinedGroups: [CommunityGroup] {
        MockData.groups.filter { state.profile.joinedGroups.contains($0.id) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                header
                blindSpotCard
                statsRow
                aboutSection
                if !joinedGroups.isEmpty { groupsSection }
                membershipCard
                referralCard
                becomeCoachCard
                settingsSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .screenBackground()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit profile") { showEdit = true }
                    .buttonStyle(OutlineButtonStyle(height: 36))
            }
        }
        .sheet(isPresented: $showEdit) { EditProfileView().environmentObject(state) }
        .sheet(isPresented: $showMembership) { MembershipView().environmentObject(state) }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { @MainActor in
                if let data = try? await item.loadTransferable(type: Data.self) {
                    state.profile.avatarData = ImageUtil.prepareForUpload(data, maxDimension: 400)
                }
                photoItem = nil
            }
        }
        .confirmationDialog("Sign out and reset this demo?", isPresented: $confirmSignOut, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) { state.resetDemo() }
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                UserAvatar(size: 104)
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.onGreen)
                            .frame(width: 30, height: 30)
                            .background(Theme.green, in: Circle())
                            .overlay(Circle().stroke(Theme.background, lineWidth: 2))
                    }
            }
            .accessibilityLabel("Change profile photo")
            VStack(alignment: .leading, spacing: 4) {
                Text(state.profile.name.isEmpty ? "Member" : state.profile.name)
                    .font(Theme.serif(40, .medium))
                    .foregroundStyle(Theme.ink)
                Text(subtitle)
                    .font(Theme.sans(13.5))
                    .foregroundStyle(Theme.muted)
            }
        }
    }

    private var subtitle: String {
        var parts: [String] = []
        let age = state.profile.age.trimmingCharacters(in: .whitespaces)
        if !age.isEmpty { parts.append(age) }
        parts.append(state.profile.relationshipStatus)
        parts.append("Member since \(state.profile.joinedAt.formatted(.dateTime.month(.wide).year()))")
        return parts.joined(separator: " · ")
    }

    private var blindSpotCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("YOUR BLIND SPOT")
                .font(Theme.sans(11, .semibold))
                .tracking(2)
                .foregroundStyle(Theme.goldOnGreen)
            Text(state.profile.blindSpot.isEmpty ? "Take the quiz to find yours" : state.profile.blindSpot)
                .font(Theme.serif(30, .semibold))
            Text("From your quiz. Your plan is built around this pattern.")
                .font(Theme.sans(13.5))
                .foregroundStyle(Theme.onGreenMuted)
        }
        .greenCard()
    }

    private var statsRow: some View {
        HStack(spacing: 10) {
            statTile(Text("\(state.streak)"), "day streak")
            statTile(Text("\(state.profile.challengeDays.count)"), "challenges")
            statTile(Text("\(state.profile.completedModules.count)")
                     + Text(" / \(MockData.modules.count)").font(Theme.serif(20, .semibold)).foregroundColor(Theme.muted),
                     "modules")
        }
    }

    private func statTile(_ value: Text, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            value
                .font(Theme.serif(38, .semibold))
                .foregroundColor(Theme.green)
            Text(label)
                .font(Theme.sans(12.5))
                .foregroundStyle(Theme.muted)
        }
        .whiteCard(padding: 16)
    }

    // MARK: Lists

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("About you")
            VStack(spacing: 0) {
                row("Name", state.profile.name)
                divider
                row("Age", state.profile.age.isEmpty ? "Not set" : state.profile.age)
                divider
                row("Status", state.profile.relationshipStatus)
                divider
                row("Looking for", state.profile.goals.first ?? "Not set")
                divider
                row("Current module", state.nextModule.title)
            }
            .padding(.horizontal, 18)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private var divider: some View {
        Rectangle().fill(Theme.divider).frame(height: 1)
    }

    private func row(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Theme.muted)
            Spacer()
            Text(value)
                .foregroundStyle(Theme.ink)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
        .font(Theme.sans(14, .medium))
        .frame(minHeight: 50)
    }

    private var groupsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Your groups")
            VStack(spacing: 0) {
                ForEach(joinedGroups) { group in
                    Button {
                        state.selectedTab = .community
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(group.name)
                                    .font(Theme.sans(14.5, .semibold))
                                    .foregroundStyle(Theme.ink)
                                Text("\(group.members.formatted()) members")
                                    .font(Theme.sans(12))
                                    .foregroundStyle(Theme.muted)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Theme.muted)
                        }
                        .frame(minHeight: 60)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    if group.id != joinedGroups.last?.id { divider }
                }
            }
            .padding(.horizontal, 18)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    // MARK: Cards

    private var membershipCard: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("MEMBERSHIP")
                    .font(Theme.sans(11, .semibold))
                    .tracking(2)
                    .foregroundStyle(Theme.goldCardInk)
                Text(state.profile.isPremium ? "Full membership" : "Free plan")
                    .font(Theme.serif(24, .semibold))
            }
            Spacer()
            Button(state.profile.isPremium ? "Manage" : "Explore") { showMembership = true }
                .buttonStyle(DarkButtonStyle(fullWidth: false))
        }
        .goldCard(padding: 20, radius: 22)
    }

    private var referralCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Invite a friend")
                .font(Theme.serif(24, .semibold))
                .foregroundStyle(Theme.ink)
            Text("When a friend joins with your code, you both get one month free.")
                .font(Theme.sans(14))
                .foregroundStyle(Theme.muted)
            HStack {
                Text(state.profile.referralCode)
                    .font(.system(size: 17, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Theme.green)
                Spacer()
                ShareLink(item: "I've been using Coach Mia to work on my dating life. Use my code \(state.profile.referralCode) for a free month: \(Config.websiteURL.absoluteString)") {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(OutlineButtonStyle())
            }
            .padding(.leading, 16)
            .padding(.trailing, 4)
            .padding(.vertical, 4)
            .background(Theme.background, in: Capsule())
        }
        .whiteCard(padding: 20)
    }

    private var becomeCoachCard: some View {
        let progress = min(Double(monthsAsMember), 12)
        return VStack(alignment: .leading, spacing: 10) {
            Text("Become a coach")
                .font(Theme.serif(24, .semibold))
                .foregroundStyle(Theme.ink)
            Text("After 12 months of consistent membership you can apply to train as a Coach Mia coach and get paid to help others.")
                .font(Theme.sans(14))
                .foregroundStyle(Theme.muted)
            ProgressLine(value: progress / 12, height: 6)
                .padding(.top, 4)
            Text("\(Int(progress)) of 12 months")
                .font(Theme.sans(12, .semibold))
                .foregroundStyle(Theme.goldText)
        }
        .whiteCard(padding: 20)
    }

    // MARK: Settings

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionLabel("Settings")
            VStack(spacing: 0) {
                Button {
                    withAnimation { showAIKey.toggle() }
                } label: {
                    settingsRow("Coach Mia AI", detail: state.apiKey.isEmpty ? "Demo replies" : "Live")
                }
                .buttonStyle(.plain)
                if showAIKey {
                    VStack(alignment: .leading, spacing: 8) {
                        SecureField("", text: $state.apiKey, prompt: Text("Anthropic API key (sk-ant-...)").foregroundColor(Theme.faint))
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .font(.system(size: 14, design: .monospaced))
                            .padding(.horizontal, 16)
                            .frame(height: 46)
                            .background(Theme.background, in: Capsule())
                        Text("Without a key, Mia uses built-in demo replies.")
                            .font(Theme.sans(12))
                            .foregroundStyle(Theme.muted)
                    }
                    .padding(.bottom, 14)
                }
                divider
                Toggle(isOn: $state.profile.isPremium) {
                    Text("Full membership (demo)")
                        .font(Theme.sans(14.5, .medium))
                        .foregroundStyle(Theme.ink)
                }
                .tint(Theme.green)
                .frame(minHeight: 54)
                divider
                if let url = URL(string: "mailto:\(Config.supportEmail)") {
                    Link(destination: url) {
                        settingsRow("Help and support", detail: nil)
                    }
                    divider
                }
                Button {
                    confirmSignOut = true
                } label: {
                    Text("Sign out")
                        .font(Theme.sans(14.5, .semibold))
                        .foregroundStyle(Theme.red)
                        .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
    }

    private func settingsRow(_ title: String, detail: String?) -> some View {
        HStack {
            Text(title)
                .font(Theme.sans(14.5, .medium))
                .foregroundStyle(Theme.ink)
            Spacer()
            if let detail {
                Text(detail)
                    .font(Theme.sans(13))
                    .foregroundStyle(Theme.muted)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.muted)
        }
        .frame(minHeight: 54)
        .contentShape(Rectangle())
    }
}

// MARK: - Edit profile

struct EditProfileView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var age = ""
    @State private var status = "Single"
    private let statuses = ["Single", "Dating", "In a relationship", "It's complicated"]

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 22) {
                field("First name", text: $name)
                field("Age", text: $age).keyboardType(.numberPad)
                VStack(alignment: .leading, spacing: 10) {
                    SectionLabel("Relationship status")
                    FlowLayout {
                        ForEach(statuses, id: \.self) { s in
                            Button(s) { status = s }
                                .buttonStyle(ChipButtonStyle(selected: status == s))
                        }
                    }
                }
                Spacer()
                Button("Save") {
                    state.profile.name = name.trimmingCharacters(in: .whitespaces)
                    state.profile.age = age
                    state.profile.relationshipStatus = status
                    dismiss()
                }
                .buttonStyle(GoldButtonStyle())
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(24)
            .screenBackground()
            .navigationTitle("Edit profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                name = state.profile.name
                age = state.profile.age
                status = state.profile.relationshipStatus
            }
        }
    }

    private func field(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(label)
            TextField("", text: text)
                .font(Theme.sans(16))
                .foregroundStyle(Theme.ink)
                .padding(.horizontal, 20)
                .frame(height: 52)
                .background(Theme.surface, in: Capsule())
                .overlay(Capsule().stroke(Theme.outline, lineWidth: 1.5))
        }
    }
}

// MARK: - Membership

struct MembershipView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan = 1

    private let plans: [(name: String, price: String, detail: String)] = [
        ("Monthly", "\(Config.currency)29.99 / month", "Cancel anytime"),
        ("Yearly", "\(Config.currency)199.99 / year", "Save 44% · 7 days free"),
        ("VIP", "\(Config.currency)99 / month", "Everything, plus a monthly 1:1 with Mia"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.muted)
                            .frame(width: 40, height: 40)
                            .background(Theme.surface, in: Circle())
                    }
                    .accessibilityLabel("Close")
                }

                VStack(alignment: .leading, spacing: 16) {
                    Label("FULL MEMBERSHIP", systemImage: "crown")
                        .font(Theme.sans(11, .semibold))
                        .tracking(2)
                        .foregroundStyle(Theme.goldCardInk)
                    Text("Everything available to support your growth")
                        .font(Theme.serif(30, .semibold))
                        .fixedSize(horizontal: false, vertical: true)
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(MockData.premiumFeatures, id: \.self) { feature in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .frame(width: 22, height: 22)
                                    .background(Color(hex: 0x14261E, opacity: 0.14), in: Circle())
                                Text(feature)
                                    .font(Theme.sans(14.5, .medium))
                            }
                        }
                    }
                }
                .goldCard()

                if !state.profile.isPremium && state.aiMessagesLeft == 0 {
                    Text("You've used your \(AppState.freeMessagesPerMonth) free Mia messages this month. Full members talk to Mia without limits.")
                        .font(Theme.sans(14, .medium))
                        .foregroundStyle(Theme.goldText)
                }

                VStack(spacing: 10) {
                    ForEach(plans.indices, id: \.self) { index in
                        let plan = plans[index]
                        let selected = selectedPlan == index
                        Button {
                            selectedPlan = index
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(plan.name)
                                        .font(Theme.sans(15, .bold))
                                    Text(plan.detail)
                                        .font(Theme.sans(12.5))
                                        .foregroundStyle(selected ? Theme.onGreenMuted : Theme.muted)
                                }
                                Spacer()
                                Text(plan.price)
                                    .font(Theme.serif(20, .semibold))
                                    .foregroundStyle(selected ? Theme.goldOnGreen : Theme.green)
                            }
                            .foregroundStyle(selected ? Theme.onGreen : Theme.ink)
                            .padding(.horizontal, 20)
                            .frame(minHeight: 70)
                            .background(selected ? Theme.green : Theme.surface,
                                        in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }

                Button(state.profile.isPremium ? "You're a full member" : "Start membership") {
                    state.profile.isPremium = true
                    dismiss()
                }
                .buttonStyle(GoldButtonStyle())
                .disabled(state.profile.isPremium)

                Text("Tip: joining on our website costs less than in-app. Purchases are simulated in this preview.")
                    .font(Theme.sans(12))
                    .foregroundStyle(Theme.muted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(24)
        }
        .screenBackground()
    }
}

// MARK: - 1:1 booking

struct BookingView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var coachID: Int
    @State private var date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var slot: String?
    @State private var confirmed = false

    init(initialCoachID: Int = 0) {
        _coachID = State(initialValue: initialCoachID)
    }

    private var coach: Coach { MockData.coaches.first { $0.id == coachID } ?? MockData.coaches[0] }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    if confirmed {
                        confirmation
                    } else {
                        SectionLabel("Choose your coach")
                        ForEach(MockData.coaches) { c in
                            coachRow(c)
                        }

                        SectionLabel("Pick a day")
                        DatePicker("", selection: $date, in: Date()..., displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .tint(Theme.green)
                            .padding(8)
                            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                        SectionLabel("Pick a time")
                        FlowLayout {
                            ForEach(MockData.timeSlots, id: \.self) { s in
                                Button(s) { slot = s }
                                    .buttonStyle(ChipButtonStyle(selected: slot == s))
                            }
                        }

                        Button("Pay \(Config.currency)\(coach.price) & book") {
                            guard let slot else { return }
                            state.profile.bookings.append(Booking(coachName: coach.name, date: date, slot: slot, price: coach.price))
                            withAnimation { confirmed = true }
                        }
                        .buttonStyle(GoldButtonStyle())
                        .disabled(slot == nil)
                        .opacity(slot == nil ? 0.5 : 1)

                        Text("50 minute video call. Payments are simulated in this preview.")
                            .font(Theme.sans(12))
                            .foregroundStyle(Theme.muted)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(24)
            }
            .screenBackground()
            .navigationTitle("Private session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func coachRow(_ c: Coach) -> some View {
        let selected = coachID == c.id
        return Button {
            coachID = c.id
        } label: {
            HStack(spacing: 14) {
                FillPhoto(name: c.image, height: 52, width: 52, radius: 26)
                VStack(alignment: .leading, spacing: 2) {
                    Text(c.name)
                        .font(Theme.sans(15, .bold))
                    Text(c.specialty)
                        .font(Theme.sans(12.5))
                        .foregroundStyle(selected ? Theme.onGreenMuted : Theme.muted)
                }
                Spacer()
                Text("\(Config.currency)\(c.price)")
                    .font(Theme.serif(22, .semibold))
                    .foregroundStyle(selected ? Theme.goldOnGreen : Theme.green)
            }
            .foregroundStyle(selected ? Theme.onGreen : Theme.ink)
            .padding(12)
            .background(selected ? Theme.green : Theme.surface,
                        in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var confirmation: some View {
        VStack(spacing: 16) {
            FillPhoto(name: coach.image, height: 110, width: 110, radius: 55)
                .padding(.top, 30)
            ScreenTitle(text: "You're ", accent: "booked")
            Text("\(coach.name) · \(date.formatted(.dateTime.weekday(.wide).month().day())) · \(slot ?? "")")
                .font(Theme.sans(15, .medium))
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.center)
            Text("You'll get a calendar invite and a video link by email.")
                .font(Theme.sans(13))
                .foregroundStyle(Theme.muted)
                .multilineTextAlignment(.center)
            Button("Done") { dismiss() }
                .buttonStyle(GoldButtonStyle())
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
    }
}
