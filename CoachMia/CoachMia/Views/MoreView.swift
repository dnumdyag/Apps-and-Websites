import SwiftUI

struct MoreView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showMembership = false
    @State private var showBooking = false
    @State private var retreatAlert: Retreat?
    @State private var confirmReset = false

    private var monthsAsMember: Int {
        Calendar.current.dateComponents([.month], from: state.profile.joinedAt, to: Date()).month ?? 0
    }

    private var profileDetail: String {
        let age = state.profile.age.trimmingCharacters(in: .whitespaces)
        return age.isEmpty ? state.profile.relationshipStatus : "\(age) · \(state.profile.relationshipStatus)"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ScreenHeader(title: "Deepen your journey", subtitle: "When you're ready for more support")

                    profileCard
                    membershipCard
                    privateSessionsCard
                    retreatsSection
                    referralCard
                    becomeCoachCard
                    settingsCard
                    supportCard
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .miaBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showMembership) {
                MembershipView().environmentObject(state)
            }
            .sheet(isPresented: $showBooking) {
                BookingView().environmentObject(state)
            }
            .alert(item: $retreatAlert) { retreat in
                Alert(
                    title: Text(retreat.title),
                    message: Text("Thanks for your interest! A secure payment link for the \(Config.currency)\(retreat.price.formatted()) deposit will be sent to you. (Simulated in this preview.)"),
                    dismissButton: .default(Text("Lovely"))
                )
            }
            .confirmationDialog("Reset all demo data?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset and restart onboarding", role: .destructive) {
                    dismiss()
                    state.resetDemo()
                }
            }
        }
    }

    // MARK: Cards

    private var profileCard: some View {
        HStack(spacing: 16) {
            Text(String(state.firstName.prefix(1)).uppercased())
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(Theme.gold)
                .frame(width: 56, height: 56)
                .background(Theme.gold.opacity(0.1), in: Circle())
                .overlay(Circle().stroke(Theme.gold.opacity(0.25)))
            VStack(alignment: .leading, spacing: 4) {
                Text(state.profile.name.isEmpty ? "Member" : state.profile.name)
                    .font(.system(size: 19, weight: .light))
                    .foregroundStyle(Theme.text)
                Text(profileDetail)
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer()
            Pill(text: state.profile.isPremium ? "Full member" : "Free", tint: state.profile.isPremium ? Theme.gold : Theme.textSoft)
        }
        .miaCard(padding: 20)
    }

    private var membershipCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "crown").foregroundStyle(Theme.gold)
                Text("Full membership")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(Theme.text)
            }
            Text("Everything available to support your growth")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Theme.textSoft)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(MockData.premiumFeatures, id: \.self) { feature in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle").foregroundStyle(Theme.gold.opacity(0.8))
                        Text(feature)
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(Theme.text)
                    }
                }
            }
            Text("1,842 men exploring together")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Theme.textMuted)
            Button(state.profile.isPremium ? "Manage membership" : "Explore membership") {
                showMembership = true
            }
            .buttonStyle(GoldButtonStyle())
        }
        .miaCard(padding: 26, fill: LinearGradient(colors: [Theme.gold.opacity(0.14), Theme.card2.opacity(0.7)],
                                                   startPoint: .topLeading, endPoint: .bottomTrailing))
    }

    private var privateSessionsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "calendar").foregroundStyle(Theme.gold)
                Text("Private sessions")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(Theme.text)
            }
            Text("Personal 1:1 time with Mia or one of our guest coaches when you need deeper support.")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Theme.textSoft)
            if !state.profile.bookings.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(state.profile.bookings) { booking in
                        Label("\(booking.coachName) · \(booking.date.formatted(.dateTime.month().day())) · \(booking.slot)",
                              systemImage: "checkmark.circle.fill")
                            .font(.system(size: 13, weight: .light))
                            .foregroundStyle(Theme.gold)
                    }
                }
            }
            Button("Book a session") { showBooking = true }
                .buttonStyle(SoftButtonStyle())
        }
        .miaCard()
    }

    private var retreatsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "mountain.2").foregroundStyle(Theme.gold)
                Text("Retreats")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(Theme.text)
            }
            Text("Immersive experiences when you're ready")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Theme.textSoft)
            ForEach(MockData.retreats) { retreat in
                VStack(alignment: .leading, spacing: 12) {
                    if retreat.spots <= 5 {
                        Pill(text: "\(retreat.spots) spots left", tint: Color(hex: 0xFDBA74))
                    }
                    Text(retreat.title)
                        .font(.system(size: 17, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text("\(retreat.location) · \(retreat.dates)")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Investment")
                                .font(.system(size: 11, weight: .light))
                                .foregroundStyle(Theme.textMuted)
                            Text("\(Config.currency)\(retreat.price.formatted())")
                                .font(.system(size: 20, weight: .light))
                                .foregroundStyle(Theme.gold)
                        }
                        Spacer()
                        Button("Learn more") { retreatAlert = retreat }
                            .buttonStyle(ChipButtonStyle())
                    }
                }
                .miaCard(padding: 20)
            }
        }
    }

    private var referralCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "gift").foregroundStyle(Theme.gold)
                Text("Invite a friend")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(Theme.text)
            }
            Text("When a friend joins with your code, you both get one month free.")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Theme.textSoft)
            HStack {
                Text(state.profile.referralCode)
                    .font(.system(size: 18, weight: .medium, design: .monospaced))
                    .foregroundStyle(Theme.gold)
                Spacer()
                ShareLink(item: "I've been using Coach Mia to level up my dating life. Use my code \(state.profile.referralCode) for a free month: \(Config.websiteURL.absoluteString)") {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(ChipButtonStyle(selected: true))
            }
            .padding(16)
            .background(Theme.chip.opacity(0.5), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .miaCard()
    }

    private var becomeCoachCard: some View {
        let progress = min(Double(monthsAsMember), 12)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "star").foregroundStyle(Theme.gold)
                Text("Become a coach")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(Theme.text)
            }
            Text("After 12 months of consistent membership you can apply to train as a Coach Mia coach and get paid to help others.")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Theme.textSoft)
            ProgressView(value: progress, total: 12)
                .tint(Theme.gold)
            Text("\(Int(progress)) of 12 months")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Theme.textMuted)
        }
        .miaCard()
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "gearshape").foregroundStyle(Theme.gold)
                Text("Settings")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(Theme.text)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Coach Mia AI key (Anthropic)")
                    .font(.system(size: 13, weight: .light))
                    .foregroundStyle(Theme.textSoft)
                SecureField("", text: $state.apiKey, prompt: Text("sk-ant-...").foregroundColor(Theme.textMuted))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundStyle(Theme.text)
                    .padding(14)
                    .background(Theme.chip.opacity(0.5), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                Text(state.apiKey.isEmpty
                     ? "No key set: Mia uses offline demo replies."
                     : "Key set: Mia replies live using Claude.")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(Theme.textMuted)
            }
            Toggle(isOn: $state.profile.isPremium) {
                Text("Full membership (demo switch)")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Theme.text)
            }
            .tint(Theme.gold)
            Button("Reset demo data") { confirmReset = true }
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Color(hex: 0xF0A0A0))
        }
        .miaCard()
    }

    private var supportCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles").foregroundStyle(Theme.gold)
            Text("Questions?")
                .font(.system(size: 18, weight: .light))
                .foregroundStyle(Theme.text)
            Text("We're here if you need guidance")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Theme.textSoft)
            if let url = URL(string: "mailto:\(Config.supportEmail)") {
                Link("Reach out", destination: url)
                    .buttonStyle(ChipButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .miaCard()
    }
}

