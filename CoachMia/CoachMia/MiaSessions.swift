import Foundation

/// Guided sessions on the Mia page: the member picks one, Mia asks three quick questions with
/// tappable answers, then gives a short personal plan built from those answers. The plans and the
/// follow-up replies are written here, so a session works fully without an API key.
struct MiaSession: Identifiable {
    struct Question {
        let text: String
        let options: [String]
        /// An extra answer that opens the photo picker (a chat or profile screenshot).
        var photoOption: String? = nil
    }

    struct FollowUp {
        let label: String
        /// The reply used when no API key is set. "{name}" becomes the member's first name.
        let reply: String
    }

    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let opener: String
    let questions: [Question]
    let followUps: [FollowUp]
    let plan: ([String]) -> SessionPlan
}

struct SessionPlan: Equatable {
    let label: String
    let title: String
    let steps: [String]
    var note: String? = nil

    /// The plan as plain text, so Mia's AI sees it in the conversation history.
    var asText: String {
        var lines = ["\(label.capitalized): \(title)"]
        lines += steps.enumerated().map { "\($0.offset + 1). \($0.element)" }
        if let note { lines.append(note) }
        return lines.joined(separator: "\n")
    }
}

enum MiaSessions {
    static let skipPhoto = "Skip for now"

    static func followUpReply(for text: String, name: String) -> String? {
        all.lazy.flatMap(\.followUps).first { $0.label == text }?.reply.replacingOccurrences(of: "{name}", with: name)
    }

    static let all: [MiaSession] = [beforeADate, helpMeReply, afterADate, profileReview, confidence, approach]

    // MARK: Before a date

    static let beforeADate = MiaSession(
        id: "before",
        title: "Before a date",
        subtitle: "Calm the nerves, plan the night",
        icon: "wineglass",
        opener: "Lovely. Let's get you ready.",
        questions: [
            .init(text: "When is the date?", options: ["Tonight", "Tomorrow", "This weekend", "Next week"]),
            .init(text: "Where are you taking her?", options: ["Drinks", "Dinner", "Coffee", "Something active", "Not decided yet"]),
            .init(text: "And honestly, how are you feeling about it?", options: ["Excited", "A little nervous", "Very nervous", "Overthinking it"]),
        ],
        followUps: [
            .init(label: "Give me three good questions", reply: """
                Here are three that open people up:

                1. "What's something you're looking forward to this month?"
                2. "What did you want to be when you were ten?"
                3. "What's the best trip you've ever taken, and who were you with?"

                Listen for the part she lights up about, then ask one more question about that. Which one feels most like you?
                """),
            .init(label: "What if there's a silence?", reply: "A short silence is normal, and it isn't your job alone to fill it. Smile, take a sip, then go back to something she mentioned earlier: \"You said you'd just been to Lisbon. What surprised you there?\" Coming back to her words shows you were listening. Want a couple more of those in your pocket?"),
            .init(label: "How do I end the night well?", reply: "End while it's still good. If you'd like to see her again, say so simply: \"I've really enjoyed tonight. I'd like to do this again.\" Make sure she gets home safely, then send a short message the next day. Would you like help with that message?"),
        ],
        plan: { a in
            let place = [
                "Drinks": "Sit at the bar or side by side if you can. It feels warmer than facing each other across a table.",
                "Dinner": "Choose a place you already know, so you can relax and recommend a dish.",
                "Coffee": "Keep it to about an hour. If it's going well, suggest a short walk.",
                "Something active": "Pick something you can talk during. Laughing at yourselves does half the work.",
            ][a[1]] ?? "Book one place with a second spot nearby, so the night can move on if it's going well."
            let feeling = [
                "Excited": "Let her finish her stories. Ask one more question than feels natural before you share yours.",
                "A little nervous": "Arrive ten minutes early and take three slow breaths outside. A few nerves read as sincere, not weak.",
                "Very nervous": "The only goal is a nice hour with a new person. Arrive early, and breathe out for longer than you breathe in.",
            ][a[2]] ?? "Write down three things you're curious about her, then put the list away. You're prepared, so you can be present."
            let timing = [
                "Tonight": "An hour before, send something short and warm: \"Looking forward to tonight.\"",
                "Tomorrow": "Confirm the time and place today, then switch off. No long chats before you meet.",
                "This weekend": "Confirm the day before. Keep texting light until then and save your best stories for the date.",
            ][a[0]] ?? "Check in once midweek so the plan stays alive, then confirm the day before."
            let title = [
                "Excited": "Bring the energy, then listen",
                "A little nervous": "Nerves mean you care",
                "Very nervous": "Slow down, you've got this",
            ][a[2]] ?? "Plan once, then let it go"
            return SessionPlan(label: "YOUR DATE PLAN", title: title, steps: [place, feeling, timing])
        }
    )

