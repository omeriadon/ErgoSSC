# Swift Student Challenge: written answers

Practice for the submission form. The questions are rebuilt from last year's form, since Apple only shows the real ones to applicants, so the wording may change. Every answer must be Adon's own writing. This file keeps the drafts, the facts to draw on, and the feedback on each draft, never finished answers written by anyone else.

The written answers are one of the three things judged, with technical accomplishment and creativity.

## Open items

- **Library credits.** The list of fallacies and biases came from Wikipedia's lists. Each entry was written from light research on Wikipedia and Google, then reviewed with AI. The names themselves are fine, but the app should still credit Wikipedia as where the list and research came from, with links to the two lists. If any sentence is close to Wikipedia's wording, it's CC BY-SA and must be attributed, like the element summaries last year. Both pages are credited in `Credits.md` at the project's root. Nothing inside the app credits them yet.
- **Accessibility testing.** Test the largest Dynamic Type sizes, and do a full VoiceOver run through one lesson, before writing question 4.
- **Name the post.** Question 1 needs the actual post that started it.

## 1. What does your app do, and what inspired you to make it?

Last year: "Problems it solves".

**Draft 1**

> i mean i thought of the idea for squint one day when i was on social media scrolling through a post and noticed a specific one and i thought, that one just can't be right, so i did a little google search and found it was indeed wrong, which made me think of all the other times something might just be wrong but we never realise, so i made this app to help people like fight against that, and it teaches people to look through arguments, posts and stuff by showing them examples and then showing them whats wrong or right with that, the goal being to have people leave the app more prepared to see through stuff they see online, especially online everythings so crazy right now

**Feedback**

- Works: a real moment opens it, and the jump from one post to "how many others did I miss?" is the insight.
- Name the post. What did it say? One concrete detail makes it believable and memorable.
- Say the idea the story implies: looking it up worked once, but nobody can fact-check everything, so the skill is noticing. That's why Squint teaches a habit instead of checking facts.
- Every lesson also shows something that holds up. It teaches telling the difference, not doubting everything. Give that its own sentence.
- End on what someone can do after using it, not "everything's so crazy".
- Break the one long sentence into four or five.

## 2. Who would benefit, and why?

**Draft 1**

> alright so a young person, so like 13 and they have just gotten a phone and theyre on social media and they see so many posts about so many things, but some things, especially news about politics or news that has statistics might just be exaggerated or they have something wrong with them, so this app would help them see through that and learn to see through a post or news item, i guess

**Feedback**

- Works: one specific person at a real moment. Politics and statistics line up with lesson 3.
- Say what they'd do differently: ask what a post claims, whether anything holds it up, and where its numbers start counting.
- Why 13: reading habits form then, and a good habit is easier to build than a bad one is to fix.
- Widen it in one sentence: a parent, a teacher using it in class, an adult who shares too quickly.
- It isn't cynical, since it shows what holds up too. "Trust nothing" is as bad as "trust everything".
- Drop "i guess".

## 3. Which frameworks and technologies did you use, and why?

Last year: "Other tech".

**Draft 1**

> for the app itself, all of the ui and navigation was using swiftui, for the glass effects, animations, transitions, graphs and graphics, which i picked over uikit because it was so much simpler to write and edit the code to tweak padding to look right
>
> i did use some uikit and Metal to create that background effect, its a file i created before and optimised for performance so i just took it and dropped it into Squint and ye i think it looks nice
>
> i used foundation models to give the user a more personalised summary for each quiz in each lesson, and i made some hardcoded summaries as well incase the device doesnt have apple intelligence. i also used foundation models to power the Describe It feature, which helps the user find a fallacy or bias just by describing it in their own words, which i found helpful when i had a post and saw it was weird but i could onyl describe what it was doing, i forgot the actual name.

**Feedback**

