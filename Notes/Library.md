# Describe It and the catalog

- There is no browsable Library. The second tab is Describe It (`LibraryFinderView`, `AppTab.library`), and the only thing it uses is a small catalog: 12 entries in the JSON files in `SquintKit/Sources/SquintCatalog/Resources`. The lessons' entries (proof surrogate, straw man, ad hominem, false dilemma, cherry-picking, regression fallacy, confirmation bias, illusory correlation) plus appeal to popularity, slippery slope, anchoring and availability. An entry's `related` and `lookalikes` may only name ids still in the files (they're empty now), and every key stays.
- `LibraryCatalog` reads those files as plain text (id, name, kind, summary). Nothing else reads them.
- `LibraryFinder` finds entries from a description, with the model on the device (Foundation Models). Its one other use in the app is the line under a lesson's quiz score (`LessonScoreLine`, see `Notes/Lessons.md`).
- It's one greedy, streamed call, given every entry numbered (name, kind, summary) and the description. The model never names an entry itself: it picks numbers, so every result is real. `descriptionLimit` and a token-count check keep it inside the context.
- Picking nothing is a normal answer: empty `choices` becomes `.nothing`, and the page says politely that it doesn't match anything Squint knows about yet. A failed or refused call is `.failed`, with its own short line. There is no plain-search fallback.
- Each match shows inline (name, kind, the model's explanation, the summary). Nothing navigates to a detail page.
- Without the model (`LibraryFinder.isModelAvailable`), the tab is a `ContentUnavailableView` saying Describe It needs Apple Intelligence.
- Both states end in a small footnote crediting Wikipedia's lists (links) and CC BY-SA 4.0.
- People notice these as situations ("my brother said…"), not definitions, so the prompt says so and the suggestions are situations too, including one that matches nothing.
- What the person describes is never logged.
