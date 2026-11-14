# Lesson 4: Lucky socks

What the lesson teaches: when something seems to happen "every time", it's usually because the times it happened are the ones we notice and remember. Two ideas:

- **Confirmation bias:** noticing and remembering what fits what you already believe, and missing what doesn't.
- **Count the misses:** to check whether two things really go together, count all four boxes (both, either one alone, neither), not just the times they both happened.

It's the first lesson about a bias rather than a fallacy, so it uses the Library's other half. It's personal and kind: everyone does this, and nobody in it is lying. It always shows a claim that holds up too. It's kept short (about a minute), so it can be shown or skipped in the three-minute demo.

The design was settled in conversation, and this doc is the reference.

## The theme

Jess, a friend, and her football team's season. Her messages use lesson 2's chat bubbles. The four boxes are a 2×2 grid: a row for each side of the condition (socks, no socks) and a column for each outcome (won, lost). The lesson's colour is green, and its card art is a 2×2 grid.

## Page 1: Lucky socks

1. A message from Jess: "Every time I wear my lucky socks, we win! 🧦"
2. Under it, the four games she remembers: socks on, won.
3. A button: **Show the whole season**. This is the moment the lesson is built around:
   1. The other eight games fade in, one at a time, to make the season of twelve.
   2. A beat later, every game flies into its box in the grid.
   3. Each box's count appears.
   4. The comparison: with socks, won 4 of 6. Without socks, won 4 of 6.
   5. "Same either way. Jess isn't lying: the wins in her socks are just the ones she remembers."
   6. A pause to read it, then the two terms and Continue come in on their own.

| | Won | Lost |
|---|---|---|
| Socks | 4 | 2 |
| No socks | 4 | 2 |

## Page 2: Deeper look

The part that holds up. Jess again: "ok fine 😅 but when I sleep badly I'm grumpy the next day. that one's real"

Her last eight days, as the four boxes. Only the top left, the one she remembers, is counted: 3 grumpy days after bad sleep. "Jess remembers 3 grumpy days after bad sleep. But that's only one box. Tap the other three to count them, and see if bad sleep really makes a difference." Each of the other three shows a question mark, and a tap counts it. (An earlier version had each day tapped into its box one at a time. It was slow and didn't teach more than this.)

| | Grumpy | Fine |
|---|---|---|
| Slept badly | 3 | 1 |
| Slept well | 1 | 3 |

Once all four are counted: after bad sleep, grumpy 3 of 4. After good sleep, grumpy 1 of 4. "This one holds up. Counting all four boxes is how you can tell."

## Page 3: Your turn!

"Here are some more. Does each one hold up? ↓"

One claim at a time, each with its four boxes already counted. Before an answer, the top-left box (the one people notice) is lit, and the rest are faint. Two options: **Holds up** / **Doesn't hold up**. After an answer, every box lights up and the two rates appear under the grid, then the explanation, then a **Next** button (**See how you did** on the last).

| Claim | Boxes (both, first only, second only, neither) | Answer | Shown after |
|---|---|---|---|
| Every time I wash my car, it rains. | 3, 9, 12, 36 | Doesn't hold up | It rained after a quarter of the washes, and on a quarter of the other days too. The rainy washes are just the ones that stick. |
| Students who use flashcards pass more often. | 18, 2, 10, 10 | Holds up | Nine in ten flashcard users passed, against half of everyone else. That's a real difference. |
| The hospital is always busier on a full moon. | 4, 8, 40, 80 | Doesn't hold up | A third of full-moon nights were busy, and a third of other nights too. Busy full moons are just easier to remember. |

A claim holds up when the two rates differ by at least 20 points. The answers are authored, and the check is there so the data can't disagree with them.

Then the score and a line under it, then Continue. The model on the device writes the line from which questions were right and wrong (`LessonScoreLine`). It never decides the score. Without the model, the line for that score is shown instead (`LuckySocks.scoreLine(for:)`):

| Score | Line |
|---|---|
| 3 | All three. You're already counting the misses. |
| 2 | Two of three. The one you missed is worth another look. |
| 0–1 | It's easy to count only the hits. Checking all four boxes is the habit to build. |

There's 250 points of empty room after the end, to scroll past it.

## Page 4: Summary

`LessonSummaryPage`. Title `Lesson 4: Lucky socks`.

- Takeaway: "When something seems to happen every time, count the times it didn't, too."
- Related: Confirmation bias, Illusory correlation (both biases).

## Progress

Saved in `LuckySocksState` (Defaults key `luckySocksState`) as it happens: the page, whether page 1 has shown the whole season, which boxes page 2 has counted, each quiz pick, and how many claims the Next button has brought in.
