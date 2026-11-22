// Color themes for the reusable CP2 slide kit.
// Add a new theme by copying one record and changing only its colors.

#let classic-blue = (
  name: "Classic Blue",
  primary: rgb("#0071c5"),
  primary-dark: rgb("#004f8b"),
  accent: rgb("#d63384"),
  background: white,
  surface: rgb("#f0f8ff"),
  code-background: rgb("#f5f7fa"),
  text: rgb("#555555"),
  muted: rgb("#888888"),
  border: rgb("#b8d9ee"),
  on-primary: white,
)

#let forest-teal = (
  name: "Forest Teal",
  pattern: "dot-grid",
  pattern-color: rgb("#2f7f77"),
  primary: rgb("#0f766e"),
  primary-dark: rgb("#115e59"),
  accent: rgb("#c2410c"),
  background: rgb("#fcfdfc"),
  surface: rgb("#ecfdf5"),
  code-background: rgb("#f3f8f6"),
  text: rgb("#3f514e"),
  muted: rgb("#73827f"),
  border: rgb("#a7d8ce"),
  on-primary: white,
)

#let plum-berry = (
  name: "Plum Berry",
  primary: rgb("#7e3a8a"),
  primary-dark: rgb("#5b2765"),
  accent: rgb("#c24162"),
  background: rgb("#fffdfd"),
  surface: rgb("#fbf0f8"),
  code-background: rgb("#faf5f8"),
  text: rgb("#554b55"),
  muted: rgb("#887d88"),
  border: rgb("#ddbed7"),
  on-primary: white,
)

// Patterned variants reuse the existing visual language and color families.
#let blueprint-dots = (
  name: "Blueprint Dots",
  pattern: "dot-grid",
  primary: rgb("#0071c5"),
  primary-dark: rgb("#004f8b"),
  accent: rgb("#d63384"),
  background: rgb("#fbfdff"),
  surface: rgb("#eef7ff"),
  code-background: rgb("#f3f7fb"),
  text: rgb("#4f5963"),
  muted: rgb("#7b8792"),
  border: rgb("#a9d2ec"),
  on-primary: white,
)

#let zen-moss-dots = (
  name: "Zen Moss Dots",
  pattern: "dot-grid",
  pattern-color: rgb("#6f7b66"),
  primary: rgb("#66725f"),
  primary-dark: rgb("#465044"),
  accent: rgb("#a37755"),
  background: rgb("#f7f4eb"),
  surface: rgb("#e9ede4"),
  code-background: rgb("#efeee8"),
  text: rgb("#484c45"),
  muted: rgb("#777c73"),
  border: rgb("#c8cec0"),
  on-primary: rgb("#fffdf7"),
)

#let zen-ink-dots = (
  name: "Zen Ink Dots",
  pattern: "dot-grid",
  pattern-color: rgb("#5f6d70"),
  primary: rgb("#536469"),
  primary-dark: rgb("#37464a"),
  accent: rgb("#a66f52"),
  background: rgb("#f4f1e9"),
  surface: rgb("#e6ebe8"),
  code-background: rgb("#ebede9"),
  text: rgb("#454a4a"),
  muted: rgb("#747b7a"),
  border: rgb("#c4ccca"),
  on-primary: rgb("#fffdf7"),
)

#let plum-ripples = (
  name: "Plum Ripples",
  pattern: "ripples",
  primary: rgb("#7e3a8a"),
  primary-dark: rgb("#5b2765"),
  accent: rgb("#0f766e"),
  background: rgb("#fffdfd"),
  surface: rgb("#fbf0f8"),
  code-background: rgb("#faf5f8"),
  text: rgb("#554b55"),
  muted: rgb("#887d88"),
  border: rgb("#ddbed7"),
  on-primary: white,
)