    // MARK: Help me reply

    static let helpMeReply = MiaSession(
        id: "reply",
        title: "Help me reply",
        subtitle: "Share a chat, get your next message",
        icon: "text.bubble",
        opener: "Of course. Let's find your next message together.",
        questions: [
            .init(text: "Where are you talking?", options: ["Hinge", "Tinder", "Bumble", "WhatsApp", "Instagram"]),
            .init(text: "How is the chat going?", options: ["We just matched", "It's flowing nicely", "It's gone quiet", "She asked me something"]),
            .init(text: "If you like, share a screenshot so I can see the details.", options: [skipPhoto], photoOption: "Add a screenshot"),
        ],
        followUps: [
            .init(label: "Make it more playful", reply: "Let's add a little play. Tease gently about something light, never about her looks: \"Bold of you to claim the best tacos in town. I'm going to need proof.\" Playful with a hint of a plan is the sweet spot. Want me to try another version?"),
            .init(label: "Make it shorter", reply: "Shorter is often stronger. Cut it to one line with one question: \"Drink on Thursday? I know a good spot.\" Confident, clear and easy to answer. Shall I give you two more options?"),
            .init(label: "What if she doesn't reply?", reply: "Then she's told you what you need to know, and that's okay. Send one light follow up after a few days at most, then let it go. Your energy is better spent on people who are excited to talk to you. How many chats are you keeping going right now?"),
        ],
        plan: { a in
            let platform = [
                "Hinge": "On Hinge, comment on one of her prompts. A comment beats a plain like.",
                "Tinder": "On Tinder, keep the first message short and specific. One line is enough.",
                "Bumble": "On Bumble she writes first. Reply within a day and match her energy.",
                "WhatsApp": "On WhatsApp, keep messages short and save the long stories for when you meet.",
            ][a[0]] ?? "On Instagram, reply to a story rather than an old post. It feels natural, not like digging."
            switch a[1] {
            case "We just matched":
                return SessionPlan(label: "YOUR NEXT MESSAGE", title: "Open with something only she'd get",
                                   steps: ["Skip \"hey\". Pick one detail from her profile and ask about it.",
                                           "Try: \"Okay, I need the story behind the photo at the market.\"",
                                           "Keep it to one or two lines. Easy to answer beats impressive."],
                                   note: platform)
            case "It's flowing nicely":
                return SessionPlan(label: "YOUR NEXT MESSAGE", title: "Time to make a plan",
                                   steps: ["You've built enough rapport. Move it toward meeting.",
                                           "Try: \"I'm enjoying this. Let's carry it on over a drink. Are you free Thursday?\"",
                                           "A clear day and place is much easier to say yes to than \"we should meet sometime\"."],
                                   note: platform)
            case "It's gone quiet":
                return SessionPlan(label: "YOUR NEXT MESSAGE", title: "One light line, then let it breathe",
                                   steps: ["Don't chase with a paragraph or a lone question mark.",
                                           "Try: \"I'm guessing a very busy week has kidnapped you. Hope it's a good one.\"",
                                           "If there's still no reply, let it go gracefully. The right person won't make you chase."],
                                   note: platform)
            default:
                return SessionPlan(label: "YOUR NEXT MESSAGE", title: "Answer, add, ask back",
                                   steps: ["Answer her properly, not with one word.",
                                           "Add one small detail about you, then ask one question back.",
                                           "Keep it roughly the same length as her message."],
                                   note: platform)
            }
        }
    )

    // MARK: After a date

