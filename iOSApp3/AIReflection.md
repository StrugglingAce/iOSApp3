
# AI Reflection — Assignment 5: iOSApp3

## Overview

This app uses the Art Institute of Chicago's public REST API to let users
search and browse the museum's collection. AI assistance (Claude) was used
during development. This document reflects on how and where it was helpful.

---

## Question 1: How did you use AI in this assignment?

AI was used in the following specific ways:

**Choosing a venue:** I asked Claude to recommend a museum API with a similar
structure to The Met's — same search-then-detail pattern, free to use, no
authentication needed. It suggested the Art Institute of Chicago (ARTIC)
because it meets all those criteria and has good image support via IIIF.

**Model design:** I described the JSON the ARTIC API returns and asked Claude
to help design the `Artwork` Codable struct. The key detail it flagged was
that search results and single-artwork fetches return different fields — so
the model needed optional properties for fields like `description` that only
come back from the detail endpoint.

**HTML in the API response:** The ARTIC `description` field returns HTML
(e.g. `<p>Monet painted…</p>`). I asked Claude how to strip the tags before
displaying in SwiftUI, and it provided the regex approach used in
`strippedDescription`.

**The `.task` modifier:** I asked Claude to explain why `.task` is preferred
over `onAppear + Task { }` for triggering network requests. The key insight:
`.task` automatically cancels its async work if the user navigates away
before the request finishes. `onAppear` doesn't do this, which can cause
state updates to fire on views that are no longer on screen.

---

## Question 2: What was AI good at, and what was it not good at?

**Good at:**
- Writing Codable structs and CodingKeys mappings quickly
- Explaining *why* a pattern is correct, not just *what* it is
- Suggesting how to handle edge cases (null image IDs, HTML descriptions)
- Pointing to the right built-in SwiftUI tool (`AsyncImage`) for remote images

**Not as useful for:**
- Knowing the exact live JSON structure of the ARTIC API — I had to verify
  by actually calling the endpoint in a browser and reading the response
- Debugging Xcode build errors — AI can suggest fixes but can't see the
  actual error location in context the way Xcode can
- Choosing between architectural options — AI presented several ways to
  share the ViewModel between ContentView and ArtworkDetailView, but I had
  to decide which fit the assignment scope

---

## Question 3: What would you do differently next time?

Using AI sped up the mechanical parts of the assignment (Codable structs,
URL construction, switch statements on AsyncImage phases). That freed up time
to focus on the concepts that were actually new — specifically, how `.task`,
async/await, and `@Observable` all work together.

One pattern I noticed: when I copied AI-generated code without understanding
it, I couldn't explain it when I read it back later. For example, I didn't
immediately understand why `ArtworkDetailView` needed a separate
`@State private var detailedArtwork: Artwork?` instead of just updating the
`artwork` let property. I had to ask a follow-up question: Swift `let`
properties on a View struct are immutable — you need `@State` for any data
the view changes locally after it appears.

**What I'd do differently:** Before asking AI to write code, first write out
what I *think* the code should look like, even if it's incomplete or wrong.
Then compare with AI's version. The differences show exactly what I don't
understand yet — which is more useful for learning than reading an
explanation from scratch.
