# Lessons: the Learn tab

- `Lesson` (`Ergo/Lessons/Lesson.swift`) is every lesson, in order: its title, the question it asks, and the Library entries its summary links to (`LessonLink`, whose ids must exist in that category's JSON).
- `LearnRoute.lesson(Lesson)` pushes `LessonView` onto `NavigationManager.learnPath`, which is saved like the other tabs' paths. `LessonView` hides the back button: its toolbar close (`learnPath.removeAll()`) is the only way out, and the lesson keeps its place.
- Each lesson's pages are in its own folder (`Behind the Words/`, `Fair Point/`), with a root view that switches on its saved page. Everything the person does is saved as it happens in that lesson's own state type, under its own Defaults key (`behindTheWordsState`, `fairPointState`), so a lesson reopens exactly where it was left. `Lesson.startOver()` resets it.
- `LessonSummaryPage` is every lesson's last page. Showing it adds the lesson to `lessonsFinished`.
- Every answer is authored, so checking one is deterministic. A model may only ever write around a result (like a line about a score), never decide it.
- What each lesson is and why is in `Plans/lesson-*.md`.
- Lesson 2's chat pieces (`ChatBubble`, `ChatConversation`, `ChatInbox`) are in `Fair Point/` and are reusable by any conversation. Its page 3 matches a scribble to Leo's bubbles by their frames in one named coordinate space, never by words, and only scrolls when the conversation doesn't fit, so the drag never fights a scroll.