- Works: the Describe It story is personal, and the fallback lines show thought for every judge's device. Being plain about reusing your own dither file is fine.
- Give SwiftUI a reason a judge can see: the games sorting themselves into the grid in lesson 4, the page transitions, Liquid Glass. "Easier to tweak padding" is small, and it was last year's reason too.
- Say why Metal: the dither is worked out for every pixel many times a second, so it runs on the GPU to stay smooth.
- Foundation Models: it runs on the device, so what's written in Describe It never leaves the phone and works offline. And the model only writes the line under the score, never decides it.
- One line on Swift Charts: lesson 3 is built on it, with pinch to zoom and bars growing in.

**Facts**

- SwiftUI: every screen, `matchedGeometryEffect` for lesson 4's sort, Liquid Glass, the page transitions.
- Swift Charts: lesson 3's charts, `MagnifyGesture` to pinch, bars that grow in.
- Foundation Models: Describe It (`LibraryFinder`), and the line under each quiz score (`LessonScoreLine`, greedy, so the same results always get the same line), with a fixed line when there's no model.
- Metal: the dither behind the pages and summaries.
- UIKit: the tab transition's blur, and the status badges drawn over sheets.

## 4. How did accessibility factor into your design?

**Facts, from the code**

- Reduce Motion is read in about 20 files. Long animations become short fades.
- VoiceOver gets real descriptions: lesson 4's season is read as counts, lesson 3's charts read every year's value, and on lesson 3's pinch page VoiceOver users swipe up and down to change the start year.
- Haptics confirm right and wrong answers.
- Nothing relies on colour alone: the four boxes are labelled, and lesson 2 names each fallacy under the message.

**Not done yet:** the largest Dynamic Type sizes, and a full VoiceOver run through a lesson. Only write what's been checked.

## 5. Did you use open source? List it and why.

