import SwiftUI
import AVKit

struct SessionsView: View {
    @EnvironmentObject var state: AppState

    enum Segment: String, CaseIterable {
        case upcoming = "Live"
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
                VStack(alignment: .leading, spacing: 20) {
                    ScreenHeader(title: "Sessions", subtitle: "Join when it feels right for you")

                    Picker("", selection: $segment) {
                        ForEach(Segment.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)

                    switch segment {
                    case .upcoming:
                        ForEach(MockData.liveSessions) { liveCard($0) }
                    case .events:
                        eventsSection
                    case .recordings:
                        ForEach(MockData.recordings) { recordingCard($0) }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .miaBackground()
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

    // MARK: Live sessions

    private func liveCard(_ session: LiveSession) -> some View {
        let reserved = state.profile.reservedSessions.contains(session.id)
        let spotsLeft = session.maxAttendees - session.attendees
        let tint: Color = session.kind == .live ? Color(hex: 0x93C5FD) : session.kind == .webinar ? Color(hex: 0xD8B4FE) : Theme.gold

        return VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Pill(text: session.kind.rawValue, tint: tint)
                if spotsLeft < 10 { Pill(text: "Almost full", tint: Color(hex: 0xFDBA74)) }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(session.title)
                    .font(.system(size: 19, weight: .light))
                    .foregroundStyle(Theme.text)
                Text("with \(session.host)")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Theme.textSoft)
            }
            HStack(spacing: 16) {
                Label(session.date, systemImage: "calendar")
                Label(session.time, systemImage: "clock")
                Label("\(session.attendees + (reserved ? 1 : 0)) joining", systemImage: "person.2")
            }
            .font(.system(size: 12, weight: .light))
            .foregroundStyle(Theme.textMuted)

            Button {
                withAnimation {
                    if reserved { state.profile.reservedSessions.remove(session.id) }
                    else { state.profile.reservedSessions.insert(session.id) }
                }
            } label: {
                Label(reserved ? "You're in. We'll remind you." : "Join this session",
                      systemImage: reserved ? "checkmark" : "video")
            }
            .buttonStyle(reserved ? AnyButtonStyle(SoftButtonStyle()) : AnyButtonStyle(GoldButtonStyle()))
        }
        .miaCard()
    }

    // MARK: In-person member events

    private var filteredEvents: [MemberEvent] {
        theme == "All" ? MockData.memberEvents : MockData.memberEvents.filter { $0.theme == theme }
    }

    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Exclusive in-person events for members. Meet like-minded men, build your social circle and practise in real life.")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Theme.textSoft)
                .lineSpacing(3)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MockData.eventThemes, id: \.self) { t in
                        Button(t) { withAnimation { theme = t } }
                            .buttonStyle(ChipButtonStyle(selected: theme == t))
                    }
                }
            }

            ForEach(filteredEvents) { event in
                eventCard(event)
            }
        }
    }

    private func eventCard(_ event: MemberEvent) -> some View {
        let booked = state.profile.bookedEvents.contains(event.id)
        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                IconBubble(systemName: event.icon, size: 44)
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Pill(text: event.theme)
                        if event.spotsLeft <= 5 { Pill(text: "\(event.spotsLeft) spots left", tint: Color(hex: 0xFDBA74)) }
                    }
                    Text(event.title)
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text("\(event.venue) · \(event.city)")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                }
            }
            HStack(spacing: 16) {
                Label(event.date, systemImage: "calendar")
                Label(event.time, systemImage: "clock")
                Spacer()
                Text(event.price == 0 ? "Included" : "\(Config.currency)\(event.price)")
                    .foregroundStyle(Theme.gold)
            }
            .font(.system(size: 12, weight: .light))
            .foregroundStyle(Theme.textMuted)

            if booked {
                Label("You're going", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Theme.gold)
            } else {
                Button("Reserve my spot") { eventToBook = event }
                    .buttonStyle(GoldButtonStyle())
            }
        }
        .miaCard()
    }

    // MARK: Recordings

    private func recordingCard(_ recording: Recording) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                IconBubble(systemName: "play.fill", size: 44)
                VStack(alignment: .leading, spacing: 6) {
                    Text(recording.title)
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text("with \(recording.host) · \(recording.date)")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                    Label(recording.duration, systemImage: "clock")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Theme.textMuted)
                }
            }
            Button {
                playing = recording
            } label: {
                Label("Watch when ready", systemImage: "play")
            }
            .buttonStyle(SoftButtonStyle())
        }
        .miaCard()
    }
}

struct RecordingPlayerView: View {
    let recording: Recording
    @State private var player = AVPlayer(url: MockData.sampleVideoURL)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VideoPlayer(player: player)
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            Text(recording.title)
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(Theme.text)
            Text("with \(recording.host) · \(recording.duration)")
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Theme.textSoft)
            Spacer()
        }
        .padding(24)
        .miaBackground()
        .onAppear { player.play() }
        .onDisappear { player.pause() }
    }
}

struct EventBookingSheet: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    let event: MemberEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(event.title)
                .font(.system(size: 24, weight: .light))
                .foregroundStyle(Theme.text)
            VStack(alignment: .leading, spacing: 8) {
                Label("\(event.venue), \(event.city)", systemImage: "mappin.and.ellipse")
                Label("\(event.date) at \(event.time)", systemImage: "calendar")
                Label(event.price == 0 ? "Included in your membership" : "\(Config.currency)\(event.price) per person", systemImage: "creditcard")
            }
            .font(.system(size: 15, weight: .light))
            .foregroundStyle(Theme.textSoft)
            Spacer()
            Button(event.price == 0 ? "Confirm my spot" : "Pay \(Config.currency)\(event.price) & confirm") {
                state.profile.bookedEvents.insert(event.id)
                dismiss()
            }
            .buttonStyle(GoldButtonStyle())
            Text("Payments are simulated in this preview.")
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Theme.textMuted)
                .frame(maxWidth: .infinity)
        }
        .padding(24)
        .padding(.top, 8)
        .miaBackground()
    }
}