    static let afterADate = MiaSession(
        id: "after",
        title: "After a date",
        subtitle: "Talk it through, decide what's next",
        icon: "moon.stars",
        opener: "I'd love to hear how it went.",
        questions: [
            .init(text: "How did it go?", options: ["Really well", "Good", "I'm not sure", "Not great"]),
            .init(text: "What stood out?", options: ["We laughed a lot", "A real conversation", "Some awkward silences", "We kissed"]),
            .init(text: "Would you like to see her again?", options: ["Yes, definitely", "Maybe", "I don't think so"]),
        ],
        followUps: [
            .init(label: "Write my follow up message", reply: "Here's a warm, simple one: \"I had a really good time last night. Still laughing about the waiter. Can I take you out for round two on Saturday?\" Swap the waiter for your own moment. A specific detail shows you were present. Want a more playful version?"),
            .init(label: "How soon should I text her?", reply: "The next day is perfect. The same night is fine too, if it's a short \"Home safe? I had a great time.\" There's no need for games or waiting three days. Clear interest is attractive. Would you like help with the wording?"),
            .init(label: "What if she doesn't feel the same?", reply: "Then you'll have your answer, and you'll handle it with grace. Thank her, wish her well, and move on with your head high. It says nothing about your worth, {name}. How are you feeling about it right now?"),
        ],
        plan: { a in
            let moment = [
                "We laughed a lot": "Shared laughter is one of the strongest signs of chemistry. Bring the same lightness to your messages.",
                "A real conversation": "A real conversation on a first date is rare. Follow the thread you started together.",
                "Some awkward silences": "Silences happen, especially early on. Next time, keep two or three open questions in your pocket.",
            ][a[1]] ?? "Lovely. Keep the follow up warm and simple, there's no need to overthink it."
            let note = [
                "Not great": "Not every date clicks, and that isn't a verdict on you. You showed up, which is the hard part.",
                "I'm not sure": "Not being sure after one date is normal. Notice how you feel in a day or two.",
            ][a[0]]
            switch a[2] {
            case "Yes, definitely":
                return SessionPlan(label: "WHAT'S NEXT", title: "Follow up, warmly and soon",
                                   steps: ["Message her tomorrow, not at 2am tonight. Name a moment you enjoyed.",
                                           moment,
                                           "Try: \"Still smiling about last night. Round two on Saturday?\""],
                                   note: note)
            case "Maybe":
                return SessionPlan(label: "WHAT'S NEXT", title: "Give the spark a second chance",
                                   steps: ["First dates are often nervous ones. If there was any spark, a second date is a fair test.",
                                           moment,
                                           "Suggest something different and low key, like coffee and a walk, and see how you feel."],
                                   note: note)
            default:
                return SessionPlan(label: "WHAT'S NEXT", title: "A kind, clear goodbye",
                                   steps: ["Tell her kindly rather than going quiet.",
                                           "Try: \"I really enjoyed meeting you, but I didn't feel the spark I'm looking for. Wishing you the best.\"",
                                           "Note one thing you learned about what you want. Every date makes the next one clearer."],
                                   note: note)
            }
        }
    )

    // MARK: Profile review

