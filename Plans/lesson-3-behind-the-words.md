# Lesson 3: Behind the words

What the lesson teaches: any piece of writing has a **claim** (what it wants you to believe or do), and it may have **reasons** (what holds it up), with **filler** around them. The person sorts one passage into those three, then sees it collapse to its skeleton.

The tone is curious, never mocking. The passage is a post that partly holds up: it has two real reasons, and one line that only sounds like a reason. The point is seeing what does the work, not tearing it down.

The Freeform mockup is the layout reference for the pages. **Its passage and its forum frame are out of date**: use the post below. Where this doc and the mockup disagree, this doc wins.

Arrows in the mockup: one going down is a change within the same page, one going sideways is a new page.

## The passage

A post in a social feed, from an account with an avatar, a handle, a timestamp, and like, reply and repost counts. It looks like a generic feed, not any real app.

It's a post because Squint started with one: a post that didn't seem right. An earlier version used a friendly coffee recommendation in a forum thread, which held up completely but didn't look like what the app is for.

> Nobody is talking about this. School should start at 9, not 8. Teenagers' body clocks run later, so most aren't properly awake at 8, and one school that moved to 9 had far fewer late arrivals. Experts agree. Wake up, people. 😴

It splits into **six units**. The third sentence splits at its "and" into two reasons.

| # | Unit | Is |
|---|---|---|
| 1 | Nobody is talking about this. | Filler |
| 2 | School should start at 9, not 8. | **Claim** |
| 3 | Teenagers' body clocks run later, so most aren't properly awake at 8, | Reason |
| 4 | and one school that moved to 9 had far fewer late arrivals. | Reason |
| 5 | Experts agree. | Filler (a proof surrogate) |
| 6 | Wake up, people. 😴 | Filler |

Unit 5 is there on purpose. It sounds like a reason, so many people will sort it as one, and that's how the lesson shows a **proof surrogate**: words that sound like proof, standing in for it. No expert is named, so there's nothing to check.

The word count is computed from the passage text, never typed in (it's 42, counting the emoji).

## Page 1: Behind the words…

Title: `Lesson 3: Behind the words…`

1. The post, as it would really look.
2. Under it: "Looks like a normal post, right?"
3. A button: "Look closer…"

Tapping it changes the same page (no navigation) to:

- "Some terms we're going to learn:"
- The three terms, each with its definition:
  - **Claim:** What the writing wants you to believe or do.
  - **Reason:** Something that, if true, makes the claim more reasonable.
  - **Filler:** Anything you could delete without losing meaning.
- A Continue button to page 2.

No sentence is labelled on this page. The person finds them on page 2.

## Page 2: Deeper look

Title: `Lesson 3: Deeper look`

The post again, split into its six numbered units as soon as the page opens (the mockup's top-right annotation).

### Question 1

"Tap the part that says what it wants you to believe."

The person taps a unit in the passage itself (no row of number buttons).

- **Right (unit 2):** it turns green, the others dim slightly, and question 2 appears.
- **Wrong:** that unit flashes red, with a small line under the passage: "Is this the thing the post wants you to agree with?" They try again. Question 2 only appears once the claim is found.

### Question 2

"So what are the other parts?"

One row per remaining unit (1, 3, 4, 5, 6), each with a **Reason / Filler** choice. After a pick, show whether it's right, and if not, the line below. The row then locks on the right answer.

| Unit | If they pick wrong |
|---|---|
| 1 Nobody is talking about this. (Filler) | You could put this on any post. It doesn't tell you anything about school. |
| 3 Teenagers' body clocks run later… (Reason) | If this is true, does starting at 9 make more sense? Then it's a reason. |
| 4 one school that moved to 9… (Reason) | If this is true, does starting at 9 make more sense? Then it's a reason. |
| 5 Experts agree. (Filler) | It sounds like a reason, but which experts, and where did they say it? Nobody's named, so there's nothing to check. |
| 6 Wake up, people. 😴 (Filler) | It tells you how to feel, not why to agree. |

### The skeleton

Once all five rows are answered, both question sets fade out and, on the same page:

1. The filler units (1, 5 and 6) dim right down in the passage. The claim and the two reasons stay bright. This is the moment the lesson is built around, so it's worth animating well.
2. Under the passage:
   > The loud bits get your attention. The reasons are what make it worth believing.
3. The skeleton:
   > **What it wants you to believe:** school should start at 9.
   > **Why:** teenagers' body clocks run later · one school had fewer late arrivals.
4. The proof surrogate, named, in its own card after the skeleton. It's shown whether or not unit 5 was sorted rightly:
   > **Looks like a reason, but isn't:** "Experts agree." No expert is named, so there's nothing you can check. It's easy to miss, because it sounds just like proof. That's called a **proof surrogate**.
5. The count: `42 words · 1 claim · 2 reasons`
6. A Continue button to page 3.

## Page 3: Your turn!

Title: `Lesson 3: Your turn!`

"For each of these, look behind the words. Is there a reason holding it up? ↓"

The passages appear one at a time. Each has "This passage…" and two buttons: **Gives a reason** / **No reason given**.

- Any answer, right or wrong, locks the passage, shows whether it was right, and shows its explanation. Then the next passage appears.
- Only the first answer counts towards the score.

| Passage | Answer | Shown after |
|---|---|---|
| Our new formula is our best yet. You'll feel the difference from day one. | No reason given | Two claims and no reason for either. |
| Bring a jacket. It drops to four degrees after dark. | Gives a reason | Short and plain, with a claim and a reason. |
| At the end of the day, it is what it is, and what matters is that we keep moving forward together. | No reason given | There isn't even a claim to disagree with. |
| This is the most important election of our lifetime, because the next government sets the emissions targets through 2040. | Gives a reason | It sounds like hype, but it gives a reason. Whether the reason is true is a separate question. |

When the last one is answered, the score appears: "3 of 4". Under it is one line about how it went, written by the model on the device from which passages were right and wrong (`LessonScoreLine`). It never decides the score. Without the model, the line for that score is shown instead:

| Score | Line |
|---|---|
| 4 | Every one. You're already looking underneath. |
| 3 | Nearly all of them. The one you missed is worth another look. |
| 2 | Half. Some of these are meant to be tricky. |
| 0–1 | These are harder than they look. Try reading for the reason first. |

Then a Continue button to the summary.

## Page 4: Summary

`LessonSummaryPage` (shared, in `Squint/Lessons/`). Title `Lesson 3: Behind the words…`.

- Heading: "That's lesson 3 done!"
- Takeaway: "Find what it wants you to believe, then look for what holds it up."
- Related: Proof surrogate, shown as plain text and already set in `Lesson.related`.

The summary finishes the lesson. The toolbar's close button (from `LessonView`) is the way out, and there's no back button on any page.

## Progress

Everything the person has done is saved in `BehindTheWordsState` (Defaults key `behindTheWordsState`) as they do it: the page, page 1's terms state, every answer and every quiz pick. Leaving and coming back reopens exactly there. "Start Over" on the Learn tab resets it.