// MARK: - Membership / paywall

struct MembershipView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan = 1

    private let plans: [(name: String, price: String, detail: String)] = [
        ("Monthly", "\(Config.currency)29.99 / month", "Cancel anytime"),
        ("Yearly", "\(Config.currency)199.99 / year", "Save 44% · 7 days free"),
        ("VIP", "\(Config.currency)99 / month", "Everything + monthly 1:1 with Mia"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Theme.textMuted)
                            .padding(10)
                            .background(Theme.chip.opacity(0.5), in: Circle())
                    }
                }
                MiaAvatar(size: 60)
                Text("Unlock your full journey")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(Theme.text)
                if !state.profile.isPremium && state.aiMessagesLeft == 0 {
                    Text("You've used your \(AppState.freeMessagesPerMonth) free Mia messages this month. Upgrade for unlimited conversations.")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Theme.gold)
                }
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(MockData.premiumFeatures, id: \.self) { feature in
                        Label(feature, systemImage: "checkmark.circle")
                            .font(.system(size: 15, weight: .light))
                            .foregroundStyle(Theme.text)
                    }
                }

                VStack(spacing: 12) {
                    ForEach(Array(plans.enumerated()), id: \.offset) { index, plan in
                        Button {
                            selectedPlan = index
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(plan.name)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(Theme.text)
                                    Text(plan.detail)
                                        .font(.system(size: 12, weight: .light))
                                        .foregroundStyle(Theme.textMuted)
                                }
                                Spacer()
                                Text(plan.price)
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundStyle(Theme.gold)
                            }
                            .padding(18)
                            .background(selectedPlan == index ? Theme.gold.opacity(0.12) : Theme.chip.opacity(0.45),
                                        in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(selectedPlan == index ? Theme.gold.opacity(0.6) : Theme.border.opacity(0.3)))
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

                Text("Tip: join on our website for a lower price than in-app. Purchases are simulated in this preview.")
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(Theme.textMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            .padding(24)
        }
        .miaBackground()
    }
}

