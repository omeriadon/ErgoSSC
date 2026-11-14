# Lesson 1: Behind the words

What the lesson teaches: any piece of writing has a **claim** (what it wants you to believe or do), and it may have **reasons** (what holds it up), with **filler** around them. The person sorts one real passage into those three, then sees it collapse to its skeleton.

The tone is curious, never mocking. The passage is a friendly recommendation that genuinely holds up: the point is seeing what does the work, not tearing it down.

The Freeform mockup is the layout reference (`/Users/omeriadon/.t3/userdata/attachments/4d056eea-7079-4472-8229-fb7ae0847eeb-22f5ddc4-1845-4279-9a4f-12559d8be438-pdf.pdf`). **Its passage is out of date**: wherever it shows the "In today's fast-paced world" post, use the coffee reply below. Where this doc and the mockup disagree, this doc wins.

Arrows in the mockup: one going down is a change within the same page, one going sideways is a new page.

## The passage

A reply in a local forum thread. The theme for this lesson is that forum: a thread titled **"Best coffee near the station?"**, and this reply under it from a username with an avatar, a timestamp and a like count. It should look like a real post, not a blue box.

> Honestly, life's too short for bad coffee. If you're anywhere near the station, go to Little Bird. A flat white is $4.50, they roast their own beans every morning, and it's the only place round here open before 7. Trust me, you'll thank me later.

It splits into **six units**. The third sentence splits at its commas and "and" into three reasons.

| # | Unit | Is |
|---|---|---|
| 1 | Honestly, life's too short for bad coffee. | Filler |
| 2 | If you're anywhere near the station, go to Little Bird. | **Claim** |
| 3 | A flat white is $4.50, | Reason |
| 4 | they roast their own beans every morning, | Reason |
| 5 | and it's the only place round here open before 7. | Reason |
| 6 | Trust me, you'll thank me later. | Filler |

The word count is computed from the passage text, never typed in (it's 45).

## Page 1: Behind the words…

Title: `Lesson 1: Behind the words…`

1. The forum thread and the reply, as it would really look.
2. Under it: "Looks like a normal reply, right?"
3. A button: "Look closer…"

Tapping it changes the same page (no navigation) to:

- "Some terms we're going to learn:"
- The three terms, each with its definition:
  - **Claim:** What the writing wants you to believe or do.
  - **Reason:** Something that, if true, makes the claim more likely.
  - **Filler:** Anything you could delete without losing either.
- A Continue button to page 2.

No sentence is labelled on this page. The person finds them on page 2.

## Page 2: Deeper look

Title: `Lesson 1: Deeper look`

The reply again, split into its six numbered units as soon as the page opens (the mockup's top-right annotation).

### Question 1

"Which part here actually says what it wants you to do?"

The person taps a unit in the passage itself (no row of number buttons).

- **Right (unit 2):** it turns green, the others dim slightly, and question 2 appears.
- **Wrong:** that unit flashes red, with a small line under the passage: "Does this actually tell you to do something?" They try again. Question 2 only appears once the claim is found.

### Question 2

"So what are the other parts?"

One row per remaining unit (1, 3, 4, 5, 6), each with a **Reason / Filler** choice. After a pick, show whether it's right, and if not, the line below. The row then locks on the right answer.

| Unit | If they pick wrong |
|---|---|
| 1 Honestly, life's too short… (Filler) | True of every café. It doesn't tell you anything about this one. |
| 3 A flat white is $4.50 (Reason) | If that's true, is Little Bird a better pick? Then it's a reason. |
| 4 they roast their own beans… (Reason) | If that's true, is Little Bird a better pick? Then it's a reason. |
| 5 the only place… open before 7 (Reason) | If that's true, is Little Bird a better pick? Then it's a reason. |
| 6 Trust me, you'll thank me later. (Filler) | It asks you to trust it instead of giving you a reason to. |

### The skeleton

Once all five rows are answered, both question sets fade out and, on the same page:

1. The filler units (1 and 6) dim right down in the passage. The claim and the three reasons stay bright. This is the moment the lesson is built around, so it's worth animating well.
2. Under the passage:
   > The friendly bits make it nice to read. The reasons are what make it worth listening to.
3. The skeleton:
   > **What it wants:** go to Little Bird.
   > **Why:** $4.50 flat whites · beans roasted every morning · open before 7.
4. The count: `45 words · 1 claim · 3 reasons`
5. A Continue button to page 3.

## Page 3: Your turn!

Title: `Lesson 1: Your turn!`

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

`LessonSummaryPage` (shared, in `Ergo/Lessons/`). Title `Lesson 1: Behind the words…`.

- Heading: "That's lesson 1 done!"
- Takeaway: "Find what it wants you to believe, then look for what holds it up."
- Related: Proof surrogate (`fallacies` / `proof-surrogate`), already set in `Lesson.related`.

The summary finishes the lesson. The toolbar's close button (from `LessonView`) is the way out, and there's no back button on any page.

## Progress

Everything the person has done is saved in `BehindTheWordsState` (Defaults key `behindTheWordsState`) as they do it: the page, page 1's terms state, every answer and every quiz pick. Leaving and coming back reopens exactly there. "Start Over" on the Learn tab resets it.
