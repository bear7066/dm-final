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

#let survey-slide(title, subtitle: none, size: 17pt, title-color: theme.primary, subtitle-color: theme.muted, body) = page(fill: theme.background)[
  #pattern-layer(theme: theme)
  #stack(dir: ttb, spacing: 11pt,
    text(size: 30pt, weight: "bold", fill: title-color)[#title],
    line(length: 100%, stroke: 0.8pt + theme.border))
  #if subtitle != none { v(4pt); text(size: 17pt, style: "italic", fill: subtitle-color)[#subtitle] }
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
  title: [Topic:\ mining locally dense itemsets\ in retail transactions],
  details: [2026-11-24],
)

/*
// Compact Contents: the kit's contents-slide spacing overflows one page with ten entries.
#let toc-items = (
  chapter-entry("motivation", [Motivation]),
  chapter-entry("objective", [Goal]),
  chapter-entry("method", [Methodology]),
  sub-entry("method", [Dense windows and dense intervals]),
  sub-entry("compare", [Comparison]),
  chapter-entry("analysis", [Analysis]),
  sub-entry("analysis", [Expected Results]),
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

// Chibi-style icons: Microsoft Fluent Emoji (flat), MIT License; see final-proposal-fig/CREDITS.txt.
#let icon(name, h: 26pt) = box(image("final-proposal-fig/" + name + ".svg", height: h))
#let stage(icons, label) = align(center, stack(dir: ttb, spacing: 5pt, icons,
  text(size: 10.5pt, weight: "bold", fill: theme.primary, label)))
#let flow-arrow = text(size: 20pt, fill: theme.muted)[→]
#let season-pill(icons, label) = box(inset: (x: 7pt, y: 4pt), radius: 12pt, fill: theme.accent.lighten(90%),
  stack(dir: ltr, spacing: 5pt, icons, align(horizon, text(size: 10.5pt, weight: "bold", fill: theme.accent, label))))

// Page 2 headings: darker than the deck-wide eyebrow.
#let heading2(body, size: 13pt) = text(size: size, weight: "bold", fill: theme.primary-dark, tracking: 0.06em)[#upper(body)]

#survey-slide([#section-mark("motivation")Motivation 1], size: 13.5pt)[
  #v(1fr)
  #heading2[Plan should be applied before the season]
  #v(8pt)
  #align(center, grid(columns: 5, column-gutter: 26pt, align: center + horizon,
    stage([#icon("laptop", h: 40pt)#icon("shopping_bags", h: 34pt)], [Online gift shop]),
    flow-arrow,
    stage(stack(dir: ltr, spacing: 10pt,
      season-pill([#icon("bouquet", h: 24pt)#icon("love_letter", h: 24pt)], [Mother's Day]),
      season-pill([#icon("christmas_tree", h: 24pt)#icon("wrapped_gift", h: 24pt)], [Christmas])), [Seasonal bundles]),
    flow-arrow,
    stage([#icon("package", h: 34pt)#h(4pt)#icon("megaphone", h: 34pt)], [Stock & promote before the season])))
  #v(1fr)
  #heading2[True scenario]
  #v(8pt)
  #strip([Year-round pair], (0.03, 0.09, 0.14, 0.2, 0.26, 0.31, 0.37, 0.43, 0.48, 0.54, 0.6, 0.65, 0.71, 0.77, 0.82, 0.88, 0.93, 0.98), theme.muted)
  #v(4pt)
  #strip([Seasonal pair], (0.02, 0.41, 0.425, 0.44, 0.45, 0.46, 0.47, 0.485, 0.5, 0.69, 0.9, 0.915, 0.93, 0.94, 0.95, 0.96, 0.975, 0.99), theme.accent, dense: ((0.4, 0.51), (0.89, 1.0)))
  #v(2pt)
  #grid(columns: (128pt, 1fr), column-gutter: 10pt,
    [], text(size: 10.5pt, fill: theme.muted)[#box(width: 100%)[Dec 2009 #h(1fr) Dec 2010 #h(1fr) Dec 2011]])
  #v(1fr)
]

// Page 3 example: monthly support of one Christmas bundle (illustration, not data).
// Global support = mean of the 24 months ≈ 0.53%, below a 1% threshold, though Nov reaches 3%.
#let xmas-monthly = (0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05, 0.15, 0.5, 3.0, 2.3) * 2
#let support-chart(vals, ymax: 3.5, ch: 140pt) = {
  let n = vals.len()
  let y(v) = ch * (1 - v / ymax)
  let months = ("J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D")
  let hline(v, stroke, label, color) = {
    place(top + left, dy: y(v), line(length: 100%, stroke: stroke))
    place(top + left, dx: 4pt, dy: y(v) - 14pt, text(size: 10pt, weight: "bold", fill: color, label))
  }
  grid(columns: (26pt, 1fr), column-gutter: 4pt, row-gutter: 4pt,
    // y axis
    box(height: ch, for t in (0, 1, 2, 3) {
      place(top + right, dy: y(t) - 6pt, text(size: 9pt, fill: theme.muted)[#t%])
    }),
    box(width: 100%, height: ch, {
      for t in (1, 2, 3) { place(top + left, dy: y(t), line(length: 100%, stroke: 0.3pt + theme.border)) }
      for (i, v) in vals.enumerate() {
        let hot = v > 1
        place(bottom + left, dx: (i + 0.15) / n * 100%,
          rect(width: 0.7 / n * 100%, height: ch * v / ymax, fill: if hot { theme.accent } else { theme.border }))
        if hot {
          place(top + left, dx: i / n * 100%, dy: y(v) - 13pt,
            box(width: 1 / n * 100%, align(center, text(size: 9pt, weight: "bold", fill: theme.accent)[#v%])))
        }
      }
      place(bottom + left, line(length: 100%, stroke: 0.6pt + theme.muted))
      hline(1.0, (paint: theme.primary-dark, thickness: 1pt, dash: "dotted"), [min_sup = 1%], theme.primary-dark)
      hline(0.53, (paint: theme.accent, thickness: 1pt, dash: "dashed"), [2-year support = 0.5%], theme.accent)
    }),
    // month letters
    [],
    box(width: 100%, height: 11pt, for i in range(n) {
      let m = calc.rem(i, 12)
      let hot = vals.at(i) > 1
      place(top + left, dx: i / n * 100%, box(width: 1 / n * 100%, align(center,
        text(size: 9pt, weight: if hot { "bold" } else { "regular" }, fill: if hot { theme.accent } else { theme.muted }, months.at(m)))))
    }),
    // years
    [],
    grid(columns: (1fr, 1fr), column-gutter: 6pt,
      ..(2010, 2011).map(yr => stack(dir: ttb, spacing: 2pt,
        line(length: 100%, stroke: 0.5pt + theme.muted),
        align(center, text(size: 10pt, fill: theme.text)[#yr])))),
  )
}
#let verdict(mark, head, body) = grid(columns: (22pt, 1fr), column-gutter: 4pt, row-gutter: 3pt,
  text(size: 18pt, weight: "bold", fill: theme.accent, mark), heading2(head), [], body)

#survey-slide([Motivation 2], size: 12.5pt)[
  #heading2[Frequent itemset mining is not enough]
  #v(1fr)
  #grid(columns: (1.15fr, 1fr), column-gutter: 28pt, align: horizon,
    [
      #text(size: 14pt, weight: "bold")[#icon("wrapped_gift", h: 20pt) #icon("christmas_tree", h: 20pt) Gift + Christmas tree]
      #v(6pt)
      #support-chart(xmas-monthly)
    ],
    [
      #set par(spacing: 0.7em)
      #text(weight: "bold", fill: theme.primary-dark)[support]:  share of orders that contain the itemset.       About 50 of 10,000 orders in two years #sym.arrow #rd[0.5%].

      #text(weight: "bold", fill: theme.primary-dark)[min_sup]: only itemsets with support #sym.gt.eq min_sup are reported.

      #text(weight: "bold", fill: theme.primary-dark)[The catch:] almost all 50 orders fall in November and December. November alone reaches #rd[3%], but the other 22 months dilute it to #rd[0.5%].
      #v(6pt)
      #text(weight: "bold", fill: theme.primary-dark)[Impact: either choice ignores the bundle]
      #v(2pt)
      #verdict([✗], [High min_sup (1%)], [0.5% < 1%: the bundle is dropped, so the shop never sees it.])
      #v(6pt)
      #verdict([✗], [Low min_sup (0.1%)], [The bundle is kept, but among thousands of itemsets, and nothing says "November".])
      #v(6pt)
      #text(weight: "bold", fill: theme.primary-dark)[Idea:] use a sliding time window to find itemsets that are frequent only locally. In November the support is 3% #sym.gt.eq 1%, so the bundle is found.
    ])
  #v(1fr)
]

// ───────────────────────── Objective ─────────────────────────

#let goal-q(n, key, body) = stack(dir: ttb, spacing: 10pt,
  line(length: 100%, stroke: 1.2pt + theme.accent),
  [#text(size: 28pt, weight: "bold", fill: theme.accent)[Q#n] #h(6pt) #heading2[#key]],
  text(size: 15pt, body))

#survey-slide([#section-mark("objective")Goals], size: 13.5pt)[
  #v(6pt)
  #text(size: 20pt, weight: "bold", fill: theme.primary)[Find the itemsets that are frequent only inside some time interval, and report their relevance to the calendar or human events.]
  #v(1fr)
  #grid(columns: (1fr, 1fr, 1fr), column-gutter: 28pt,
    goal-q(1, [Hidden], [Which itemsets are dense in some interval but infrequent over the whole dataset?]),
    goal-q(2, [When], [Do their dense intervals line up with calendar events, or something else?]),
    goal-q(3, [Scale], [How does the window size change what is found? Bi-yearly? Yearly? Monthly? Weekly?]))
  #v(1fr)
  #text(size: 15pt, weight: "bold")[#blue-link(uci-url)[UCI Online Retail II]] \
  #text(size: 13.5pt)[A transaction dataset across multiple human events: Christmas, Valentine's Day, Mother's Day, ...]
  // #v(8pt)
  // #note[Method from #blue-link(paper-url)[Takahashi et al., arXiv:2604.24122 (2026)]. The paper tests it against promotion campaigns on grocery data. We apply it to a gift retailer and to the calendar.]
  #v(8pt)
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

#survey-slide([#section-mark("method")Method], subtitle: [#blue-link(paper-url)[Apriori-window counts support inside a sliding window]], size: 12pt)[
  #v(1fr)
  #grid(columns: (1fr, auto, 1fr, auto, 1.15fr, auto, 1fr), column-gutter: 6pt,
    stage([Input], [Timestamped transactions]), arrow,
    stage([Parameters], [Window $W$ in days, minimum count $sigma$]), arrow,
    stage([Apriori-window], [Level-wise search, exact pruning]), arrow,
    stage([Output], [Each pattern with its dense intervals]))
  #v(8pt)
  #grid(columns: (1.3fr, 1fr), column-gutter: 14pt,
    [
      #heading2(size: 11.5pt)[Example from the paper: purchases of {a, b}, $W = 10$, $sigma = 3$]
      #v(3pt)
      #window-figure
      #v(2pt)
      #text(size: 11pt)[A window is dense if it holds at least $sigma$ purchases. Joining the consecutive dense windows gives the dense interval.]
    ],
    [
      #heading2(size: 11.5pt)[Scan only where every item is dense]
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
  #v(1fr)
]

// One row of the comparison figure: how one setting counts the same purchases.
#let burst = (0.07, 0.31, 0.52, 0.7, 0.885, 0.893, 0.901, 0.908, 0.914, 0.922, 0.93, 0.938, 0.946, 0.954)
#let msapriori-url = "https://doi.org/10.1145/312129.312274"
#let calendar-url = "https://doi.org/10.1016/S0169-023X(02)00135-0"
#let cmp-h = 32pt
#let cmp-row(label, sub, found, body) = grid(
  columns: (200pt, 1fr), column-gutter: 16pt, align: horizon,
  [#text(size: 14pt, weight: "bold", fill: theme.primary)[#label] \ #text(size: 11pt, fill: theme.text)[#sub]],
  box(width: 100%, height: cmp-h, { body; marks(burst, if found { theme.accent } else { theme.text }, h: 16pt, dy: 8pt) }))
#let month-boxes(hot, hot-fill) = for m in range(12) {
  band(m / 12, (m + 1) / 12, if m in hot { hot-fill } else { white }, h: cmp-h, stroke: 0.7pt + theme.muted)[]
}
#survey-slide([#section-mark("compare")Comparisons], size: 12.5pt)[
  #v(1fr)
  #cmp-row([M0 Global], [FP-Growth on all invoices], false,
    band(0, 1, white, h: cmp-h, stroke: 0.7pt + theme.muted)[])
  #v(10pt)
  #cmp-row([M1 Monthly], [FP-Growth per calendar month], false, month-boxes((10, 11), theme.muted.lighten(70%)))
  #v(10pt)
  #cmp-row([M2 Sliding window], [Apriori-window], true, {
    place(left + horizon, line(length: 100%, stroke: 0.6pt + theme.border))
    band(0.874, 0.962, theme.accent.lighten(82%), h: cmp-h, stroke: 0.8pt + theme.accent)[]
  })
  #v(10pt)
  #cmp-row([M3 #blue-link(msapriori-url)[MSApriori]], [Per-item min_sup, no time], false,
    band(0, 1, theme.primary.lighten(88%), h: cmp-h, stroke: 0.7pt + theme.muted)[])
  #v(10pt)
  #cmp-row([M4 #blue-link(calendar-url)[Calendar-based rules]], [Rules that hold on a fixed calendar pattern, e.g. every December], false,
    month-boxes((10, 11), theme.primary.lighten(80%)))
  #v(3pt)
  #grid(columns: (200pt, 1fr), column-gutter: 16pt,
    [], grid(columns: (1fr,) * 12, align: center, ..("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec").map(m => text(size: 10pt, fill: theme.muted)[#m])))
  #v(1fr)
  #heading2[Extra comp.]
  #v(4pt)
  #grid(columns: (1fr, 1fr), column-gutter: 24pt,
    [*M3*: If we target the rare item problem directly, will it be enough?],
    [*M4*: are fixed calendar units enough to say #emph[when]? It can say "December", but only on units chosen in advance.])
  #v(4pt)
  #text(size: 14pt, weight: "bold", fill: theme.accent)[We want to find out if Sliding Window can find insights beyond M0/1/3/4.]
  #v(1fr)
]

// ───────────────────────── Methodology and analysis ─────────────────────────

// Q1 figure: itemsets found by M0 vs M2; the M2-only part is the hidden set.
#let q1-figure = box(width: 100%, height: 120pt, {
  let r = 56pt
  place(left + top, dx: 30pt, dy: 4pt, circle(radius: r, fill: theme.muted.lighten(80%).transparentize(20%), stroke: 0.8pt + theme.muted))
  place(left + top, dx: 100pt, dy: 4pt, circle(radius: r, fill: theme.accent.lighten(80%).transparentize(35%), stroke: 0.8pt + theme.accent))
  place(left + top, dx: 38pt, dy: 52pt, text(size: 11pt, weight: "bold", fill: theme.text)[M0])
  place(left + top, dx: 160pt, dy: 30pt, box(width: 50pt, align(center, text(size: 11pt, weight: "bold", fill: theme.accent)[M2 only \ = hidden])))
  place(left + top, dx: 166pt, dy: 66pt, [#icon("christmas_tree", h: 18pt)#icon("wrapped_gift", h: 18pt)])
  place(left + top, dx: 98pt, dy: 52pt, box(width: 30pt, align(center, text(size: 10pt, fill: theme.text)[both])))
})
// Q2 figure: Nov 1 to Dec 31; M2 interval vs the month-sized answers of M1 / M4.
#let q2-figure = {
  let x(d) = d / 61 * 100%
  let lane(label, color, body) = grid(columns: (56pt, 1fr), column-gutter: 8pt, align: horizon,
    text(size: 11pt, weight: "bold", fill: color)[#label], box(width: 100%, height: 18pt, body))
  let bar(a, b, fill, body) = place(left + top, dx: x(a), rect(width: x(b - a), height: 18pt, radius: 2pt, inset: 0pt, fill: fill, align(center + horizon, body)))
  box(width: 100%, {
    lane([Event], theme.primary-dark, {
      bar(24, 54, theme.primary.lighten(82%), text(size: 10pt, fill: theme.primary-dark)[lead-up])
      bar(54, 56, theme.primary-dark, [])
    })
    v(6pt)
    lane([M2], theme.accent, bar(19, 44, theme.accent, text(size: 10pt, weight: "bold", fill: white)[dense interval]))
    v(6pt)
    lane([M1 / M4], theme.text, {
      bar(0, 29.6, theme.muted.lighten(60%), text(size: 10pt)[November])
      bar(30.4, 61, theme.muted.lighten(60%), text(size: 10pt)[December])
    })
    v(4pt)
    grid(columns: (56pt, 1fr), column-gutter: 8pt, [],
      box(width: 100%, height: 12pt, {
        place(left + top, dx: x(0), text(size: 9.5pt, fill: theme.muted)[Nov 1])
        place(left + top, dx: x(30) - 12pt, text(size: 9.5pt, fill: theme.muted)[Dec 1])
        place(left + top, dx: x(54) - 14pt, text(size: 9.5pt, weight: "bold", fill: theme.primary-dark)[Dec 25])
      }))
  })
}
#let q-col(n, key, fig, expect, metric) = stack(dir: ttb, spacing: 10pt,
  line(length: 100%, stroke: 1.2pt + theme.accent),
  [#text(size: 24pt, weight: "bold", fill: theme.accent)[Q#n] #h(6pt) #heading2[#key]],
  fig,
  [*Expect:* #expect],
  [*Measure:* #metric])

#survey-slide([#section-mark("analysis")Expected Results], size: 13pt)[
  #v(2pt)
  #text(size: 16pt)[- 5 methods #sym.times 1 dataset #sym.times 2 questions (Q1, Q2)]
  #v(1fr)
  #grid(columns: (1fr, 1fr), column-gutter: 36pt,
    q-col(1, [Hidden], q1-figure,
      [many itemsets found by M2 are missing from M0, mostly seasonal gift bundles. M3 may recover some, but with no interval.],
      [hidden ratio = share of M2 itemsets that M0 does not return.]),
    q-col(2, [When], q2-figure,
      [M2 intervals sit in the weeks before an event. M1 and M4 can only answer "November" or "December".],
      [share of dense intervals inside an event's lead-up; share that cross a month boundary.]))
  #v(1fr)
]

// ───────────────────────── Thanks ─────────────────────────

#page(fill: theme.background)[
  #pattern-layer(theme: theme)
  #align(center + horizon, text(size: 72pt, weight: "bold", fill: theme.primary)[Thanks!])
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
