# Codex handoff

Updated: 2026-09-07

## Repository state

- Repository: `/Users/lukedupont/bento-shop-feed-summer-26`
- Branch: `luke/feed-topic-polish`
- Handoff remote: `public` (`lukerenedupont/bento-shop-feed-summer-26`)
- Use the latest commit on this branch as the handoff baseline.

## Current prototype

The feed is personalized for Luke, Mikhail, Tobi, Katarina, Kenny, Archie, and
Ashten.
Each buyer receives authored For You and topic feeds backed by the local buyer
profile/catalog data. Feed presentation is shared across buyers rather than
forked into per-profile views.

Ashten is an explicitly fictional, discovery-led fixture built only from
public products already present in the sanitized shelf dataset. It includes no
Shop Account UUID, warehouse activity, saved-item claim, or purchase-history
claim. Its profile avatar uses the user-supplied `IMG_4929.jpg`, center-cropped
to square 1x/2x/3x local assets for the circular UI.

Ashten also has an opt-out `Nari` destination after Following and Deals. It
uses the user-supplied Nari photo, optional locally persisted clothing size,
shoe size, and fit notes; official public BKR products; and archive-fashion and
secondhand rails assembled only from sanitized bundled products. The old
Partner relationship pill has been replaced by a flat Add details/Edit details
action. The shopping-details sheet supports locally editable relationship,
tops, pants, dresses, shoes, and fit notes. The Vivienne Westwood language is
explicitly a watch interest; adjacent products are not mislabeled as Westwood.
No protected Shop account or warehouse data was queried or bundled.

Ashten's For You feed now uses the same utility-shelf grammar as Luke for
prototype realism, including the local `Your orders` and cart examples plus
the shared promotion modules. These are explicitly local demo surfaces backed
by Ashten's bundled public-product fixture, not account or warehouse claims.

When Nari has a valid locally saved birthday within the next 45 days, including
year wrap, Ashten's For You feed inserts `Gifts for Nari` as story rank 2. It
uses Leon's exact full-height feed-card recipe and product-rail geometry, but
with Nari's archive-fashion assortment and Westwood womenswear cover. Tapping
the card uses the same shared-view zoom and opens the Nari gift guide. The card
is absent when the birthday is unknown or outside the occasion window.
Bottom-carousel stories now compose their title and product rail as one
bottom-anchored block rather than independently pinning the title near the top.
Leon and Nari therefore share identical title geometry, while the story accent
builds into a stronger colored floor beneath the title and white product cards.

The `Gift ideas for her` landing card is one full press target with native
press feedback, an amber gradient sampled from Nari's profile image, plain
disclosure chevron, birthday context, and a shared-view
zoom into the full gift-guide prototype. Its preview and the destination are
archive-first rather than BKR-first. The destination keeps Leon's steering,
budget, setting, intent, voice/chat, and swipe-deck interactions while replacing
his child products and copy with an official Vivienne Westwood AW26/27 womenswear
hero, expanded Rick Owens/Issey Miyake/Comme des Garçons/Ann Demeulemeester
products, secondhand jewelry, and a long lazy two-column discovery grid. BKR is
a supporting rail labeled as a callback to the user-provided prior-browsing
context. Shared product-card favorite hearts default to white; Nari rails remove
the diffuse image shadow and use a crisp hairline edge instead.

When Nari's gift guide does not yet have a saved birthday, its bottom glass
prompt asks `When is Nari’s birthday?` and opens the focused birthday-entry
sheet only after an explicit tap; entering the gift guide never presents the
sheet automatically. This skips the broader profile questionnaire. After a valid
birthday is stored, the prompt yields back to the guide's normal voice/chat
steering dock. The compact 160pt sheet uses a lifecycle-aware native
first-responder month field so both entry paths raise the number keyboard with
the sheet without leaving a large blank band above it.

On Nari's landing page, the gift entry is followed by the Archive fashion
product rail rather than a second consecutive promo card. A taller, near-full-
width Vivienne Westwood editorial entry follows the products and zooms into the
archive-led guide, bringing the page closer to the media-led For You rhythm.
The landing-page gift entry uses the shared 12pt page margin, while the Westwood
editorial card uses a true 16pt margin on every side instead of running edge to
edge. The gift entry and destination now share a pink-plum palette sampled from
Nari's campaign image, and
the gift entry uses the same two-card-plus-peek rail rhythm as the home feed.
Its 22pt title and 16pt supporting copy reuse the Archive fashion hierarchy;
the profile header uses 32pt for Nari and a compact 14pt Edit details action.
The Archive rail starts with jewelry and then apparel so it does not repeat the
gift preview's first products. The top navigation now says `For Nari` without a
second avatar; Nari's photo remains only in the profile block.