#let solar-coral = (
  name: "Solar Coral",
  pattern: "sun-rays",
  pattern-color: rgb("#f4b942"),
  primary: rgb("#e55332"),
  primary-dark: rgb("#ad351f"),
  accent: rgb("#f4a51c"),
  background: rgb("#fffaf3"),
  surface: rgb("#fff0df"),
  code-background: rgb("#fff5e9"),
  text: rgb("#59463e"),
  muted: rgb("#8a756b"),
  border: rgb("#efc5a6"),
  on-primary: white,
)

#let zen-sage = (
  name: "Zen Sage",
  pattern: "zen-orbits",
  primary: rgb("#526b5b"),
  primary-dark: rgb("#35493c"),
  accent: rgb("#b57a55"),
  background: rgb("#f7f4ea"),
  surface: rgb("#ecefe6"),
  code-background: rgb("#f0eee6"),
  text: rgb("#4c5049"),
  muted: rgb("#7d8179"),
  border: rgb("#c7cec2"),
  on-primary: rgb("#fffdf5"),
)

// Additional dot-grid color variants.
#let terracotta-dots = (
  name: "Terracotta Dots",
  pattern: "dot-grid",
  pattern-color: rgb("#9c5a3c"),
  primary: rgb("#b0553a"),
  primary-dark: rgb("#7f3a26"),
  accent: rgb("#3f7a74"),
  background: rgb("#fbf6ef"),
  surface: rgb("#f6e7db"),
  code-background: rgb("#f5eee6"),
  text: rgb("#503f37"),
  muted: rgb("#86736a"),
  border: rgb("#e3c4b0"),
  on-primary: rgb("#fffaf3"),
)

#let indigo-lavender-dots = (
  name: "Indigo Lavender Dots",
  pattern: "dot-grid",
  pattern-color: rgb("#5a5c9c"),
  primary: rgb("#4b4f96"),
  primary-dark: rgb("#33366d"),
  accent: rgb("#c0567a"),
  background: rgb("#faf9fd"),
  surface: rgb("#eeedf8"),
  code-background: rgb("#f3f2f8"),
  text: rgb("#4a4a5c"),
  muted: rgb("#7d7d92"),
  border: rgb("#c9c8e6"),
  on-primary: white,
)

#let charcoal-mustard-dots = (
  name: "Charcoal Mustard Dots",
  pattern: "dot-grid",
  pattern-color: rgb("#4a4f55"),
  primary: rgb("#3d4349"),
  primary-dark: rgb("#262a2f"),
  accent: rgb("#c9921c"),
  background: rgb("#fafaf7"),
  surface: rgb("#f1efe6"),
  code-background: rgb("#f2f2ef"),
  text: rgb("#44484c"),
  muted: rgb("#7a7f84"),
  border: rgb("#d2d3cd"),
  on-primary: rgb("#fdfbf4"),
)

// Additional blue dot-grid variants.
#let navy-ink-dots = (
  name: "Navy Ink Dots",
  pattern: "dot-grid",
  pattern-color: rgb("#3d5f96"),
  primary: rgb("#1f4788"),
  primary-dark: rgb("#14305f"),
  accent: rgb("#d4692f"),
  background: rgb("#f9fbfe"),
  surface: rgb("#e9f0f9"),
  code-background: rgb("#f1f4f9"),
  text: rgb("#414b5a"),
  muted: rgb("#76839a"),
  border: rgb("#bccde6"),
  on-primary: white,
)

#let steel-blue-dots = (
  name: "Steel Blue Dots",
  pattern: "dot-grid",
  pattern-color: rgb("#5c82ad"),
  primary: rgb("#3f6fa3"),
  primary-dark: rgb("#2a5078"),
  accent: rgb("#c0567a"),
  background: rgb("#f9fbfd"),
  surface: rgb("#ebf2f8"),
  code-background: rgb("#f2f5f8"),
  text: rgb("#4a5360"),
  muted: rgb("#7c8896"),
  border: rgb("#c3d5e6"),
  on-primary: white,
)
