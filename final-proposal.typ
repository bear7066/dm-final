// Data Mining final project proposal (written 2026-11-19, dated 2026-11-24): dense pattern mining on retail transactions.
// Method follows Takahashi et al., "Exact Mining of Dense Patterns via Direct Evaluation of Local
// Interval Frequency Using a Sliding Window", arXiv:2604.24122 (2026). Every paper number below is
// quoted from that paper; nothing on our own dataset has been measured yet.
// Build: typst compile final-proposal.typ

#import "slide-kit/core.typ": *
#import "slide-kit/themes.typ": steel-blue-dots

#let theme = steel-blue-dots
#let title-slide = title-slide.with(theme: theme)
#show: body => deck(theme: theme, body)

#let survey-slide(title, subtitle: none, size: 17pt, title-color: theme.primary, body) = page(fill: theme.background)[
  #pattern-layer(theme: theme)
  #stack(dir: ttb, spacing: 11pt,
    text(size: 30pt, weight: "bold", fill: title-color)[#title],
    line(length: 100%, stroke: 0.8pt + theme.border))
  #if subtitle != none { v(4pt); text(size: 17pt, style: "italic", fill: theme.muted)[#subtitle] }
  #v(12pt)
  #set text(size: size)
  #set par(leading: 0.6em, spacing: 0.9em)
  #set list(spacing: 0.55em)
  #body
]
#let eyebrow(body) = text(size: 11.5pt, weight: "bold", fill: theme.muted, tracking: 0.06em)[#upper(body)]
#let rd(v) = text(fill: theme.accent, weight: "bold")[#v]
#let hl = 0.6pt + theme.border
#let thin = 0.3pt + theme.border
#let uci-url = "https://archive.ics.uci.edu/dataset/502/online+retail+ii"
#let paper-url = "https://arxiv.org/abs/2604.24122"
#let blue-link(url, body) = link(url, underline(text(fill: rgb("#1a56db"), body)))
#let note(body) = align(center, text(size: 11.5pt, fill: theme.muted)[#body])
#let soft(body) = block(width: 100%, inset: 10pt, radius: 5pt, fill: theme.accent.lighten(92%), body)
#let outlined(body) = block(width: 100%, inset: 10pt, radius: 5pt, stroke: 0.7pt + theme.border, fill: white, body)

// One row of the motivation figure: a label and a time axis with one tick per purchase.
#let strip(label, ticks, color, dense: ()) = grid(
  columns: (128pt, 1fr), column-gutter: 10pt, align: horizon,
  text(size: 12pt, weight: "bold", fill: color)[#label],
  box(width: 100%, height: 20pt, {
    for (a, b) in dense {
      place(left + horizon, dx: a * 100%, rect(width: (b - a) * 100%, height: 20pt, radius: 2pt, fill: color.lighten(80%)))
    }
    place(left + horizon, line(length: 100%, stroke: 0.5pt + theme.border))
    for t in ticks {
      place(left + horizon, dx: t * 100%, rect(width: 1.5pt, height: 12pt, fill: color))
    }
  }),
)

#title-slide(
  eyebrow: [Data Mining #sym.dot.c Final project proposal],
  title: [Frequent only for a while:\ mining locally dense itemsets\ in retail transactions],
  details: [2026-11-24],
)

/*
// Compact Contents: the kit's contents-slide spacing overflows one page with ten entries.
#let toc-items = (
  chapter-entry("motivation", [Motivation]),
  chapter-entry("objective", [Objective]),
  chapter-entry("dataset", [Dataset]),
  chapter-entry("method", [Methodology]),
  sub-entry("method", [Dense windows and dense intervals]),
  sub-entry("compare", [What we compare]),
  chapter-entry("analysis", [Analysis]),
  sub-entry("analysis", [How the method answers each question]),
  sub-entry("pictures", [Two measurements in pictures]),
  chapter-entry("expected", [Expected results]),
)
#survey-slide([#contents-mark;Contents])[
  #v(1fr)
  #for item in toc-items {
    let sub = item.len() > 2
    set text(size: if sub { 13.5pt } else { 17pt }, fill: if sub { theme.muted } else { theme.text })
    grid(columns: (auto, 1fr, auto), column-gutter: 10pt, align: bottom,
      if sub [#h(24pt)#item.at(0)] else [#item.at(0)],
      box(width: 100%)[#repeat[ . ]],
      [#item.at(1)])
    v(if sub { 1pt } else { 6pt })
  }
  #v(1fr)
]
*/