Nari's landing page also carries a persistent `Tell us more about Nari` agent
composer immediately above bottom navigation. It reuses the app's glass input
treatment while retaining the requested chat icon. It opens an 87%-height profile sheet
matched to Figma frames `1289-16981` and `1289-18130`. The sheet is locked to
that single detent so content scrolling cannot expand and collapse the Figma
composition. Its header clears the drag indicator with a measured sheet-relative
inset, and its copy uses the named Gravity type hierarchy rather than local font
values. It also uses the measured vertical spacing, tall
two-column media cards, black selection states, and a thumb-free segmented age
slider. The birthday question branches dynamically: Yes quickly morphs into
inline MM/DD/YYYY fields, focuses Month, and keeps the rest of the questionnaire
in place; No reveals the approximate-age slider inline. The single black Save
action at the end validates and persists the inline birthday along with the
quiz. Selected interests render as solid-black pills
without checkmarks, while unselected suggestions retain the quiet white-pill
treatment. The sheet also persists a taste lens, editable interests,
recommendation priorities, and the desired discovery range. These local-only
answers update the landing-card preview order and seed the Nari gift guide's
ranking, setting, copy, and adult product bias. Gift-occasion budget/mood
controls remain separate inside the guide, where Speak with Shop and Chat with
Shop are both retained. Debug-only `-openNariProfile`,
`-openNariBirthdayQuestion`, and `-openNariAgeSlider` provide repeatable
profile-sheet QA states.
The gift guide has no launch-time birthday-sheet hook, so entering Gifts for
Nari cannot accidentally jump into birthday entry.

For the scripted demo, every fresh profile-sheet presentation starts the
birthday question at Yes/No even when a birthday was saved previously. Yes
reveals blank inline MM/DD/YYYY fields and focuses Month. The compact standalone
birthday sheet remains only on the gift-guide entry path, with its own back arrow
and Save action. Recommendation priorities
now use restrained Gravity-icon cards rather than flat text blocks.

New profiles begin with birthday knowledge, persona, interests, priorities,
and discovery range entirely unanswered. Existing answers remain persisted,
and a selected persona can be tapped again to clear it. Interests retain a
stable visual order when selected, with Add interest after the recommendations.
Recommendation priorities use a separate two-column card pattern rather than a
second pill cloud. Inline `Nari` mentions use the quieter gray treatment.
The Add interest action uses the same quiet gray filled-pill treatment as the
unselected suggestions instead of a dashed special state.
Debug-only
`-openNariDetails` opens the shopping-details sheet and `-resetNariProfile`
clears Nari's local answers for repeatable fresh-state QA.

Prominent media-card disclosures now share the Hyperfeed-style white forward
arrow in a quiet translucent circular control. The Nari gift entry and tall
Vivienne Westwood entry both use that component instead of mixing a list
chevron with a bare arrow. The amber gift entry uses a lower-opacity white
surface and tint so the white arrow remains legible against the card color.

Gift-guide header controls use self-describing labels (`Budget $100`,
`Indoors`, and `Surprise me`) instead of the ambiguous `$100`, `Inside`, and
`Surprise` shorthand.

The shopping-details editor now uses a compact 78% detent, a larger black Nari
name, and a seeded Tops size of S to represent a recipient the shopper has
bought for before. Its entry action is a white text-only secondary pill with no
redundant plus or pencil icon. Opening the sheet
keeps the keyboard dismissed; tapping Fit notes raises it. Nari profile sheets share one collision-safe
header geometry; the birthday editor raises the numeric keyboard on its first
field after presentation finishes. Size and relationship menu
chevrons align with each field title and suppress the system-added indicator so
their placement cannot drift.

The approximate-age control now starts at age 1 so younger gift recipients are
representable. The taste-stretch preference reuses that same black fill-track
component while retaining its Familiar, A mix, and Surprising ranking states.
Interest and recommendation-priority pills communicate selection through their
black fill alone, with no redundant checkmark. Birthday fields use the same
native number-pad controller in both entry paths; tapping anywhere outside the
fields dismisses the keyboard without adding a keyboard toolbar.

### Feed and topic behavior

- For You opens at the utility rail and resets there when revisited.
- The first feed card smoothly takes over the viewport as the utility rail
  leaves, and subsequent cards share the same full-bleed snap geometry.
- Cards retain a 40pt bottom radius and expose the next-card peek above the
  bottom navigation.