    static let profileReview = MiaSession(
        id: "profile",
        title: "Review my profile",
        subtitle: "Photos, bio and prompts",
        icon: "person.crop.square",
        opener: "Good idea. Small changes here make a big difference.",
        questions: [
            .init(text: "Which app are you on?", options: ["Hinge", "Tinder", "Bumble", "Raya", "More than one"]),
            .init(text: "How many matches do you get in a week?", options: ["None", "1 to 3", "4 to 10", "More than 10"]),
            .init(text: "Share screenshots of your profile, or skip and I'll give you my top fixes.", options: [skipPhoto], photoOption: "Add screenshots"),
        ],
        followUps: [
            .init(label: "Help me write a better bio", reply: "Let's make it easy to start a conversation. Try this shape: one true detail, one thing you love, one light invitation. For example: \"Weekend cook, early morning runner, terrible at karaoke but committed. Tell me your go to song.\" Want me to write one around your interests?"),
            .init(label: "Which photos work best?", reply: "In this order: a clear, smiling photo, shoulders up, in natural light. Then a full length photo, one doing something you love, and one with friends where you're easy to spot. Skip the car selfies, the gym mirror and the sunglasses. Want to share yours for a closer look?"),
            .init(label: "Give me three better prompts", reply: """
                Try these:

                1. "The way to win me over is..." good coffee and a terrible pun.
                2. "I'm looking for..." someone who'll argue with me about the best pizza in town.
                3. "A perfect Sunday..." a long breakfast, a walk, and a film we disagree about.

                Each one gives her an easy reply. Which feels most like you?
                """),
        ],
        plan: { a in
            let note = [
                "Hinge": "On Hinge, your prompts matter as much as your photos.",
                "Tinder": "On Tinder, your first photo does almost all the work.",
                "Bumble": "On Bumble, a clear bio gives her an easy way to start.",
                "Raya": "On Raya, a short, warm intro beats a list of achievements.",
            ][a[0]] ?? "Put your strongest photo first on every app, and tailor the words to each one."
            switch a[1] {
            case "4 to 10":
                return SessionPlan(label: "YOUR PROFILE FIXES", title: "Good start, now sharpen it",
                                   steps: ["Keep your strongest photo first, and remove any group photo where you're hard to find.",
                                           "Add one prompt that shows your humour or a strong opinion. Easy to reply to beats impressive.",
                                           "Reply within a day of matching. Momentum matters more than the perfect line."],
                                   note: note)
            case "More than 10":
                return SessionPlan(label: "YOUR PROFILE FIXES", title: "It's working, now turn matches into dates",
                                   steps: ["Your profile is doing its job. The work now is in the chat.",
                                           "Move good conversations toward a plan within ten or so messages.",
                                           "Be choosy. Put your energy into the chats that feel easy and mutual."],
                                   note: note)
            default:
                return SessionPlan(label: "YOUR PROFILE FIXES", title: "Lead with your best photo",
                                   steps: ["Make your first photo clear and warm: shoulders up, daylight, smiling, no sunglasses.",
                                           "Add one photo that shows your life, like a hobby, travel or friends where you're easy to spot.",
                                           "Rewrite one prompt so it's easy to reply to. Swap \"I love travel\" for \"Best meal of my life was in a tiny place in Naples. Your turn.\""],
                                   note: note)
            }
        }
    )

    // MARK: Confidence

    static let confidence = MiaSession(
        id: "confidence",
        title: "Build confidence",
        subtitle: "One small brave step today",
        icon: "flame",
        opener: "I love that you're working on this.",
        questions: [
            .init(text: "Where do you feel least confident?", options: ["Starting conversations", "On dates", "How I look", "Being myself"]),
            .init(text: "How do you feel right now?", options: ["Low", "Unsure", "Okay", "Good", "Strong"]),
            .init(text: "How much time do you have today?", options: ["Five minutes", "An hour", "All day"]),
        ],
        followUps: [
            .init(label: "Why does this work?", reply: "Confidence isn't a feeling you wait for, it's evidence you collect. Every small promise you keep tells your mind you can be trusted. Do that often enough and it starts to feel natural. What's one promise you can keep before tonight?"),
            .init(label: "Give me a bigger challenge", reply: "Love it. This week, invite someone you're interested in for a coffee, in person or by message, with a specific day. The outcome doesn't matter. The asking does. How does that feel to read?"),
            .init(label: "I'm still nervous", reply: "That's completely normal, and it isn't a sign to stop. Nerves and excitement feel almost the same in the body. Try saying \"I'm excited\" instead of \"I'm nervous\" and notice what changes. Want to make the step even smaller?"),
        ],
        plan: { a in
            let size = ["Five minutes": 0, "An hour": 1][a[2]] ?? 2
            let steps: [String: [String]] = [
                "Starting conversations": ["Say a warm hello to one stranger today. The barista counts.",
                                           "Start three small conversations today. Comment on something you can both see.",
                                           "Start five small conversations today, and notice that nothing bad happens."],
                "On dates": ["Write down three questions you're genuinely curious to ask someone.",
                             "Ask a friend one deeper question today, and really listen to the answer.",
                             "Plan a date you'd enjoy yourself, then invite someone to it."],
                "How I look": ["Stand tall, shoulders back, and take three slow breaths before you leave the house.",
                               "Do one thing that makes you feel sharp: a haircut, a workout or a clean outfit.",
                               "Move your body, eat well, and wear the outfit you feel best in."],
                "Being myself": ["Share one honest opinion today, kindly.",
                                 "Tell a friend one thing you've been holding back.",
                                 "Spend part of the day on something you love, without needing anyone's approval."],
            ]
            let step = (steps[a[0]] ?? steps["Being myself"]!)[size]
            let mood = [
                "Low": "Be gentle with yourself. Today the win is simply showing up.",
                "Unsure": "You don't need to feel ready to take a small step. Action comes first, confidence follows.",
                "Okay": "Okay is a good place to build from. Keep the step small and finish it.",
                "Good": "Use the good energy. Do it early, before the day gets busy.",
            ][a[1]] ?? "Stretch a little further than usual today. You've got momentum."
            let title = [
                "Starting conversations": "Say hello, with no goal",
                "On dates": "Be curious, not impressive",
                "How I look": "Show up for yourself first",
            ][a[0]] ?? "Say one true thing"
            return SessionPlan(label: "TODAY'S BRAVE STEP", title: title,
                               steps: [step, mood, "Tonight, write down what you did and how it felt. Confidence is built from kept promises."])
        }
    )

