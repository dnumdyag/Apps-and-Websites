import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var state: AppState

    private var joined: [CommunityGroup] { MockData.groups.filter { state.profile.joinedGroups.contains($0.id) } }
    private var others: [CommunityGroup] { MockData.groups.filter { !state.profile.joinedGroups.contains($0.id) } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    ScreenHeader(title: "You're ", accent: "not alone", subtitle: "Men walking the same path as you")

                    VStack(alignment: .leading, spacing: 14) {
                        Text("YOUR COMMUNITY")
                            .font(Theme.sans(11, .semibold))
                            .tracking(2)
                            .foregroundStyle(Theme.goldOnGreen)
                        HStack(alignment: .top, spacing: 16) {
                            stat("\(joined.count)", "groups you're part of")
                            stat("8.2K", "men walking similar paths")
                        }
                        Label("Moderated by the Coach Mia team", systemImage: "checkmark.shield")
                            .font(Theme.sans(12, .medium))
                            .foregroundStyle(Theme.onGreenMuted)
                    }
                    .greenCard()

                    if !joined.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionLabel("Your groups")
                            ForEach(joined) { group in
                                NavigationLink(value: group.id) {
                                    joinedCard(group)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if !others.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionLabel("More groups")
                            VStack(spacing: 0) {
                                ForEach(others) { group in
                                    otherRow(group)
                                    if group.id != others.last?.id {
                                        Rectangle().fill(Theme.divider).frame(height: 1)
                                    }
                                }
                            }
                            .padding(.horizontal, 18)
                            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .screenBackground()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Int.self) { id in
                if let group = MockData.groups.first(where: { $0.id == id }) {
                    GroupDetailView(group: group)
                }
            }
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(Theme.serif(46, .semibold))
            Text(label)
                .font(Theme.sans(13.5))
                .foregroundStyle(Theme.onGreenMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func joinedCard(_ group: CommunityGroup) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: group.icon)
                    .font(.system(size: 19))
                    .foregroundStyle(Theme.goldOnGreen)
                    .frame(width: 48, height: 48)
                    .background(Theme.green, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name)
                        .font(Theme.serif(20, .semibold))
                        .foregroundStyle(Theme.ink)
                    Text("\(group.members.formatted()) members")
                        .font(Theme.sans(12, .semibold))
                        .foregroundStyle(Theme.goldText)
                }
                Spacer(minLength: 0)
                OutlineArrow(size: 40)
            }
            Text(group.description)
                .font(Theme.sans(13.5))
                .foregroundStyle(Theme.muted)
        }
        .whiteCard(padding: 18)
    }

    private func otherRow(_ group: CommunityGroup) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name)
                    .font(Theme.serif(20, .semibold))
                    .foregroundStyle(Theme.ink)
                Text(group.description)
                    .font(Theme.sans(12.5))
                    .foregroundStyle(Theme.muted)
                Text("\(group.members.formatted()) members")
                    .font(Theme.sans(12, .semibold))
                    .foregroundStyle(Theme.goldText)
            }
            Spacer(minLength: 0)
            Button("Join") {
                withAnimation { _ = state.profile.joinedGroups.insert(group.id) }
            }
            .buttonStyle(OutlineButtonStyle())
        }
        .padding(.vertical, 16)
    }
}

struct GroupDetailView: View {
    @EnvironmentObject var state: AppState
    @Environment(\.dismiss) private var dismiss
    let group: CommunityGroup

    @State private var draft = ""
    @State private var anonymous = false
    @State private var reported = false

    private var trimmedDraft: String { draft.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(group.members.formatted()) MEMBERS")
                        .font(Theme.sans(11, .semibold))
                        .tracking(2)
                        .foregroundStyle(Theme.goldText)
                    Text(group.name)
                        .font(Theme.serif(36, .medium))
                        .foregroundStyle(Theme.ink)
                    Text(group.description)
                        .font(Theme.sans(15))
                        .foregroundStyle(Theme.muted)
                }
                .padding(.bottom, 8)

                composer

                ForEach(state.posts(for: group)) { post in
                    postCard(post)
                }

                Button("Leave group") {
                    _ = state.profile.joinedGroups.remove(group.id)
                    dismiss()
                }
                .font(Theme.sans(13, .medium))
                .foregroundStyle(Theme.muted)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.top, 8)
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .alert("Thanks for flagging this", isPresented: $reported) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("A moderator will review the post.")
        }
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("", text: $draft, prompt: Text("Share a win, a question, or how you're feeling...").foregroundColor(Theme.faint), axis: .vertical)
                .lineLimit(2...6)
                .font(Theme.sans(15))
                .foregroundStyle(Theme.ink)
            HStack {
                Toggle(isOn: $anonymous) {
                    Text("Post anonymously")
                        .font(Theme.sans(13, .medium))
                        .foregroundStyle(Theme.muted)
                }
                .toggleStyle(.switch)
                .tint(Theme.green)
                .fixedSize()
                Spacer()
                Button("Post") {
                    state.addPost(trimmedDraft, to: group, anonymous: anonymous)
                    draft = ""
                }
                .buttonStyle(GoldButtonStyle(height: 40, fontSize: 14))
                .frame(width: 90)
                .disabled(trimmedDraft.isEmpty)
                .opacity(trimmedDraft.isEmpty ? 0.5 : 1)
            }
        }
        .whiteCard(padding: 18)
    }

    private func postCard(_ post: Post) -> some View {
        let liked = state.profile.likedPosts.contains(post.id)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(String(post.author.prefix(1)))
                    .font(Theme.serif(17, .semibold))
                    .foregroundStyle(Theme.goldOnGreen)
                    .frame(width: 34, height: 34)
                    .background(Theme.green, in: Circle())
                Text(post.author)
                    .font(Theme.sans(14, .semibold))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Text(post.timeAgo)
                    .font(Theme.sans(12))
                    .foregroundStyle(Theme.muted)
            }
            Text(post.text)
                .font(Theme.sans(14.5))
                .foregroundStyle(Theme.ink)
                .lineSpacing(3)
            HStack(spacing: 20) {
                Button {
                    state.toggleLike(post)
                } label: {
                    Label("\(post.likes + (liked ? 1 : 0))", systemImage: liked ? "heart.fill" : "heart")
                        .foregroundStyle(liked ? Theme.red : Theme.muted)
                }
                Label("Reply", systemImage: "bubble.left")
                    .foregroundStyle(Theme.muted)
                Spacer()
                Menu {
                    Button("Report to moderators", systemImage: "flag") { reported = true }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Theme.muted)
                        .frame(width: 32, height: 28)
                }
            }
            .font(Theme.sans(13, .medium))
        }
        .whiteCard(padding: 18)
    }
}