- Topic feeds enter in the normal full-width white-background state and reuse
  the same header navigation component.
- Topic drill-ins preserve buyer context and use shared-view navigation.
- Authenticated shelf exports for every preview buyer contribute privacy-safe
  shelf type, persona, price-band, quality, and related-shelf signals. Raw
  hypotheses, queries, activity, suppression history, and provenance stay out
  of the app bundle.
- Topic drill-ins use those relationships for featured collections and require
  both semantic and price-band fit before showing canonical merchant cards.
- Lifestyle covers are selected from verified topic/product/merchant media;
  merchant cards require a verified bundled wordmark and merchant-owned cover.
- The 10 canonical Luke topics now prefer approved merchant-owned covers from
  exact PDP galleries or relevant Nocs, Fellow, and Extra Butter editorial
  pages. Feed cards, topic headers, and topic feature cards share the same
  `FeedCoverCatalog` decision and retain the bundled covers as load fallbacks.

### Shared presentation components

- `BuyerFeedNavigationBar.swift` owns the buyer avatar and top-level topic
  chips, including the selected white pill and shared shadow treatment.
- `FeedCardStyle` owns shared card radius, spacing, peek, and bottom-navigation
  clearance tokens.
- `GravityShadows` and `GravityTypography` own utility, selected-topic, feed
  contrast, and editorial typography treatments.
- Feed cards, merchant cards, posts, and product cards share the same contrast,
  corner, favorite-heart, and typography conventions.
- Utility cards use a shared horizontal snap rail and consistent card/product
  sizing. Luke currently exposes the Your orders example.

### Opt-in World prototypes

Luke’s experimental Worlds are disabled by default and can be enabled
individually from the avatar/overflow feed-controls sheet. Following and Deals
can also be hidden there without altering the underlying authored feeds. Each
feed independently persists its mix of general recommendations, merchant
cards, and merchant-authored posts; enabled Worlds remain separately managed.

- `HomeFeedPlanner.swift` is the single feed-planning seam. It resolves authored
  and followed content, distributes posts, prioritizes Worlds, applies each
  feed’s composition settings, inserts campaigns, reports available card-type
  counts, and memoizes the resulting render plan.
- `WorldDomain.swift` owns World identity, context, lifetime, session state, and
  preference persistence. Parent/child relationships remain separate from
  identity.
- `CanvasAgentWorldDestination.swift` owns the Watch Canvas presentation,
  steering, shared chrome alignment, and feed-cover Canvas preview.
- `CanvasAgentInfiniteProductCanvas.swift` is the source-aligned Canvas engine
  adapted from `shopify-playground/canvas-agent` at commit `a5957f4`.
- `CanvasAgentSupport.swift` is the adapter seam between canonical Shop
  products and Canvas products.
- `VerySpecialWatchCatalog.swift` owns the deterministic 47-watch snapshot from
  Very Special’s official Watches collection, including canonical prices,
  imagery, and PDP destinations.
- `WorldExperienceViews.swift` contains the remaining lightweight World forms;
  Canvas no longer shares that implementation file.

The Watch Canvas feed card uses a noninteractive instance of the real Canvas
engine as its cover. Opening it restores full pan, zoom, density, steering,
product actions, and Shop PDP routing. The destination computes its own safe
area chrome, so callers provide only the World session, resolved products, and
close action.

### Holiday banner variant

Tap the buyer avatar and use **Holiday banner** to choose:

- Off
- Header
- Feed card

`HomePage.SeasonalPlacement` is persisted through `seasonalPlacement`. The
legacy `holidayHeaderEnabled` value is migrated on first use.

`SeasonalSavingsSurface` owns the shared campaign image, copy, and CTA so the
header and card cannot visually drift. `HolidayFeedCard` adds real buyer
products in a horizontally snapping rail. The rail uses shared feed clearance
tokens and interpolates its inset during takeover, keeping complete product
tiles above the bottom navigation in both compact and snapped states.

## Data boundaries

- Buyer feeds and utility items come from the existing personalized catalog.
- Merchant cards only render when a canonical merchant identity, bundled
  wordmark, and verified lifestyle cover are available.
- Shop Posts are exposed through `ShopPostService.posts(for:)`; curated post
  availability is currently implemented for Luke only.
- The holiday CTA is intentionally a prototype hook until the campaign has a
  canonical collection destination. Product tiles route to real PDPs.

## Verification

Simulator:

- Device ID: `A70613C5-07F2-46D2-8310-7211EC8B7F6B` (`Shop Native [main]`)
- Bundle ID: `com.shopify.purl.prototype.shop.feed.summer.26`