    // MARK: Approach

    static let approach = MiaSession(
        id: "approach",
        title: "Approach someone",
        subtitle: "A gentle plan to say hello",
        icon: "figure.walk",
        opener: "Let's make this feel a lot less scary.",
        questions: [
            .init(text: "Where might you meet someone?", options: ["A café", "The gym", "A bar", "Work or events", "Out walking"]),
            .init(text: "What usually stops you?", options: ["Fear of rejection", "Not knowing what to say", "The timing", "People watching"]),
            .init(text: "How big a step feels right today?", options: ["Small", "Medium", "Big"]),
        ],
        followUps: [
            .init(label: "What if she isn't interested?", reply: "Then you smile, say \"Enjoy your day\", and walk away with your head high. That's a success: you were brave and respectful. Her answer is about her day, her mood and her life, not your worth. Ready to try once this week?"),
            .init(label: "Give me three openers", reply: """
                Keep them simple and real:

                1. "I have to ask, what are you reading?"
                2. "Settle a debate for me. Is this place better for coffee or cake?"
                3. "Hi, I noticed you and wanted to say hello. I'm {name}."

                The third one works more often than you'd think. Honesty is disarming. Which feels most like you?
                """),
            .init(label: "How do I ask for her number?", reply: "If it's going well, keep it simple and clear: \"I've enjoyed talking to you. Can I take your number and take you for a coffee?\" Ask once, and accept her answer graciously either way. Confidence is in the clarity, not the line. Want to practise it with me?"),
        ],
        plan: { a in
            let place = [
                "A café": "In a café, comment on what she's reading or ordering: \"Is that any good? I always order the same thing.\"",
                "The gym": "At the gym, wait until she's between sets with her headphones off. Keep it short and respectful.",
                "A bar": "In a bar, make eye contact and smile first. If she smiles back, go and say hello.",
                "Work or events": "At an event, ask how she knows the host. It's the easiest opener there is.",
            ][a[0]] ?? "Out walking, a dog, a view or a shared moment is all you need: \"Is it always this busy here?\""
            let blocker = [
                "Fear of rejection": "Make your only goal a nice thirty second chat. Then a no isn't rejection, it's just a short conversation.",
                "Not knowing what to say": "You don't need a line. An honest observation and a question is enough.",
                "The timing": "Waiting for the perfect moment is the trap. Within three seconds of noticing her, say hello.",
            ][a[1]] ?? "Most people are busy with their own day. Keep your voice warm and normal, and it looks like any other conversation."
            let step = [
                "Small": "Today's step: smile and make eye contact with three people. That's all.",
                "Medium": "Today's step: say hello to one person you find interesting, with no goal.",
            ][a[2]] ?? "Today's step: start a conversation and, if it's going well, ask for her number."
            let title = [
                "Fear of rejection": "Connection, not outcome",
                "Not knowing what to say": "Start with what's around you",
                "The timing": "There's no perfect moment",
            ][a[1]] ?? "Nobody is watching as closely as you think"
            return SessionPlan(label: "YOUR APPROACH PLAN", title: title, steps: [place, blocker, step],
                               note: "Read the signals. If she seems busy or uninterested, smile, wish her a good day and move on.")
        }
    )
}