// ───────────────────────── Motivation ─────────────────────────

#survey-slide([#section-mark("motivation")Motivation], subtitle: [A retailer needs to know what sells together, and when], size: 13.5pt)[
  #v(1fr)
  #grid(columns: (1fr, 1fr), column-gutter: 18pt,
    outlined[
      #eyebrow[Application scenario] \
      An online gift shop plans promotions and stock for each season. Bundles that sell only before Christmas or Mother's Day matter most, and they must be known before the season starts.
    ],
    soft[
      #eyebrow[Why frequent itemset mining is not enough] \
      Support is counted over the whole dataset. A high threshold drops seasonal bundles. A low threshold returns thousands of itemsets with no time information. This is the rare item problem.
    ])
  #v(10pt)
  #outlined[
    #eyebrow[Same global support, different knowledge (illustration, not data)]
    #v(4pt)
    #strip([Year-round pair], (0.03, 0.09, 0.14, 0.2, 0.26, 0.31, 0.37, 0.43, 0.48, 0.54, 0.6, 0.65, 0.71, 0.77, 0.82, 0.88, 0.93, 0.98), theme.muted)
    #v(2pt)
    #strip([Seasonal pair], (0.02, 0.41, 0.425, 0.44, 0.45, 0.46, 0.47, 0.485, 0.5, 0.69, 0.9, 0.915, 0.93, 0.94, 0.95, 0.96, 0.975, 0.99), theme.accent, dense: ((0.4, 0.51), (0.89, 1.0)))
    #v(2pt)
    #grid(columns: (128pt, 1fr), column-gutter: 10pt,
      [], text(size: 10.5pt, fill: theme.muted)[#box(width: 100%)[Dec 2009 #h(1fr) Dec 2010 #h(1fr) Dec 2011]])
  ]
  #v(8pt)
  #note[Both pairs have 18 purchases, so global support cannot tell them apart. Only the shaded dense intervals say when to promote the second pair.]
  #v(1fr)
]

// ───────────────────────── Objective ─────────────────────────

#survey-slide([#section-mark("objective")Objective], subtitle: [Knowledge to discover from the data], size: 13.5pt)[
  #v(1fr)
  #align(center, block(width: 94%, inset: (x: 16pt, y: 11pt), radius: 6pt, fill: theme.accent.lighten(92%), stroke: 0.7pt + theme.accent,
    text(size: 15pt, weight: "bold", fill: theme.primary)[Find the itemsets that are frequent only inside some time interval, report that interval, and explain it with the calendar.]))
  #v(10pt)
  #align(center, table(
    columns: (auto, 1.25fr, 1.25fr),
    inset: (x: 8pt, y: 6pt), align: left, stroke: (x, _) => (left: if x > 0 { thin }),
    table.hline(stroke: hl),
    table.header([], [*Question*], [*What the retailer learns*]),
    table.hline(stroke: hl),
    [*Q1* Hidden], [Which itemsets are dense in some interval but infrequent over the whole dataset?], [Bundles that ordinary market basket analysis never shows],
    table.hline(stroke: thin),
    [*Q2* When], [Do their dense intervals line up with calendar events, and do they return the next year?], [When to stock and promote each bundle],
    table.hline(stroke: thin),
    [*Q3* Scale], [How does the window size change what is found?], [Short events and long seasons need different windows],
    table.hline(stroke: hl),
  ))
  #v(8pt)
  #note[Method from #blue-link(paper-url)[Takahashi et al., arXiv:2604.24122 (2026)]. The paper tests it against promotion campaigns on grocery data. We apply it to a gift retailer and to the calendar.]
  #v(1fr)
]

// ───────────────────────── Dataset ─────────────────────────