Build:

```sh
xcodebuild -project ShopFeedSummer26.xcodeproj \
  -scheme ShopFeedSummer26 \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,id=A70613C5-07F2-46D2-8310-7211EC8B7F6B' \
  -derivedDataPath /tmp/shop-feed-derived build
```

The clean simulator build, personalized-feed validation phase, and
`git diff --check` pass. The clean app product is approximately `184020 KB`
against the enforced `184320 KB` budget. Existing unrelated Swift concurrency
warnings may remain.

Current local validation on 2026-09-06: personalized-feed validation and
`git diff --check` pass, and the Ashten fixture compiles and runs in the
simulator. This machine currently lacks `pngquant`, so the first local media
optimization produces a `356644 KB` app and trips the existing product-size
gate before Xcode signs the debug product; this is an environment/tooling issue
rather than an Ashten fixture validation failure.

The ranked Nari birthday card and Ashten utility shelf also compile and were
ad-hoc signed, installed, and visually verified on `Shop Native [main]`. A
local QA birthday 20 days out confirms the occasion branch. The current
unoptimized app is approximately `359112 KB`; the only build failure remains
the documented media-size gate.

The Nari destination was also compiled, ad-hoc signed, installed, launched,
and visually verified on `Shop Native [main]`. The profile header, white
Edit details action, centered shopping-details sheet, BKR rail, Vivienne
Westwood archive watch, and archive-fashion products render without overlap.
The avatar-free `For Nari` navigation chip, consolidated 22/16pt landing-card
type, smaller Edit details type, and jewelry-first Archive rail were verified.
The clickable `Gift ideas for her` card and its full `Gifts for Nari`
destination were also visually verified with the Westwood womenswear hero,
archive-first products, and the persistent direct `When is Nari’s birthday?`
glass prompt. Nari’s top gift-guide filters omit the irrelevant Indoors/Outdoors
control. Nari’s profile prompt now slides behind the bottom navigation while
scrolling down and returns on the first upward scroll. The shopping-details
sheet was verified both at rest with no keyboard
and with Fit notes explicitly focused; its Nari title is black in both states.
The 128pt direct birthday sheet uses a leading back arrow and trailing text-only
Save action, does not persist until a valid date is explicitly saved, and requests numeric Month
focus from a child view controller's presentation lifecycle. The main simulator's
software keyboard is enabled so the focused number pad is visible.
Save dismisses the birthday sheet back to whichever page presented it. The profile’s saved state shows the full
ordinal date (for example, `July 10th 2000`) with no age or Change action.
The birthday-question, No/age-slider, and birthday-entry states were checked
against direct 3x exports of the three Figma frames above; the question and age
layouts now align within roughly one text line's antialiasing variance and the
user-requested black selectors supersede the purple Figma accent. The birthday
prompt now places equal-width Yes/No controls beneath the question, and both
the initial prompt and expanded age prompt share the same 18pt question style
as the rest of the profile editor. Yes morphs that question into inline
MM/DD/YYYY fields without presenting another sheet. The birthday question
starts at Yes/No on each presentation for the demo, while saved persona,
interest, priority, and discovery answers remain intact. Nari’s swipe deck now labels left as `Not for her` and right as
`More like this`, includes matching drag feedback and direct buttons, and
advances in one direction after either signal. Ranking is cached during a drag,
vertical scrolling no longer competes with the horizontal gesture, and a 12pt
dead zone keeps both the card label and directional button highlight stable at
center. The gift and inset Westwood editorial cards align their disclosure
arrows with the title; the Westwood card remains 620pt tall for a more immersive treatment. The
editorial section now has no width-forcing container frame and uses a true 16pt
outer inset on every side, with roomier 24pt horizontal/28pt bottom copy padding.
The pink-plum gift card uses a 10% black glass tint with a white arrow, matching the
photo card. Nari’s birthday story is always promoted at exact feed rank 2 for
Ashten’s For You demo, independent of stored birthday state and optional feed
cards. Product assortments de-duplicate canonical image URLs so adjacent tiles
cannot repeat the same media. The de-duplication path safely preserves products
without image URLs instead of attempting to normalize a missing URL. Debug-only
`-openNariFeed` and `-openNariGiftGuide` launch arguments open those states
directly for repeatable visual QA; normal builds still launch on For You. The
current unoptimized app is approximately `359536 KB` and reaches only the same
documented size gate. The latest app was ad-hoc signed, installed, and launched
with `-openNariProfile`; its first profile-sheet frame was visually verified
with birthday, persona, interests, priorities, and discovery all unselected.
The birthday entry focuses Month as the inline fields appear, and the main
Simulator's software number keyboard is enabled. Tapping outside the fields
dismisses it; the questionnaire persists the valid date through its final Save.
Year is optional: month and day alone save and display as, for example,
`July 10th`; a supplied year displays as `July 10th 2000` and is the only case
that contributes a derived age.

