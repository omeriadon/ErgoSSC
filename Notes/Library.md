# Describe It and the catalog

- There is no browsable Library. The second tab is Describe It (`LibraryFinderView`, `AppTab.library`), and the only thing it uses is a small catalog: 12 entries in the JSON files in `SquintKit/Sources/SquintCatalog/Resources`. The lessons' entries (proof surrogate, straw man, ad hominem, false dilemma, cherry-picking, regression fallacy, confirmation bias, illusory correlation) plus appeal to popularity, slippery slope, anchoring and availability. Each entry has only `id`, `name`, `aliases` and `plain`: nothing else is read.
- `LibraryCatalog` reads those files as plain text (id, name, kind, aliases, `plain`). Nothing else reads them.
- `plain` is the everyday-words description with a small example. It's what Describe It shows on a match and what it gives the model, so changing it changes both. Adon may rewrite it in his own words.
- `aliases` are the other names people use ("Bandwagon", "Strawman"). They matter: the model's names are mapped through them, so add one when a usual name keeps failing to map.
- `LibraryFinder` finds entries from a description, with the model on the device (Foundation Models). Its one other use in the app is the line under a lesson's quiz score (`LessonScoreLine`, see `Notes/Lessons.md`).

## The flow

Greedy sampling, a fresh session for each call, `descriptionLimit` and a token-count check to stay inside the context.

1. **Name (not streamed).** The model is not given a list to choose from, since the on-device model picks poorly from numbered lists but knows the usual names. It's told Squint's names (with aliases) in its instructions and asked for at most two usual names, best first, after restating the situation (`situation` is generated first so it reasons before it commits). No names is a normal answer. If this call fails, the state is `.failed`.
2. **Map (no model).** `LibraryEntryMatcher.entries(named:in:)`. Each name is lowercased, stripped of punctuation and of a trailing "fallacy", "bias" or "effect", then matched exactly against every entry's name and aliases (same normalising). If that fails, FuzzyMatch (edit distance, `maxEditDistance: 1`, `minScore: 0.8`, acronym matches ignored, names under 5 characters only matched exactly) picks the best-scoring entry. Names that don't map are dropped, and duplicates removed. Nothing mapped is `.nothing`: the page says politely that it doesn't match anything Squint knows about yet. Only real entries are ever shown.
3. **Explain (streamed).** The model gets only the mapped entries (name, kind, `plain`) and the description, and writes an opening plus one explanation per entry, matched back by number so the order is always the mapped one. The entries are shown as soon as they're mapped, so if this call fails or doesn't fit, they stay without an opening or explanations. It's never `.failed`.

## The page

- Each match shows inline (name, kind, the explanation, `plain`). Nothing navigates to a detail page.
- Without the model (`LibraryFinder.isModelAvailable`), the tab is a short note that Describe It needs Apple Intelligence, a search field ("Search by name or keyword"), and all 12 entries as cards (name, kind, `plain`). `LibraryEntryMatcher.search` filters them with FuzzyMatch over name, aliases and `plain` as you type, best first.
- Both end in a small footnote crediting Wikipedia's lists (links) and CC BY-SA 4.0.
- People notice these as situations ("my brother said…"), not definitions, so the prompt says so and the suggestions are situations too. Each suggestion is a clean example of one entry.
- What the person describes is never logged.