#survey-slide([#section-mark("dataset")Dataset], subtitle: [#blue-link(uci-url)[UCI Online Retail II]], size: 13.5pt)[
  #v(1fr)
  #align(center, table(
    columns: (auto, 1fr),
    inset: (x: 8pt, y: 5.5pt), align: left, stroke: (x, _) => (left: if x > 0 { thin }),
    table.hline(stroke: hl),
    [*Source*], [UK online gift retailer, 1 Dec 2009 to 9 Dec 2011, about 1.07 M line items \ #blue-link(uci-url)[#uci-url]],
    table.hline(stroke: thin),
    [*Transaction*], [One invoice. Items are the product codes on it. Timestamp is the invoice date.],
    table.hline(stroke: thin),
    [*Cleaning*], [Remove cancelled invoices, non-product codes such as postage, and rows with no product description],
    table.hline(stroke: thin),
    [*External events*], [Christmas, Valentine's Day, UK Mother's Day, Easter, Halloween. Added by us from the calendar, with a fixed lead time before each date.],
    table.hline(stroke: thin),
    [*Why this one*], [Real timestamps. Two full years, so every event occurs twice and a seasonal pattern can be checked for recurrence.],
    table.hline(stroke: hl),
  ))
  #v(10pt)
  #grid(columns: (1fr, 1fr), column-gutter: 18pt,
    soft[
      #eyebrow[Fixed before mining] \
      The event list and the lead time are written down first, so the alignment in Q2 cannot be tuned to the result.
    ],
    outlined[
      #eyebrow[Fallback] \
      Dunnhumby Complete Journey, the dataset of the paper, with 30 labelled promotion campaigns.
    ])
  #v(1fr)
]

// ───────────────────────── Methodology ─────────────────────────

#let stage(title, body) = block(width: 100%, height: 46pt, inset: 7pt, radius: 5pt, fill: white, stroke: 0.7pt + theme.border)[
  #text(size: 12pt, weight: "bold", fill: theme.primary)[#title] \
  #text(size: 10.5pt)[#body]
]
#let arrow = align(horizon, text(size: 15pt, fill: theme.muted)[#sym.arrow.r])

// Figure helpers: everything is positioned as a fraction of the row width.
#let band(a, b, color, h: 16pt, dy: 0pt, stroke: none, body) = place(left + top, dx: a * 100%, dy: dy,
  rect(width: (b - a) * 100%, height: h, radius: 2pt, inset: 0pt, fill: color, stroke: stroke, align(center + horizon, body)))
#let marks(ts, color, h: 12pt, dy: 0pt) = for t in ts {
  place(left + top, dx: t * 100%, dy: dy, rect(width: 1.5pt, height: h, fill: color))
}
#let fig-row(label, height: 16pt, lw: 78pt, color: theme.text, body) = grid(
  columns: (lw, 1fr), column-gutter: 8pt, align: horizon,
  text(size: 10.5pt, weight: "bold", fill: color)[#label],
  box(width: 100%, height: height, body))
#let on(body) = text(size: 9pt, weight: "bold", fill: white)[#body]