The Nari destination and gift-guide copy now use shorter, direct language and no
longer describe BKR recommendations as inferred browsing behavior. Saving the
profile commits a recommendation revision and re-ranks the gift preview plus
archive and secondhand rails. The profile header no longer shows a redundant
personalization-summary line, and its final action is an always-active `Save`.
Gift-preview ranking now reserves at least four unique products for each
downstream recommendation rail, so personalization cannot collapse a row to a
single item. The jewelry-and-vintage pool now includes enough distinct public
products for collector and jewelry preferences to visibly change the leading
gift preview while still leaving four unique products in that downstream rail.
The landing card also changes its supporting line to name the saved taste, so
the result of Save is immediately legible instead of looking unchanged.
The live Simulator's **Connect Hardware Keyboard** option was also disabled;
the number pad now appears as soon as the birthday fields receive focus. A
normal `For Nari` launch was rechecked without the profile sheet—the sheet opens
only from the persistent personalization input (the explicit
`-openNariProfile` launch argument remains a debug-only QA shortcut).
The installed
simulator build was visually checked with an `Individualist · Westwood +1`
profile; jewelry and archive-fashion products lead the refreshed page.

The profile questionnaire now edits a private draft rather than re-ranking the
feed live behind the sheet. Every presentation deliberately starts with
birthday, persona, interests, priorities, and discovery unselected. Save commits
the new draft once, temporarily replaces the persistent `Personalize Nari’s
picks` composer above bottom navigation with `Refreshing Nari’s picks…`, and
shows four-tile shimmer skeletons in each recommendation rail plus three in the
gift preview. After 850ms the newly ranked products fade in and the same bottom
bar briefly confirms `Nari’s picks are updated` before restoring the composer.
The skeleton geometry keeps each row full and honors Reduce Motion by disabling
the traveling shimmer. Personalized gift-preview copy is now the quieter,
generic `Tuned to her taste` instead of exposing a selected interest by name.
The clean questionnaire state and updated generic landing-card copy were
visually verified in the live simulator. Swift compilation and personalized-feed
validation pass; the current unoptimized app is approximately `359992 KB` and
still reaches only the documented media-size gate.

Opening Nari’s gift guide no longer performs the full destination build on the
tap frame. The landing card’s shared-view zoom snapshots only its lightweight
pink-plum surface instead of flattening the live product carousel, the Westwood
hero image prefetches while the Nari feed is visible, and StoryTopicPage reuses
one merged merchant snapshot per render. The Nari destination bounds adjacent
catalog expansion to 96 products, which retains the 60-item discovery grid with
headroom. Gift-guide content now uses a lazy vertical stack, starts from its
already de-duplicated authored order, and performs one deferred personalization
ranking pass after the hero and navigation transition commit. The optimized tap
and loaded destination were verified in the live simulator; Swift compilation,
personalized-feed validation, and `git diff --check` pass. The current
unoptimized app is approximately `360004 KB` and still reaches only the known
media-size gate.

The separate Home/For You `Holiday gifts for Nari` entry now uses the same
lightweight-source principle without sharing an ID with the For Nari landing
card. Its `home-nari-gift-guide` source is attached only to the full-height
media and scrim, so the live title and product carousel are excluded from the
synchronous navigation snapshot. Home feed prefetching now resolves the exact
authored feed cover before falling back to generated lifestyle media, which
warms the Westwood destination hero while the card is approaching. The latest
app was ad-hoc signed, installed, launched with `-openNariHomeCard`, and the
Home-card tap was verified through the shared-view zoom into the loaded gift
guide. Swift compilation and personalized-feed validation pass; the current
unoptimized app is approximately `360060 KB` and still reaches only the known
media-size gate.

## Design intent

- Keep Shop UI direct, restrained, native, and media-led.
- Preserve shared geometry across buyers; do not add per-buyer layout forks.
- Use lifestyle media for feed covers and merchant-owned assets for merchant
  cards.
- Keep editorial titles heavy with controlled multiline leading.
- Avoid bounce or content reflow in the vertical snap interaction.
- Top-level tabs move horizontally; content drill-ins use shared-view depth.
