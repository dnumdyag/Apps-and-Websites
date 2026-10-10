import SwiftUI
import AVKit

struct SessionsView: View {
    @EnvironmentObject var state: AppState

    enum Segment: String, CaseIterable {
        case upcoming = "Upcoming"
        case events = "Events"
        case recordings = "Recordings"
    }

    @State private var segment: Segment = .upcoming
    @State private var theme = "All"
    @State private var playing: Recording?
    @State private var eventToBook: MemberEvent?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    ScreenHeader(title: "Live ", accent: "sessions", subtitle: "Join when it feels right for you")
                    segmentPicker

                    switch segment {
                    case .upcoming: upcomingSection
                    case .events: eventsSection
                    case .recordings: recordingsSection
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .screenBackground()
            .toolbar(.hidden, for: .navigationBar)
            .sheet(item: $playing) { recording in
                RecordingPlayerView(recording: recording)
            }
            .sheet(item: $eventToBook) { event in
                EventBookingSheet(event: event)
                    .environmentObject(state)
                    .presentationDetents([.medium])
            }
        }
    }

    private var segmentPicker: some View {
        HStack(spacing: 4) {
            ForEach(Segment.allCases, id: \.self) { s in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { segment = s }
                } label: {
                    Text(s.rawValue)
                        .font(Theme.sans(14, .semibold))
                        .foregroundStyle(segment == s ? Theme.onGreen : Theme.muted)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(segment == s ? Theme.green : Color.clear, in: Capsule())
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Theme.surface, in: Capsule())
    }

    private func isReserved(_ session: LiveSession) -> Bool {
        state.profile.reservedSessions.contains(session.id)
    }

    private func toggle(_ session: LiveSession) {
        withAnimation {
            if isReserved(session) { _ = state.profile.reservedSessions.remove(session.id) }
            else { _ = state.profile.reservedSessions.insert(session.id) }
        }
    }

    // MARK: Upcoming

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            featuredCard(MockData.liveSessions[0])
            VStack(alignment: .leading, spacing: 12) {
                SectionLabel("Coming up")
                ForEach(MockData.liveSessions.dropFirst()) { session in
                    smallSessionCard(session)
                }
            }
        }
    }

    private func featuredCard(_ session: LiveSession) -> some View {
        let reserved = isReserved(session)
        let joining = session.attendees + (reserved ? 1 : 0)
        let spotsLeft = session.maxAttendees - joining
        return VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .top) {
                FillPhoto(name: session.image, height: 190)
                HStack {
                    PhotoBadge(text: "\(session.date) · \(session.time)", dot: Color(hex: 0xF08A6E))
                    Spacer()
                    if spotsLeft < 10 {
                        PhotoBadge(text: "Almost full", color: Color(hex: 0xF3D9A0))
                    }
                }
                .padding(14)
            }
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    SectionLabel(session.kind.rawValue, color: Theme.goldText)
                    Text(session.title)
                        .font(Theme.serif(28, .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("with \(session.host)")
                        .font(Theme.sans(14))
                        .foregroundStyle(Theme.muted)
                }
                VStack(spacing: 8) {
                    HStack {
                        Text("\(joining) others joining").foregroundStyle(Theme.muted)
                        Spacer()
                        Text("\(spotsLeft) spots left").foregroundStyle(Theme.goldText)
                    }
                    .font(Theme.sans(12.5, .semibold))
                    ProgressLine(value: Double(joining) / Double(session.maxAttendees), height: 6)
                }
                if reserved {
                    Button { toggle(session) } label: {
                        Label("You're in · \(session.date) · \(session.time)", systemImage: "checkmark")
                    }
                    .buttonStyle(OutlineButtonStyle(fullWidth: true, height: 52))
                } else {
                    Button { toggle(session) } label: {
                        Label("Join this session", systemImage: "video")
                    }
                    .buttonStyle(GoldButtonStyle())
                }
            }
            .padding(20)
        }
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private func smallSessionCard(_ session: LiveSession) -> some View {
        let reserved = isReserved(session)
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                FillPhoto(name: session.image, height: 64, width: 64, radius: 16)
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.kind.rawValue.uppercased())
                        .font(Theme.sans(10, .semibold))
                        .tracking(2)
                        .foregroundStyle(Theme.goldText)
                    Text(session.title)
                        .font(Theme.serif(21, .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("with \(session.host)")
                        .font(Theme.sans(12.5))
                        .foregroundStyle(Theme.muted)
                }
            }
            HStack {
                Label("\(session.date) · \(session.time)", systemImage: "calendar")
                    .font(Theme.sans(13.5, .medium))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Button(reserved ? "Reserved" : "Reserve") { toggle(session) }
                    .buttonStyle(reserved ? AnyButtonStyle(ChipButtonStyle(selected: true)) : AnyButtonStyle(OutlineButtonStyle()))
            }
        }
        .whiteCard(padding: 16)
    }

    // MARK: Member events

    private var filteredEvents: [MemberEvent] {
        theme == "All" ? MockData.memberEvents : MockData.memberEvents.filter { $0.theme == theme }
    }

    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Exclusive in-person evenings for members. Meet like-minded men, grow your circle and practise in real life.")
                .font(Theme.sans(14))
                .foregroundStyle(Theme.muted)
                .lineSpacing(3)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MockData.eventThemes, id: \.self) { t in
                        Button(t) { withAnimation { theme = t } }
                            .buttonStyle(ChipButtonStyle(selected: theme == t))
                    }
                }
                .padding(.vertical, 1)
            }

            ForEach(filteredEvents) { event in
                eventCard(event)
            }
        }
    }

    private func eventCard(_ event: MemberEvent) -> some View {
        let booked = state.profile.bookedEvents.contains(event.id)
        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: event.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.goldOnGreen)
                    .frame(width: 52, height: 52)
                    .background(Theme.green, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.theme.uppercased())
                        .font(Theme.sans(10, .semibold))
                        .tracking(2)
                        .foregroundStyle(Theme.goldText)
                    Text(event.title)
                        .font(Theme.serif(21, .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("\(event.venue) · \(event.city)")
                        .font(Theme.sans(12.5))
                        .foregroundStyle(Theme.muted)
                }
                Spacer(minLength: 0)
                if event.spotsLeft <= 5 {
                    Text("\(event.spotsLeft) left")
                        .font(Theme.sans(11, .semibold))
                        .foregroundStyle(Theme.red)
                }
            }
            HStack {
                Label("\(event.date) · \(event.time)", systemImage: "calendar")
                    .font(Theme.sans(13.5, .medium))
                    .foregroundStyle(Theme.ink)
                Spacer()
                if booked {
                    Label("Going", systemImage: "checkmark")
                        .font(Theme.sans(14, .semibold))
                        .foregroundStyle(Theme.green)
                } else {
                    Button(event.price == 0 ? "Reserve" : "\(Config.currency)\(event.price)") { eventToBook = event }
                        .buttonStyle(OutlineButtonStyle())
                }
            }
        }
        .whiteCard(padding: 16)
    }

    // MARK: Recordings

    private var recordingsSection: some View {
        VStack(spacing: 12) {
            ForEach(MockData.recordings) { recording in
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        FillPhoto(name: recording.image, height: 96, width: 96, radius: 16)
                        Image(systemName: "play.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(Color(hex: 0xF3D9A0))
                            .frame(width: 34, height: 34)
                            .liquidGlass(in: Circle(), tint: Color(hex: 0x081813, opacity: 0.55)) {
                                $0.background(Color(hex: 0x081813, opacity: 0.78), in: Circle())
                            }
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(recording.title)
                            .font(Theme.serif(20, .semibold))
                            .foregroundStyle(Theme.ink)
                        Text("with \(recording.host)")
                            .font(Theme.sans(13))
                            .foregroundStyle(Theme.muted)
                        Text("\(recording.duration) · \(recording.date)")
                            .font(Theme.sans(12))
                            .foregroundStyle(Theme.muted)
                        Button {
                            playing = recording
                        } label: {
                            Label("Watch when ready", systemImage: "play.circle")
                                .font(Theme.sans(13.5, .bold))
                                .foregroundStyle(Theme.green)
                                .frame(minHeight: 36)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .whiteCard(padding: 14)
            }
        }
    }
}

struct RecordingPlayerView: View {
    let recording: Recording
    @State private var player = AVPlayer(url: MockData.sampleVideoURL)

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VideoPlayer(player: player)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            Text(recording.title)
                .font(Theme.serif(28, .semibold))
                .foregroundStyle(Theme.ink)
            Text("with \(recording.host) · \(recording.duration)")
                .font(Theme.sans(14))
                .foregroundStyle(Theme.muted)
            Spacer()
        }
        .padding(24)
        .screenBackground()
        .onAppear { player.play() }
        .onDisappear { player.pause() }
    }
}

struct EventBookingSheet: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    let event: MemberEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionLabel(event.theme, color: Theme.goldText)
            Text(event.title)
                .font(Theme.serif(30, .semibold))
                .foregroundStyle(Theme.ink)
            VStack(alignment: .leading, spacing: 8) {
                Label("\(event.venue), \(event.city)", systemImage: "mappin.and.ellipse")
                Label("\(event.date) at \(event.time)", systemImage: "calendar")
                Label(event.price == 0 ? "Included in your membership" : "\(Config.currency)\(event.price) per person", systemImage: "creditcard")
            }
            .font(Theme.sans(14.5))
            .foregroundStyle(Theme.muted)
            Spacer()
            Button(event.price == 0 ? "Confirm my spot" : "Pay \(Config.currency)\(event.price) & confirm") {
                state.profile.bookedEvents.insert(event.id)
                dismiss()
            }
            .buttonStyle(GoldButtonStyle())
            Text("Payments are simulated in this preview.")
                .font(Theme.sans(12))
                .foregroundStyle(Theme.muted)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .padding(.top, 8)
        .screenBackground()
    }
}
