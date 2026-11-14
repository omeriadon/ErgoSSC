# Lesson 3: The bigger picture

What the lesson teaches: a number can be true and still give the wrong picture, depending on where the counting starts. Two ideas:

- **Cherry-picking:** choosing where to start counting so the numbers tell your story.
- **Back to normal:** after an unusually bad (or good) stretch, things usually drift back to normal on their own, even if nothing changes. Its proper name is regression to the mean, and the Library entry is Regression fallacy.

The tone is curious, not cynical: the lesson always shows what a fair comparison looks like, and the cameras might still help. Lessons 1 and 2 are about writing and people. This one is about numbers, and isn't personal.

There's no Freeform mockup. The design was agreed in conversation, and this doc is the reference.

## The theme

A local news article, "The Northside Herald", with a bar chart drawn in Swift Charts. The article is set in a serif face, like a paper, and so is every headline in the lesson.

## The data

Crashes on Station Road, 2015–2024: 21, 19, 22, 20, 21, 18, 18, 23, **40**, 20. The cameras went in after 2023, because it was so bad. "Usual" is the 2015–2022 average (about 20), computed, never typed.

Similar roads without cameras: 22, 20, 21, 21, 20, 19, 19, 22, 38, 24. They spiked in 2023 too.

## Page 1: The bigger picture

1. The article: "Speed cameras cut crashes on Station Road by half", with a two-bar chart: 2023 (40) and 2024 (20).
2. Under it: "Pretty convincing, right?" and a button, **Zoom out…**
3. Tapping it changes the same page. This is the moment the lesson is built around, so the animation matters most:
   1. The two bars move right and shrink as the other years grow in one at a time from the right to the left.
   2. A dashed "Usual" line draws across.
   3. 2023 gets a note: "Worst year".
   4. A line: "Zoomed out, 2023 was a one-off. The cameras went in because it was so bad, and most years are about 20 anyway."
   5. The two terms, then a Continue button.

## Page 2: Deeper look

The article again, with all ten years. The person pinches the chart to choose where the counting starts. The chart is pinned at its right edge to 2024: spreading the fingers zooms in to fewer years, pinching zooms back out. The headline rewrites itself as it goes (computed from the data):

- from 2023: "Crashes halved since 2023!"
- from 2019: "Crashes down 5% since 2019"
- from 2020: "Crashes up 11% since 2020"
- from 2018: "Crashes about the same as 2018"

The question: "Pinch the chart to zoom in, and find the start year that makes the cameras look best."

Once they land on 2023, "That's the one…" and the part that holds up appear: a dashed line for similar roads without cameras, and "Roads without cameras dropped too, from 38 to 24. So the cameras might still help, just less than the headline says." Then Continue.

The headline always keeps two lines' room, so the chart doesn't jump as it rewrites. VoiceOver can change the start year with the adjustable action.

## Page 3: Your turn!

"Here are some more headlines. Is each one a fair picture, or cherry-picked? ↓"

One at a time. The first two charts show only the window the headline picked, so a cherry-picked one looks fair at first. The last shows every year from the start, since hiding them isn't what makes it unfair. Two options: **Fair picture** / **Cherry-picked**. After any answer, the chart zooms out to all ten years. A cherry-picked one then makes the reveal obvious: a "Zoomed out" tag ("Whole picture" on the last, which never zoomed), the usual line, a note on the year the headline started from ("A dip", "Worst season"), and only the headline's window stays lit. Then the explanation, then a **Next headline** button brings in the next one, in the person's own time. The last one's button is **See how you did**.

After the last one, the score ("2 of 3") and a line under it, then Continue. The model on the device writes the line from which questions were right and wrong (`LessonScoreLine`). It never decides the score. Without the model, the line for that score is shown instead (`BiggerPicture.scoreLine(for:)`):

| Score | Line |
|---|---|
| 3 | All three. You're already asking where the counting started. |
| 2 | Two of three. The one you missed is worth another look. |
| 0–1 | These charts are made to look convincing. Zooming out is the habit to build. |

There's 250 points of empty room after the end, to scroll past it.

| Headline | Window | Answer | Shown after |
|---|---|---|---|
| House prices up 30% since 2020! | 2020–2024 | Cherry-picked | 2020 was a dip. Over ten years, prices have only gone up about 10%. |
| Library visits have grown every year since 2015. | 2015–2024 | Fair picture | This one's fair. It shows the whole picture, and the climb is steady all the way. |
| Goals doubled after the new coach arrived! | 2023–2024 | Cherry-picked | Last season was their worst in a decade. Most seasons they score about 50, so this is mostly back to normal. |

## Page 4: Summary

`LessonSummaryPage`. Title `Lesson 3: The bigger picture`.

- Takeaway: "Before trusting a number, ask where the counting started, and what it's being compared to."
- Related: Cherry-picking, Regression fallacy.

## Progress

Saved in `BiggerPictureState` (Defaults key `biggerPictureState`) as it happens: the page, whether page 1 has zoomed out, page 2's start year and whether the best one was found, each quiz pick, and how many headlines the Next button has brought in.