// Running example of the paper: occ({a,b}) = {1,3,7,9,20,25}, W = 10, sigma = 3, dense interval [0,13].
#let window-figure = {
  let x(t) = t / 26 * 100%
  box(width: 100%, height: 120pt, {
    for t in (1, 3, 7, 9, 20, 25) {
      place(left + top, dx: x(t) - 8pt, box(width: 16pt, align(center, text(size: 9pt, fill: theme.primary, weight: "bold")[#t])))
      place(left + top, dx: x(t) - 0.75pt, dy: 12pt, rect(width: 1.5pt, height: 11pt, fill: theme.primary))
    }
    place(left + top, dy: 23pt, line(length: 100%, stroke: 0.6pt + theme.border))
    let win(l, dy, cnt, ok) = place(left + top, dx: x(l), dy: dy, rect(
      width: x(10), height: 14pt, radius: 2pt, inset: 0pt,
      fill: if ok { theme.accent.lighten(86%) } else { white },
      stroke: 0.7pt + (if ok { theme.accent } else { theme.muted }),
      align(center + horizon, text(size: 9pt, fill: if ok { theme.accent } else { theme.muted })[
        window at #l: #cnt purchases, #if ok [dense] else [not dense]])))
    win(1, 30pt, 4, true)
    win(3, 47pt, 3, true)
    win(4, 64pt, 2, false)
    win(15, 81pt, 2, false)
    place(left + top, dy: 102pt, rect(width: x(13), height: 16pt, radius: 2pt, inset: 0pt, fill: theme.accent,
      align(center + horizon, on[dense interval \[0, 13\]])))
  })
}

#survey-slide([#section-mark("method")Method: dense windows and dense intervals], subtitle: [Apriori-window counts support inside a sliding window], size: 12pt)[
  #v(1fr)
  #grid(columns: (1fr, auto, 1fr, auto, 1.15fr, auto, 1fr), column-gutter: 6pt,
    stage([Input], [Invoices as timestamped transactions]), arrow,
    stage([Parameters], [Window $W$ in days, minimum count $sigma$]), arrow,
    stage([Apriori-window], [Level-wise search, exact pruning]), arrow,
    stage([Output], [Each pattern with its dense intervals]))
  #v(8pt)
  #grid(columns: (1.3fr, 1fr), column-gutter: 14pt,
    outlined[
      #eyebrow[Example from the paper: purchases of {a, b}, $W = 10$, $sigma = 3$]
      #v(3pt)
      #window-figure
      #v(2pt)
      #text(size: 11pt)[A window is dense if it holds at least $sigma$ purchases. Joining the consecutive dense windows gives the dense interval.]
    ],
    outlined[
      #eyebrow[Scan only where every item is dense]
      #v(4pt)
      #fig-row([{b}], lw: 62pt, { band(0, 15 / 25, theme.primary.lighten(55%))[]; band(15 / 25, 1, theme.primary.lighten(55%))[] })
      #v(3pt)
      #fig-row([{c}], lw: 62pt, { band(0, 13 / 25, theme.primary.lighten(55%))[]; band(15 / 25, 1, theme.primary.lighten(55%))[] })
      #v(3pt)
      #fig-row([{b, c}], lw: 62pt, color: theme.accent, { band(0, 13 / 25, theme.accent)[#on[scan]]; band(15 / 25, 1, theme.accent)[#on[scan]] })
      #v(1pt)
      #fig-row([], lw: 62pt, height: 10pt, text(size: 9pt, fill: theme.muted)[#box(width: 100%)[0 #h(1fr) 25]])
      #v(3pt)
      #set text(size: 11pt)
      Dense intervals of {b, c} must lie inside those of {b} and of {c}, so the gap between 13 and 15 is never scanned.
      #v(2pt)
      - A superset is never denser than its subsets, so Apriori pruning holds
      - Stride-skip jumps over positions that are certainly dense
    ])
  #v(6pt)
  #note[We implement Algorithms 1 and 2 of the paper in Python, reproduce this example first, then check against brute force on a sample.]
  #v(1fr)
]

// One row of the comparison figure: how one setting counts the same purchases.
#let burst = (0.07, 0.31, 0.52, 0.7, 0.885, 0.893, 0.901, 0.908, 0.914, 0.922, 0.93, 0.938, 0.946, 0.954)
#let cmp-row(label, sub, verdict, found, body) = grid(
  columns: (118pt, 1fr, 178pt), column-gutter: 12pt, align: horizon,
  [#text(size: 13pt, weight: "bold", fill: theme.primary)[#label] \ #text(size: 10.5pt, fill: theme.muted)[#sub]],
  box(width: 100%, height: 34pt, { body; marks(burst, if found { theme.accent } else { theme.text }, h: 16pt, dy: 9pt) }),
  text(size: 12pt, weight: if found { "bold" } else { "regular" }, fill: if found { theme.accent } else { theme.text })[#verdict])

#survey-slide([#section-mark("compare")Method: what we compare], subtitle: [The same purchases of one seasonal pair, counted in three ways (illustration, not data)], size: 12.5pt)[
  #v(1fr)
  #outlined[
    #cmp-row([M0 Global], [FP-Growth on all invoices], [One count for the whole year. The burst is diluted and the pair is missed.], false,
      band(0, 1, white, h: 34pt, stroke: 0.7pt + theme.muted)[])
    #v(8pt)
    #cmp-row([M1 Monthly], [FP-Growth per calendar month], [The burst is cut at the month boundary. Each half may fall below the threshold.], false, {
      for m in range(12) {
        band(m / 12, (m + 1) / 12, if m >= 10 { theme.muted.lighten(70%) } else { white }, h: 34pt, stroke: 0.7pt + theme.muted)[]
      }
    })
    #v(8pt)
    #cmp-row([M2 Sliding window], [Apriori-window], [The whole burst fits in one window. The pair is found together with its dense interval.], true, {
      place(left + horizon, line(length: 100%, stroke: 0.6pt + theme.border))
      band(0.874, 0.962, theme.accent.lighten(82%), h: 34pt, stroke: 0.8pt + theme.accent)[]
    })
    #v(3pt)
    #grid(columns: (118pt, 1fr, 178pt), column-gutter: 12pt,
      [], grid(columns: (1fr,) * 12, align: center, ..("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec").map(m => text(size: 9.5pt, fill: theme.muted)[#m])), [])
  ]
  #v(10pt)
  #note[All three use the same support rate. M0 applies it to the whole dataset, M1 to each month, M2 to each window of $W$ = 7, 30 or 90 days.]
  #v(1fr)
]

// ───────────────────────── Methodology and analysis ─────────────────────────

#survey-slide([#section-mark("analysis")How the method answers each question], subtitle: [Every analysis reads one output of the method], size: 12.5pt)[
  #v(1fr)
  #align(center, table(
    columns: (auto, 1.05fr, 1.35fr, 1.2fr),
    inset: (x: 7pt, y: 6pt), align: left, stroke: (x, _) => (left: if x > 0 { thin }),
    table.hline(stroke: hl),
    table.header([], [*Method output used*], [*Measurement*], [*Reading*]),
    table.hline(stroke: hl),
    [*Q1* Hidden], [Dense patterns of M2 against frequent itemsets of M0], [Hidden ratio: share of dense patterns that M0 does not return], [High ratio means global mining loses real structure],
    table.hline(stroke: thin),
    [*Q2* When], [Dense intervals of each pattern against the event windows], [$R_"event"$: share of dense days that fall in an event window, compared with the share of all days that do], [Above the base rate means the pattern is tied to the event],
    table.hline(stroke: thin),
    [*Q2* Return], [Dense intervals of the same pattern in year 1 and year 2], [Share of event-tied patterns that are dense before the same event in both years], [Recurring patterns are usable for next year's plan],
    table.hline(stroke: thin),
    [*Q3* Scale], [M2 output at $W$ = 7, 30, 90 days], [Pattern count, intervals per pattern, mean interval length, share of intervals touching at most one event], [Shows which $W$ fits which planning decision],
    table.hline(stroke: thin),
    [*Check*], [Dense intervals of M2 against the monthly results of M1], [Share of dense intervals that cross a month boundary], [Cost of fixing the time partition in advance],
    table.hline(stroke: hl),
  ))
  #v(8pt)
  #note[$R_"event"$ follows the overlap ratio $R_"promo"$ of the paper, with calendar events in place of promotion campaigns.]
  #v(1fr)
]

