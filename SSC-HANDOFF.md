# Handoff: what ErgoSSC should be

This is the full context of a direction conversation between Adon and an agent that turned out to be working in the wrong folder (`Ergo`, the full app) when it should have been in `ErgoSSC`. Nothing was built. It was thinking only, and the thinking isn't finished: the last question to Adon is still open (see [Where it stopped](#where-it-stopped)).

**The conversation itself was held against the full `Ergo` repo.** So some of what the earlier agent said in it assumed things that aren't true here (a server to remove, a paywall on the lessons, a ban on Foundation Models). The code facts at the end were checked against `ErgoSSC` afterwards, by reading only. Nothing was built or run.

## The situation

- **Ergo** (`/Users/omeriadon/Documents/Xcode_App_Library/Ergo`) is the full app Adon is building for the App Store. It has four tabs (Board, Logic, Ask, Library), a Vapor server, accounts, sync, sharing and purchases. It is paused for about a month.
- **ErgoSSC** (`/Users/omeriadon/Documents/Xcode_App_Library/ErgoSSC`) is a duplicate of that repo, made for the Swift Student Challenge. Adon has already stripped out the server, Ask, and much else. Once the SSC is done, nothing from ErgoSSC is expected to go back into the full Ergo.
- Adon does not expect a cut-down version of the existing app to work for the SSC. A lot of reinvention is expected: much deleting and much new work.
- Adon's view: thinking about the execution matters far more than the execution itself, and the past winners' words reflect that.
- Being succinct matters far more than having lots of features.

## What the Swift Student Challenge asks for

From the two Apple pages Adon pasted (the 2027 challenge):

- Submit an app built in Xcode or Swift Playground that **can be experienced within three minutes**.
- New this year: the app can be for any Apple platform.
- Apple's advice: "Great apps start with great ideas. First, think about what it will do and what problem it can solve."
- Events: Get started with agentic coding (10 Dec 2026), Get ready for the Swift Student Challenge (14 Jan 2027), Create your app's story (4 Feb 2027).

`CLAUDE.md` here already records the rest of the rules: judged offline so nothing may need the network, a ZIP of at most 500 MB, Adon's own work with credited open source allowed, and no private API.

### The past Distinguished Winners

Each one is a single idea that fits in a sentence, usually with a personal story behind it:

| Winner | App | The idea |
|---|---|---|
| Anton Baranov | Pitch Coach | Rehearse a pitch and get feedback on pace, filler words, posture |
| Rino Ito | ColortheGoalDaruma | Commit to a goal by colouring a Daruma's eye; visuals all her own |
| Gaurav Kukreja | Fast Aid | Step-by-step help in a medical emergency, with a hands-free Panic Mode |
| Larissa Okabayashi | Yume's Spellbook | Teaches non-experts how LLMs work, through a wizard character |
| AJ Nettles | CryptOh | Makes people think about password strength |
| Keitaro Kawahara | PuzzlePix | Turns your photos into puzzles |
| Ruoshan Li | Deep Blue Tangram | An AR ocean puzzle game for young children |
| Vildan Kocabas | MyCycle | A period tracker that explains the data |

Observations drawn from them:

- None is several tools behind tabs.
- Teaching one thing well is a genre that wins (Yume's Spellbook, CryptOh, MyCycle).
- The stories are about why the person made it, more than about features.

## How the conversation went

### 1. Adon's opening question

Adon was going to ask for help making the logic lessons better, then stepped back: is it a good idea to have Library, Board and Logic all in the SSC app?

Adon's own reading:

- The Library can't stand alone. It's just a dataset.
- Keeping only Logic would need considerable work to build the app around logic, lessons and worked examples.
- Keeping the Board would need something like a one-shot analysis (like the library finder) that goes through the premises and labels them, small enough for on-device models to manage.

### 2. The agent's first answer

**Centre it on Logic, keep the Library as the reference behind it, cut the Board and Ask.** The real question is what the one sentence is, since three equal tabs in three minutes gives each about a minute and no story. Proposed sentence: *learn to tell whether an argument actually holds up.*

Reasons given for Logic:

- The checker, the prover and `LogicEnglish` are deterministic, so the app is never wrong, and `.undecided` is honest. For an app about rigour that is the pitch. (Adon: "interesting".)
- It needs no server, account or model.
- A parser, a tableau prover and an exact logic-to-English reader are Adon's own work, which is stronger evidence than a model call.
- Teaching is the genre that wins. (Adon agreed.)

Reasons given against the Board:

- A one-shot labeller is the riskiest thing to put in front of a judge. A small on-device model picking fallacies from a list will force matches, and one wrong label in three minutes undoes the app's credibility. The model may not be available on the judge's device at all. (Adon: "fair enough".)
- Without AI, the Board is cards added one at a time, which isn't a demo. (Adon agreed, and added that even they can't think of what board they would put in it.)
- "AI analyses your text" is likely to be a common entry this year. (Adon: "oh dear yes".)