- [Defaults](https://github.com/sindresorhus/Defaults) by Sindre Sorhus (MIT): saving each lesson's progress.
- [FuzzyMatch](https://github.com/ordo-one/FuzzyMatch) by Ordo One (Apache 2.0): Library search that forgives typos.
- Both are copied into `Packages/` so nothing needs the network, with what was trimmed and their credits in `Packages/README.md`.

## 5.5. Content you don't own

Last year: "Non-ownership". See the Library credits in the open items above.

## 6. Did you use AI tools, and how?

Be concrete about what an assistant did and what you decided: the lesson design, the content, the tone, the cuts. Include the AI review of the Library entries. Show you can explain every part.

## 7. Beyond the challenge

Last year's answer had Flavortown, contributing to Anyways, and helping a classmate learn SwiftUI. Update it with what's happened since.

## 8. Social

Portfolio: dev.adonis.pt

## 9. Anything else, or notes for the judge

- Apple Intelligence is optional: Describe It and the written score lines only appear with it, and everything else works without.
- A suggested order if time is short: lesson 1, then lesson 4.

## Last year's answers (Elements)

For reference: the structure, and what worked.

**7. Problems it solves**

I was a chemistry student, but I found it hard to engage with traditional periodic tables. They were static and either too simple to get useful information out of or too complex to understand at a glance. Remembering valencies and bonds was like an impossible task, and I struggled to make real use out of the data they presented, and because they were static and didn't adapt to my level of understanding, I found it harder to build a good understanding of the subject. I was quite frustrated with how inaccessible and boring these tools were.
So, I wanted to create an app that could help me as a student, that would help make the periodic table more accessible and engaging. I wanted to turn the periodic table into a tool that adapts to the user's level of understanding, making it easier to explore and learn and test their knowledge.

**8. Who would benefit**

This app is for students who don't like using paper periodic tables that either don't have enough information or have too much, and aren't helpful for learning. My app aims to fix that by being very customisable - you can choose what element properties you see and filter to only show the elements you need to see, so that it's never too simple or too overwhelming. I also added a quiz feature that uses Apple Intelligence that lets you test yourself at your own knowledge level. I also made this app offline because most periodic table apps need an internet connection, which isn't always accessible for everyone.

**9. Accessibility**

Since usability, accessibility, and customisability were the core ideas behind my app, this was an important part of the design of this app.
To achieve this, I tested the app at different Dynamic Type sizes and capped it to make sure it doesn't break the layout, and also read if the user has Reduce Motion enabled to disable animations in my app.
Another thing I added was VoiceOver support, by adding labels and hints to buttons. I also added a haptic feedback toggle in settings, so users who prefer tactile feedback can enable it to help navigate the app.
Lastly, I designed the app to be customisable by allowing users to control the visibility of data sections in the element detail view. I added this to reduce the visual load on the student while still providing them all the information they need.

**10. Open source**

I used 3 open source libraries in my app:
- Periodic table data (github.com/sweaver2112/periodic-table-data-complete) This was the source of the element table data.
- ColorfulX (github.com/Lakr233/ColorfulX) This library provides the animated gradient background I used in the onboarding view, to make the introduction more visually engaging.
- VariableBlurView (github.com/jtrivedi/VariableBlurView) I used this file to apply a progressive blur to the top safe area of the list view to make sure the time and status symbols stayed legible as the list items scrolled under.
I included a third-party licenses file in my project to credit their authors and comply with the licenses.

**10.5 Non-ownership**

The periodic table data I used had a summary for each element sourced from Wikipedia, with a CC BY-SA license. To comply with that license I referenced the source link under the summary and included the CC BY-SA license in my third-party licenses file.

**11. AI**

I used GitHub Copilot and ChatGPT to save time with repetitive and boring tasks, which gave me more freedom to focus on the design and user experience.
For example, I used GitHub Copilot to make the Swift structs and enums for the JSON data when it gets decoded. This needed figuring out optional values and embedded objects, which would have been tedious for me to do manually. Copilot also helped with some repetitive code, such as some utility functions and debugging SwiftData @Query keypaths.
I also used ChatGPT because it was useful for teaching me new frameworks and accessibility features. It taught me how to add VoiceOver and Reduce Motion support, which I then applied to my app. It also explained how to use TipKit, because that was a new framework to me.
I reviewed the code because sometimes it makes mistakes, and doesn't always do things correctly. I didn't need AI for the navigation, layout, or design because they were my favourite parts of the app to create.

**12. Other tech**

The app's UI was made with SwiftUI, because it's a simple way to make modern UI, and better than UIKit because of its advanced features like LazyVGrid, which I used for the table view.
I used the Apple Intelligence Foundation Models to generate the personalised quizzes. It was especially good because it runs offline on-device, keeping the app accessible to as many people as possible by not requiring an internet connection.
To persist element bookmarks, I used SwiftData because it was really easy to integrate with my existing model, and efficient to query, sort, add, and delete bookmarks.
To help the user discover the app's features, I used TipKit to show some tips everywhere. It simplified the job of showing and hiding tips, because it automatically tracks when the user dismisses a tip and doesn't show it again.
I also used UIKit to trigger haptic feedback when navigating around, which made the app feel more intuitive and comfortable.

**13. Beyond**

Right now I'm participating in Flavortown, which is a hackathon that started last year December and ends in March. The goal is to ship and release actual projects, which taught me a lot about the full app development lifecycle. In this hackathon I built this app, Elements, as well as a finance-tracking app called Money and my personal portfolio. I learnt how to use TestFlight and App Store Connect, and how to apply user feedback to my projects, things I haven't learnt before when I was just making apps and leaving them.
I'm also contributing to Anyways, a public transport utility app on the App Store. A friend introduced me to the developers, and since they also happened to use SwiftUI, I started helping the iOS developer improve the app's UI and UX. We spent several hours fixing dozens of issues together, and along the way, we both learnt a lot about SwiftUI modifiers. I'm excited to continue contributing to Anyways and help expand it to Apple Watch and iPad.
I also enjoy helping others learn to code. At school, I'm helping a classmate learn SwiftUI and encouraged them to submit something for the Swift Student Challenge.

**14. Social**

portfolio: dev.adonis.pt