// ───────────────────────── Measurements in pictures ─────────────────────────

#let blue = theme.primary.lighten(45%)
#let season = (0.13, 0.145, 0.16, 0.34, 0.5, 0.615, 0.63, 0.645, 0.66, 0.675, 0.74, 0.815, 0.83, 0.845, 0.86, 0.875, 0.89, 0.905)

#survey-slide([#section-mark("pictures")Analysis: two measurements in pictures], subtitle: [Illustration, not data], size: 12pt)[
  #v(1fr)
  #grid(columns: (1fr, 1fr), column-gutter: 16pt,
    outlined[
      #eyebrow[Q2: is a dense interval tied to an event?]
      #v(6pt)
      #fig-row([Event windows], lw: 86pt, color: theme.primary, { band(0.05, 0.27, blue)[#on[Valentine]]; band(0.76, 0.98, blue)[#on[Christmas]] })
      #v(4pt)
      #fig-row([Dense interval], lw: 86pt, color: theme.accent, band(0.68, 0.92, theme.accent.lighten(55%))[])
      #v(4pt)
      #fig-row([Overlap], lw: 86pt, band(0.76, 0.92, theme.accent)[])
      #v(1pt)
      #fig-row([], lw: 86pt, height: 10pt, text(size: 9pt, fill: theme.muted)[#box(width: 100%)[Jan #h(1fr) Dec]])
      #v(6pt)
      $ R_"event" = "overlap days" / "dense days" #h(18pt) "base rate" = "event days" / "all days" $
      #v(6pt)
      #text(size: 11pt)[A pattern is tied to the event only if $R_"event"$ is well above the base rate. An interval placed at random would reach the base rate by chance.]
    ],
    outlined[
      #eyebrow[Q3: what does the window size change?]
      #v(6pt)
      #fig-row([Purchases], lw: 86pt, { place(left + horizon, line(length: 100%, stroke: 0.6pt + theme.border)); marks(season, theme.text, h: 12pt, dy: 2pt) })
      #v(4pt)
      #fig-row([$W$ = 7 days], lw: 86pt, color: theme.accent, { band(0.12, 0.175, theme.accent)[]; band(0.605, 0.69, theme.accent)[]; band(0.805, 0.92, theme.accent)[] })
      #v(4pt)
      #fig-row([$W$ = 90 days], lw: 86pt, color: theme.accent, band(0.58, 0.94, theme.accent)[#on[one season]])
      #v(1pt)
      #fig-row([], lw: 86pt, height: 10pt, text(size: 9pt, fill: theme.muted)[#box(width: 100%)[Jan #h(1fr) Dec]])
      #v(6pt)
      #align(center)[$sigma$ grows with $W$, so the support rate stays the same]
      #v(6pt)
      #text(size: 11pt)[A short window gives one interval per event. A long window merges neighbouring events into a season and can lose a short isolated burst.]
    ])
  #v(1fr)
]