Where an on-device model does fit: English to logic for one short argument, and nothing else. The model only proposes the formalisation, `LogicEnglish` reads it back so the person sees what was understood, and the checker gives the verdict. If the model is missing, the keyboard still works.

Costs named:

- The lessons need to be more than read-then-quiz. Valid/invalid is a coin flip. A better exercise: have the person make the premises true and the conclusion false themselves. (Adon agreed with the idea, not the wording.)
- The first screen should be an argument in plain English, with symbols coming later.
- The Library stops being a destination and becomes what a flaw's name opens.
- Purchases, accounts, sync, sharing and the "first two lessons are free" gate come out. (Adon thought these were already gone, which was the first sign of the wrong folder.)

### 3. Adon's pushback

- **The concern:** learning that ¬A implies B may not help anyone do the one-sentence thing. Formal logic may not be what teaches you to tell whether an argument holds up.
- **The real motivation:** how much slop we see in daily life, how much lazy writing, how much plain-wrong stuff. Adon wants Ergo to help you see through that, to dissect things and see where they don't hold up.
- **On the sentence:** Adon agrees it is about better arguments and better thinking, but feels "argument" narrows it too much.

### 4. The agent's second answer

The concern is right. Most bad writing isn't formally invalid. It fails earlier, in roughly this order:

1. **It says nothing.** There is no claim you could disagree with.
2. **It claims with no support.** Confidence and no reasons.
3. **The support is beside the point.** Who said it, how many people think it, how it feels.
4. **It leans on something unstated.** The reasons only work if you grant a premise nobody wrote down.
5. **The shape is broken.** The reasons are there and still don't reach the conclusion.

Formal logic only covers the fifth. The first answer put it at the centre because it is the part that is never wrong, but that describes the engine, not the skill. The skill is dissection, and symbols are the last tool reached for.

On "argument" being too narrow, the agent half agreed:

- The word should go from the surface. Nobody thinks of an ad or a LinkedIn post as an argument.
- "Better thinking" is too vague to show in three minutes.
- "Plain wrong" facts have to be dropped. An offline app can't know what is true, and pretending to would undo it.
- Proposed sentence: *see what a piece of writing is actually claiming, and whether anything holds it up.*

The proposed app:

- **The person does the dissecting, on passages Adon writes.** They are the kind of thing people really see: an ad, a headline with a statistic, a motivational post, a paragraph that sounds wise and says nothing.
- **The interaction is on the text itself.** Tap the sentence that is the actual claim. Mark what supports it and what is filler. Find what it assumes.
- **The reveal is the skeleton.** The passage stripped to its claim and its reasons in plain English, with usually very little left.
- **Logic arrives last, only when the shape is the problem.** Then the checker gives its verdict and a counterexample, and the flaw's name opens its Library entry.
- **Authored passages mean every answer is known in advance.** That keeps the "never wrong" property without a model judging anything.
- **The same tool then works on the person's own text.** Paste anything, mark the claim and the supports by hand, get the skeleton. The app only gives structure, so there is nothing for it to mislabel. An on-device model could be optional here, proposing the symbols for a short argument and nothing more.

What that changes:

- The lessons stop being a logic course. They become the five failures, one passage each, with connectives taught only where the fifth needs them.
- The writing is the app. A judge sees two or three passages, so those need more care than any code.
- Most of the Logic tab becomes a detail view for the person who wants to go further.

## Where it stopped

Adon had not yet answered this:

> Does dissecting authored passages feel like the right core, or were you picturing something closer to pasting in whatever you just read?

So the second answer is a proposal, not a decision. Adon has said a lot of thinking still needs to happen.

## What is settled and what isn't

Settled by Adon:

- ErgoSSC is a separate, offline, small, succinct app for the SSC, and it won't be merged back.
- No server, Ask, accounts, sync, sharing or purchases.
- The app is about better arguments and better thinking, seeing through slop and lazy writing, and dissecting text to see where it doesn't hold up.
- Foundation Models are allowed in ErgoSSC, and Describe It already uses them. (The ban the earlier agent worried about is only in the full Ergo's CLAUDE.md.)
- A one-shot AI labeller on the Board is too risky, and the Board has no obvious demo.

Not settled:

- The one sentence. Two candidates are above, and Adon found the first too narrow.
- Whether the core is authored passages, the person's own pasted text, or both.
- Whether the Board survives in any form.
- What the Library becomes: a second tab, or only what a flaw's name opens.
- What the first minute looks like.
- How far the lessons move from formal logic toward the five failures.

## What was changed in ErgoSSC

- `CLAUDE.md` got one line: "Being succinct matters far more than having lots of features." It already said the app is for the Swift Student Challenge, and it has no Foundation Models rule to lift.
- This file was added. Nothing else was touched.

## What ErgoSSC contains

Checked by reading `CLAUDE.md`, `Notes/` and the folders. Read `Notes/` before changing an area.

**Already gone, despite what the conversation says:** the server, Ask, accounts, sync, sharing, purchases, the share extension, the widgets, Break Down and the board analysis. `ErgoKit` is down to `ErgoLogic` and `ErgoCatalog`. `Plans/` holds only its README and `dither-device-corners.md`, so there is no direction doc here.

**Tabs:** `AppTab` is `board`, `logic`, `library`.

**Logic**
- `ErgoKit/Sources/ErgoLogic/Course/LogicCourse.swift` holds the course: 6 lessons (`arguments`, `connectives`, `conditionals`, `valid-and-sound`, `only-if-unless`, `all-and-some`) with 19 exercises between them. Each `LogicLesson` is a title, a summary, a few paragraphs, and `LogicExercise`s. An exercise is an argument in symbols, an English reading, `isValid`, and an explanation. A test checks every answer against `LogicChecker`.
- Every lesson is open. There is no paywall.
- The course's screen is one file, `Ergo/Views/Logic Tab/Course/LogicCourseView.swift`.
- `LogicChecker` uses a truth table for ¬ ∧ ∨ ⊕ → ↔ and `LogicProver` (a tableau) for □ ◇ ∀ ∃, identity and sets. `.undecided` is only for what ran out of steps or quantifies over sets.
- `LogicEnglish` turns logic into English deterministically and reads everything the logic keyboard can write.
- Fallacy ids in `LogicFallacyForm` match ids in `fallacies.json`, which is how a detected flaw can open a Library entry.
- The Logic tab is a list of saved scratchpads, with logic on top and its read-only English reading below.

**Library**
- The entries are JSON in `ErgoKit/Sources/ErgoCatalog/Resources/`: arguments, biases, concepts, fallacies, paradoxes, philosophers, razors, symbols, and an item of the day. About 3 MB.
- Describe It (`LibraryFinder`, `LibraryFinderView`) finds entries from a description with Foundation Models. It is the only place the app uses a model, and it's the "library finder" Adon referred to.
- Its design is the pattern the conversation argued for. The model never names an entry: it says what to search for, the plain search finds candidates, and the model picks from a numbered list, so every result is real. When the model is missing or a call fails, it falls back to the plain search.

**Board**
- A UIKit canvas of cards, arrows and sources, holding English only. Sources are a block of text or a web link, and links open in the external browser.
- Nothing on the Board uses a model here. Cards are added and linked by hand, which is the "no obvious demo" problem in practice.

**One thing the conversation leaned on that isn't here:** the full Ergo's `Plans/07-Direction.md`, whose reasoning on grounding was behind the Board risk argument. Its points: a citation doesn't prove a finding, a fixed list encourages forced matches, and "nothing found" has to be a normal result.
