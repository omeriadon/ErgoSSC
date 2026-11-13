# Lesson 2: Fair point?

What the lesson teaches: three ways an everyday argument goes wrong. A reply can twist what you said (**straw man**), make it about you instead of the point (**ad hominem**), or act like there are only two choices (**false dilemma**). Some replies are fair, and the lesson always shows one.

The tone is kind. Sam and Leo aren't villains: they're frustrated, and each of them makes a fair point by the end. The lesson never says anyone is lying or hiding something.

The Freeform mockup is the layout reference (`/Users/omeriadon/.t3/userdata/attachments/4d056eea-7079-4472-8229-fb7ae0847eeb-ff9ebc3a-0f7e-42f3-a323-98d220da1c33-pdf.pdf`). Where this doc and the mockup disagree, this doc wins: it has the fixes made after the mockup.

## The theme

A messaging app, like Messages: grey bubbles on the left for the other person, blue on the right for "You", and consecutive messages from the same person grouped the way Messages groups them. It's all drawn in SwiftUI. Nothing is real or sent.

## Page 1: Fair point?

Title: `Lesson 2: Fair point?`

1. An inbox: a list of conversations that scrolls by on its own, slows and lands on **Sam**, and opens that conversation. Keep it to about two seconds. Judges feel every wait. Other rows in the inbox, as filler: Mum ("dinner's at 7, don't be late"), Jess ("lol did you see that"), Football group ("training moved to thursday"), Leo ("where's the charger"), Dentist ("Reminder: your appointment is on…").
2. Sam's conversation (below), shown in full.
3. Under it: "Common scenario: messaging a friend. Arguments can get messy, so let's look at how this one goes →". The arrow is the button to page 2.

### Sam's conversation

| From | Message |
|---|---|
| Sam | are you coming friday?? 🎸 |
| You | can't, exam on monday 😩 |
| Sam | so uni matters more than your friends now? |
| You | no, I just need to study |
| Sam | you've been so boring lately honestly |
| Sam | either you come or you've just given up on having fun |
| Sam | ok sorry. what if you study all weekend and just come for the first hour? |

## Page 2: Deeper look

Title: `Lesson 2: Deeper look`

"Tap each of Sam's messages to take a deeper look ↓"

The same conversation. Each of Sam's messages can be tapped, and a tap shows a popover pointing at the bubble. On iPhone this needs `.presentationCompactAdaptation(.popover)`, or it becomes a sheet.

| Sam's message | Popover |
|---|---|
| are you coming friday?? 🎸 | Just a question. Nothing to check here. |
| so uni matters more than your friends now? | You said you have an exam, not that uni matters more. Sam's answering something you didn't say. That's called a **straw man**. |
| you've been so boring lately honestly | This is about you, not about the exam. That's called **ad hominem**. |
| either you come or you've just given up on having fun | There are more than two options, like coming for a bit. That's a **false dilemma**. |
| ok sorry. what if you study all weekend and just come for the first hour? | This one's fair. Sam's answering your actual reason, and finding a way to do both. |

- A tapped bubble gets a subtle mark so the person can see which ones they've looked at. Nothing is scored.
- Under the conversation: "N more to go ↑" counts the untapped messages ("1 more to go ↑" for one). Once all five have been tapped, it becomes a Continue button to page 3.

## Page 3: Your turn!

Title: `Lesson 2: Your turn!`

"Here's another convo you might have. Now scribble over any message that doesn't seem fair."

### Leo's conversation

Leo is a sibling.

| From | Message | Is |
|---|---|---|
| You | can you walk Biscuit tonight? I've got a shift | (yours, not markable) |
| Leo | so I have to do everything in this house now? | Straw man |
| Leo | I walked him yesterday and the day before | **Fair** |
| Leo | either you walk him or he doesn't get walked | False dilemma |
| Leo | says the person who forgot to feed him last week | Ad hominem |

### Scribbling

- The person draws with a finger over the conversation. The stroke is drawn as it goes, like a highlighter or pen.
- When a stroke ends, every one of Leo's bubbles it crossed counts as scribbled. Matching is by bubble frame, not by words, so a messy scribble still works. Use a drag gesture's points hit-tested against each bubble's frame in a shared coordinate space. No PencilKit.
- As soon as a bubble is scribbled, its popover shows (same popover style as page 2) and the bubble gets marked: caught for an unfair one, a gentle "fair" look for the fair one. The ink stroke can then fade.
- Scribbling the fair message isn't a failure. Its popover just explains it.
- Once all three unfair messages are found, a Continue button appears to the summary. There's no score.

| Leo's message | Popover |
|---|---|
| so I have to do everything in this house now? | You asked about tonight, not everything. That's a **straw man**. |
| I walked him yesterday and the day before | This one's fair. Leo has a point: they did walk him twice. |
| either you walk him or he doesn't get walked | Someone else could, or he could go later. That's a **false dilemma**. |
| says the person who forgot to feed him last week | That's about you, not about tonight. That's **ad hominem**. |

Scrolling has to stay possible if the conversation is taller than the screen. If it fits on an iPhone screen, which it should, don't put it in a scroll view at all, so the drag is never fighting a scroll.

## Page 4: Summary

`LessonSummaryPage` (shared, in `Ergo/Lessons/`). Title `Lesson 2: Fair point?`.

- Heading: "That's lesson 2 done!"
- Takeaway: "When people get frustrated, they sometimes change what you said, make it about you, or act like there are only two choices. Usually they don't mean to, and everyone does it. Once you can spot it, it's easier to get back to what you were actually talking about."
- Related: Straw man, Ad hominem, False dilemma, already set in `Lesson.related`.

The toolbar's close button (from `LessonView`) is the way out, and there's no back button on any page.

## Progress

Everything is saved in `FairPointState` (Defaults key `fairPointState`) as it happens: the page, whether the inbox animation has played (it plays once), which of Sam's messages were tapped, and which of Leo's were scribbled. Ink strokes aren't saved. Leaving and coming back reopens exactly there. "Start Over" on the Learn tab resets it.