// MARK: - 1:1 booking

struct BookingView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var coachID = 0
    @State private var date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var slot: String?
    @State private var confirmed = false

    private var coach: Coach { MockData.coaches.first { $0.id == coachID } ?? MockData.coaches[0] }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
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
                            .tint(Theme.gold)
                            .miaCard(padding: 12)

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
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(Theme.textMuted)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(24)
            }
            .miaBackground()
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
        Button {
            coachID = c.id
        } label: {
            HStack(spacing: 14) {
                if c.isMia {
                    MiaAvatar(size: 44)
                } else {
                    Text(String(c.name.prefix(1)))
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.gold)
                        .frame(width: 44, height: 44)
                        .background(Theme.gold.opacity(0.1), in: Circle())
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(c.name)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Theme.text)
                    Text(c.specialty)
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                    Text("\(c.sessions.formatted()) sessions")
                        .font(.system(size: 11, weight: .light))
                        .foregroundStyle(Theme.textMuted)
                }
                Spacer()
                Text("\(Config.currency)\(c.price)")
                    .font(.system(size: 16, weight: .light))
                    .foregroundStyle(Theme.gold)
            }
            .padding(16)
            .background(coachID == c.id ? Theme.gold.opacity(0.12) : Theme.chip.opacity(0.45),
                        in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(coachID == c.id ? Theme.gold.opacity(0.6) : Theme.border.opacity(0.3)))
        }
        .buttonStyle(.plain)
    }

    private var confirmation: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64, weight: .thin))
                .foregroundStyle(Theme.gold)
                .padding(.top, 40)
            Text("You're booked")
                .font(.system(size: 28, weight: .light))
                .foregroundStyle(Theme.text)
            Text("\(coach.name) · \(date.formatted(.dateTime.weekday(.wide).month().day())) · \(slot ?? "")")
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Theme.textSoft)
                .multilineTextAlignment(.center)
            Text("You'll get a calendar invite and a video link by email.")
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(Theme.textMuted)
            Button("Done") { dismiss() }
                .buttonStyle(GoldButtonStyle())
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity)
    }
}
