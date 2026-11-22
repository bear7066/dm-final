// Reusable layout and teaching components for CP2 slides.
// Each public component accepts `theme:` so a template can bind its theme once.

#import "patterns.typ": pattern-layer
#import "nav.typ": *

#let deck(theme: none, body) = {
  set page(
    paper: "presentation-16-9",
    margin: (x: 42pt, y: 30pt),
    fill: theme.background,
    numbering: "1",
    number-align: right + bottom,
  )
  set text(size: 22pt, fill: theme.text)
  set par(leading: 0.72em)
  show heading.where(level: 2): it => text(
    size: 23pt,
    weight: "bold",
    fill: theme.primary,
  )[#it.body]
  show raw.where(block: true): it => block(
    width: 100%,
    inset: 10pt,
    radius: 5pt,
    fill: theme.code-background,
    stroke: 0.6pt + theme.border,
  )[
    #set text(size: 15pt)
    #it
  ]
  body
}

#let slide-heading(theme: none, title: none) = {
  text(size: 30pt, weight: "bold", fill: theme.primary)[#title]
  v(0.08em)
  line(length: 100%, stroke: 0.8pt + theme.border)
}

#let title-slide(
  theme: none,
  course: none,
  title: none,
  details: none,
  eyebrow: none,
) = page(numbering: none, fill: theme.background)[
  #pattern-layer(theme: theme)
  #align(left + horizon)[
    #if eyebrow != none {
      text(size: 16pt, weight: "bold", fill: theme.accent)[#eyebrow]
      v(0.7em)
    }
    #text(size: 44pt, weight: "bold", fill: theme.primary)[#course]
    #v(0.25em)
    #text(size: 31pt, fill: theme.text)[#title]
    #v(0.6em)
    #text(size: 23pt, fill: theme.text)[#details]
  ]
]

// Items: chapter-entry(key, name) / sub-entry(key, name) link to their section; plain (name, page) still works.
#let contents-slide(theme: none, items: (), title: [Contents]) = page(fill: theme.background)[
  #contents-mark
  #pattern-layer(theme: theme)
  #slide-heading(theme: theme, title: title)
  #v(0.7em)
  #for item in items {
    let sub = _is-sub(item)
    set text(size: if sub { 17pt } else { 21pt })
    grid(
      columns: (auto, 1fr, auto),
      column-gutter: 10pt,
      align: bottom,
      if sub [#h(26pt)#item.at(0)] else [#item.at(0)],
      box(width: 100%)[#repeat[ . ]],
      [#item.at(1)],
    )
    v(if sub { 4pt } else { 11pt })
  }
]

// key: the target of chapter-entry(key, ...); the title and the corner mark link back to the Contents.
#let section-slide(theme: none, title: none, subtitle: none, key: none) = page(
  numbering: none,
  fill: theme.primary,
)[
  #if key != none { section-mark(key) }
  #pattern-layer(theme: theme, on-primary: true)
  #place(bottom + left)[#back-to-contents[#text(size: 12pt, fill: theme.on-primary.transparentize(25%))[#sym.arrow.l Contents]]]
  #align(center + horizon)[
    #back-to-contents[#text(size: 49pt, weight: "bold", fill: theme.on-primary)[#title]]
    #if subtitle != none {
      v(0.5em)
      text(size: 22pt, fill: theme.on-primary)[#subtitle]
    }
  ]
]

#let content-slide(theme: none, title: none, subtitle: none, body) = page(fill: theme.background)[
  #pattern-layer(theme: theme)
  #slide-heading(theme: theme, title: title)
  #if subtitle != none {
    v(0.15em)
    text(size: 19pt, style: "italic", fill: theme.muted)[#subtitle]
  }
  #v(0.65em)
  #body
]

#let two-columns(left, right, ratio: (1fr, 1fr), gutter: 24pt) = grid(
  columns: ratio,
  column-gutter: gutter,
  align: top,
  left,
  right,
)

#let callout(theme: none, title: none, kind: "primary", body) = {
  let color = if kind == "accent" { theme.accent } else { theme.primary }
  box(
    width: 100%,
    inset: 12pt,
    radius: 5pt,
    fill: theme.surface,
    stroke: (left: 4pt + color, rest: 0.6pt + theme.border),
  )[
    #if title != none {
      text(size: 18pt, weight: "bold", fill: color)[#title]
      v(0.25em)
    }
    #set text(size: 17pt)
    #body
  ]
}

#let card(theme: none, title: none, body) = box(
  width: 100%,
  inset: 12pt,
  radius: 5pt,
  fill: theme.background,
  stroke: 0.8pt + theme.border,
)[
  #text(size: 19pt, weight: "bold", fill: theme.primary)[#title]
  #v(0.35em)
  #set text(size: 17pt)
  #body
]

#let quiz-slide(theme: none, number: none, question: none, choices: (), answer: none) = content-slide(
  theme: theme,
  title: [Question #number],
  subtitle: if answer == none { none } else { [Answer: #answer] },
)[
  #text(size: 20pt, weight: "bold")[#question]
  #v(0.7em)
  #set text(size: 18pt)
  #for choice in choices {
    box(
      width: 100%,
      inset: (x: 12pt, y: 7pt),
      radius: 4pt,
      fill: if answer != none and choice.at(0) == answer { theme.surface } else { none },
      stroke: if answer != none and choice.at(0) == answer {
        1pt + theme.primary
      } else {
        0.6pt + theme.border
      },
    )[
      #text(weight: "bold", fill: theme.primary)[#choice.at(0).] #choice.at(1)
    ]
    v(7pt)
  }
]