// ───────────────────────── Expected results ─────────────────────────

#survey-slide([#section-mark("expected")Expected results], subtitle: [Hypotheses, not measurements], size: 12.5pt)[
  #v(1fr)
  #align(center, table(
    columns: (auto, 1.4fr, 1.5fr, 1.1fr),
    inset: (x: 7pt, y: 6pt), align: left, stroke: (x, _) => (left: if x > 0 { thin }),
    table.hline(stroke: hl),
    table.header([], [*We expect*], [*Because the paper reports*], [*If it fails*]),
    table.hline(stroke: hl),
    [*Q1*], [Many dense patterns are missing from M0, mostly seasonal gift items], [Global FIM reaches F1 of at most #rd[0.035] against dense patterns on three datasets], [Report that this shop sells mostly year-round bundles],
    table.hline(stroke: thin),
    [*Q2*], [Hidden patterns score far above the base rate on $R_"event"$ and return in year 2. Year-round patterns stay near the base rate.], [Patterns found only with the short window: mean overlap 76.5% against 58.4% for the rest. Beef pairs stay at 11% to 39%.], [Look for another cause, such as a few wholesale customers],
    table.hline(stroke: thin),
    [*Q3*], [$W$ = 7 gives many short intervals around single events. $W$ = 90 merges them into seasons.], [At 47 days, 83.0% of intervals touch at most one campaign. At 141 days, 64.6% span two or more.], [Report the $W$ where the split appears],
    table.hline(stroke: hl),
  ))
  #v(10pt)
  #outlined[
    #eyebrow[What one finding will look like (format only, no real values yet)]
    #v(2pt)
    #set text(size: 12pt)
    #grid(columns: (1.2fr, 1.5fr, 1fr, 1fr, 1.3fr), column-gutter: 10pt,
      [*Pattern* \ {item A, item B}],
      [*Dense intervals* \ late Oct to mid Dec, both years],
      [*$R_"event"$* \ against base rate],
      [*Global support* \ below threshold],
      [*Action* \ bundle and stock from October])
  ]
  #v(1fr)
]

// ───────────────────────── Plan ─────────────────────────

/*
#survey-slide([Plan and deliverables], size: 13.5pt)[
  #v(1fr)
  #align(center, table(
    columns: (auto, 1.6fr, 1.2fr),
    inset: (x: 8pt, y: 6pt), align: left, stroke: (x, _) => (left: if x > 0 { thin }),
    table.hline(stroke: hl),
    table.header([], [*Work*], [*Done when*]),
    table.hline(stroke: hl),
    [*Week 1*], [Clean the data, fix the event list, run M0 and M1], [Dataset statistics table is filled],
    table.hline(stroke: thin),
    [*Week 2*], [Implement Apriori-window and verify it], [Paper example and brute force both match],
    table.hline(stroke: thin),
    [*Week 3*], [Run M2 at three window sizes, compute the five measurements], [One results table per question],
    table.hline(stroke: thin),
    [*Week 4*], [Case studies of the top hidden patterns, report and slides], [Each case has a pattern, an interval and an action],
    table.hline(stroke: hl),
  ))
  #v(10pt)
  #grid(columns: (1fr, 1fr), column-gutter: 18pt,
    soft[
      #eyebrow[Risks] \
      - Wholesale orders may create dense intervals with no seasonal meaning, so we also count distinct customers per interval
      - A pure Python implementation may be slow, so we cap pattern length at 4
    ],
    outlined[
      #eyebrow[References] \
      #set text(size: 11pt)
      - Takahashi et al., #blue-link(paper-url)[Exact Mining of Dense Patterns via Direct Evaluation of Local Interval Frequency Using a Sliding Window], arXiv:2604.24122, 2026
      - Chen, #blue-link(uci-url)[Online Retail II], UCI Machine Learning Repository
      - Han, Pei and Yin, Mining frequent patterns without candidate generation, 2000
    ])
  #v(1fr)
]
*/
