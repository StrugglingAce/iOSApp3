# AI Reflection — Assignment 6: iOSApp3

## Question 1: How Did You Use AI in This Assignment?

For this assignment I did most of the structural thinking myself first — 
picking the venue, planning the MVVM layout, and writing the first drafts 
of each file — then used AI (Claude) to check my approach and fill gaps 
where I got stuck.

I kept the majority of the code as I originally wrote it. The main areas 
where I leaned on AI were the `Codable` model setup and one specific Swift 
syntax issue I ran into.

**Example 1 — CodingKeys:**
I knew the ARTIC API returns snake_case JSON (`artist_display`, `image_id`, 
etc.) and that Swift uses camelCase, but I hadn't memorized the exact 
`CodingKeys` enum syntax yet. I wrote the struct properties myself, then 
asked Claude to confirm whether my CodingKeys mapping was correct. It was — 
I just had a typo in one key name that would have caused a silent decode 
failure.

**Example 2 — Something I chose not to use:**
Claude suggested I decode the `config.iiif_url` field from the API response 
dynamically rather than hardcoding the base IIIF URL. That's the "correct" 
approach per the API docs. I looked at it, understood why it's better in 
production, but decided to hardcode it for now since this is still a 
prototype and it would have required a more complex nested `Codable` 
structure I didn't want to over-engineer at this stage. I added a comment 
in the code noting this as a future improvement.

**Concepts not yet covered in class:**
The `.task` modifier for async lifecycle management wasn't something we 
had covered in depth. I read the Apple developer documentation for it and 
watched a short WWDC clip to understand how it differs from `onAppear`. 
Once I understood that `.task` cancels automatically when a view disappears 
(which `onAppear + Task { }` doesn't), I was confident using it in 
`ArtworkDetailView`.

---

## Question 2: How Did You Understand, Verify, and Adapt the Code?

**Verification:**
My main verification method was testing directly in Simulator with real 
search queries and reading the Xcode console. Before building any UI I 
actually opened the ARTIC API endpoint in a browser (`api.artic.edu/api/v1/
artworks/search?q=monet&fields=id,title,image_id`) to read the raw JSON 
myself. That's how I confirmed the structure before writing any `Codable` 
structs — I wasn't guessing at field names.

I also hit an image loading issue where no artwork photos were showing up 
at all. Rather than immediately going back to AI, I added `print` statements 
inside the decode loop to check whether `imageId` was actually coming back 
as `nil` or whether it was present but the URL was wrong. Turns out the 
`image_id` field wasn't being requested in my fields parameter — I had 
forgotten to add it to the query string. Fixed it myself once I saw the 
nil output.

**Key changes I made:**

*1. Filtering search results to public domain only.*
Claude's original search query didn't include a public domain filter. After 
reading the ARTIC docs I added 
`&query[term][is_public_domain]=true` to the search URL. This matters 
because non-public-domain artworks return an `image_id` but the IIIF server 
returns a 403 for the actual image — which looked like a broken image in 
the UI. Filtering to public domain eliminated that whole class of confusion.

*2. Separating thumbnail size from detail size.*
The initial code used the same `400,` width for both the row thumbnail and 
the hero image in the detail view. I changed the detail view to use `843,` 
(the size the ARTIC docs explicitly recommend for full display) while keeping 
`400,` for thumbnails. Small change but it made the detail images 
noticeably sharper.

---

## Question 3: What Did You Learn or Get Better At Through This Work?

**Where I levelled up:**
`async/await` with `.task` finally clicked for me on this assignment. In 
earlier work I understood that `async/await` suspends execution without 
blocking the thread, but I was fuzzy on *when* to use `.task` vs creating 
a `Task { }` inside `onAppear`. Seeing the difference play out in a real 
app — where tapping back quickly before a fetch finishes can cause state 
updates on a view that's already gone — made it concrete. `.task` handles 
that cancellation for you automatically. That's the kind of thing that's 
easy to miss when you're just reading about it.

I also got more comfortable with the pattern of keeping the `fields` 
parameter minimal for list queries and requesting more fields only in detail 
fetches. It's a straightforward optimization but it forced me to think about 
what each screen actually needs rather than just dumping all fields 
everywhere.

**What went well:**
The MVVM split felt natural this time. `SearchViewModel` genuinely stayed 
focused on data — no UI logic bled into it — and the views stayed focused 
on display. That separation made debugging much easier because I always knew 
which layer a problem belonged to.

**What didn't go as smoothly:**
The image issue took longer than it should have because I initially assumed 
the URL format was wrong and spent time double-checking that before realizing 
it was just a missing field in the query string. Next time I'll add console 
logging to network calls from the start rather than after things break — 
it's a small habit that would have saved me 20 minutes.
