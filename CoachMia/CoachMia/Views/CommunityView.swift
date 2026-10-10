import SwiftUI

struct CommunityView: View {
    @EnvironmentObject var state: AppState

    private var joined: [CommunityGroup] { MockData.groups.filter { state.profile.joinedGroups.contains($0.id) } }
    private var others: [CommunityGroup] { MockData.groups.filter { !state.profile.joinedGroups.contains($0.id) } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ScreenHeader(title: "Community", subtitle: "You're not alone on this path")

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your community")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(Theme.textMuted)
                        HStack(alignment: .top, spacing: 32) {
                            stat("\(joined.count)", "groups you're part of")
                            stat("8.2K", "men walking similar paths")
                        }
                        Label("Moderated by the Coach Mia team to keep it respectful", systemImage: "checkmark.shield")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(Theme.textMuted)
                    }
                    .miaCard()

                    if !joined.isEmpty {
                        SectionLabel("Your groups").padding(.top, 8)
                        ForEach(joined) { group in
                            NavigationLink(value: group.id) {
                                groupCard(group, joined: true)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if !others.isEmpty {
                        SectionLabel("More groups").padding(.top, 8)
                        ForEach(others) { group in
                            groupCard(group, joined: false)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .miaBackground()
            .navigationDestination(for: Int.self) { id in
                if let group = MockData.groups.first(where: { $0.id == id }) {
                    GroupDetailView(group: group)
                }
            }
        }
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 30, weight: .light))
                .foregroundStyle(Theme.gold)
            Text(label)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Theme.textSoft)
        }
    }

    private func groupCard(_ group: CommunityGroup, joined: Bool) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                IconBubble(systemName: group.icon, size: 42)
                VStack(alignment: .leading, spacing: 6) {
                    Text(group.name)
                        .font(.system(size: 18, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text(group.description)
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                    Label("\(group.members.formatted()) members", systemImage: "person.2")
                        .font(.system(size: 12, weight: .light))
                        .foregroundStyle(Theme.textMuted)
                }
            }
            if joined {
                HStack {
                    Text("Enter group")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 14, weight: .light))
                .foregroundStyle(Theme.gold)
            } else {
                Button("Join if you wish") {
                    withAnimation { _ = state.profile.joinedGroups.insert(group.id) }
                }
                .buttonStyle(SoftButtonStyle())
            }
        }
        .miaCard(padding: 24)
    }
}

struct GroupDetailView: View {
    @EnvironmentObject var state: AppState
    let group: CommunityGroup

    @State private var draft = ""
    @State private var anonymous = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.name)
                        .font(.system(size: 28, weight: .light))
                        .foregroundStyle(Theme.text)
                    Text(group.description)
                        .font(.system(size: 15, weight: .light))
                        .foregroundStyle(Theme.textMuted)
                }

                composer

                ForEach(state.posts(for: group)) { post in
                    postCard(post)
                }

                Button("Leave group") {
                    state.profile.joinedGroups.remove(group.id)
                }
                .font(.system(size: 13, weight: .light))
                .foregroundStyle(Theme.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .miaBackground()
        .navigationBarTitleDisplayMode(.inline)
    }

    private var composer: some View {
        VStack(alignment: .leading, spacing: 12) {
            TextField("", text: $draft, prompt: Text("Share a win, a question, or how you're feeling...").foregroundColor(Theme.textMuted), axis: .vertical)
                .lineLimit(2...6)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Theme.text)
            HStack {
                Toggle(isOn: $anonymous) {
                    Text("Post anonymously")
                        .font(.system(size: 13, weight: .light))
                        .foregroundStyle(Theme.textSoft)
                }
                .toggleStyle(.switch)
                .tint(Theme.gold)
                .fixedSize()
                Spacer()
                Button("Post") {
                    state.addPost(draft.trimmingCharacters(in: .whitespacesAndNewlines), to: group, anonymous: anonymous)
                    draft = ""
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.bgTop)
                .padding(.horizontal, 20)
                .padding(.vertical, 9)
                .background(Theme.goldFill, in: Capsule())
                .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
            }
        }
        .miaCard(padding: 20)
    }

    private func postCard(_ post: Post) -> some View {
        let liked = state.profile.likedPosts.contains(post.id)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(String(post.author.prefix(1)))
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Theme.gold)
                    .frame(width: 32, height: 32)
                    .background(Theme.gold.opacity(0.1), in: Circle())
                Text(post.author)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Theme.text)
                Spacer()
                Text(post.timeAgo)
                    .font(.system(size: 12, weight: .light))
                    .foregroundStyle(Theme.textMuted)
            }
            Text(post.text)
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(Theme.text)
                .lineSpacing(3)
            HStack(spacing: 20) {
                Button {
                    state.toggleLike(post)
                } label: {
                    Label("\(post.likes + (liked ? 1 : 0))", systemImage: liked ? "heart.fill" : "heart")
                        .foregroundStyle(liked ? Theme.gold : Theme.textMuted)
                }
                Label("Reply", systemImage: "bubble.left")
                    .foregroundStyle(Theme.textMuted)
                Spacer()
                Menu {
                    Button("Report to moderators", systemImage: "flag") {}
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Theme.textMuted)
                        .frame(width: 30, height: 24)
                }
            }
            .font(.system(size: 13, weight: .light))
        }
        .miaCard(padding: 20)
    }
}
