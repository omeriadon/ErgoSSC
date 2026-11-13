# The library and Describe It

- The library is fallacies and biases only. Their entries are the JSON files in `ErgoKit/Sources/ErgoCatalog/Resources`, and an entry may only link (`related`, `lookalikes`) to an id in one of those two files, or the catalog fails to load. The app's screens read them as models of their own (`CatalogStore`), and `LibraryCatalog` reads the same files as plain text to search.
- Describe It (`LibraryFinder`, `LibraryFinderView`) finds entries from a description, with the model on the device (Foundation Models). It's the only place the app uses a model.
- The model never names an entry itself. It says what to search for, `LibraryCatalog.search` finds the candidates, and the model picks from a numbered list of them, so every result is a real entry. Its last call talks the person through the picks (an opening, a few words on each entry, a closing), shown as it's written.
- The model's context is small. Every call is a session of its own, so none carries another's context, and all a call is given of an entry is its name, its kind and its summary. Everything sent has a ceiling in `LibraryFinder`'s limits, and a list that still won't fit is read as two halves.
- The model can be missing (the device can't run it, it's turned off, or it's still downloading). Then the Library doesn't offer Describe It at all, and the library's search is the way to find things. Any call can still fail or be refused, and each of those falls back to what the plain search found, so the page always answers.
- People notice these as situations ("my brother said…"), not definitions, so the prompts say so and the suggestions are situations too.
- What the person describes is never logged.
