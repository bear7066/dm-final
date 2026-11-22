// Decorative patterns used by the patterned themes.
// They are placed behind slide content and do not affect layout.

#let pattern-layer(theme: none, on-primary: false) = {
  let kind = theme.at("pattern", default: "none")
  let base-color = theme.at("pattern-color", default: theme.primary)
  let color = if on-primary {
    white.transparentize(79%)
  } else {
    base-color.transparentize(90%)
  }

  if kind == "dot-grid" {
    for x in range(0, 37) {
      for y in range(0, 20) {
        place(
          top + left,
          dx: x * 24pt - 6pt,
          dy: y * 24pt - 6pt,
          circle(radius: 0.9pt, fill: color),
        )
      }
    }
  } else if kind == "ripples" {
    for index in range(1, 10) {
      let radius = index * 25pt
      place(
        top + right,
        dx: 48pt,
        dy: -38pt,
        circle(radius: radius, stroke: 1.1pt + color),
      )
      place(
        bottom + left,
        dx: -35pt,
        dy: 38pt,
        circle(radius: radius, stroke: 1.1pt + color),
      )
    }
  } else if kind == "sun-rays" {
    for index in range(0, 18) {
      place(
        top + right,
        dx: 36pt,
        dy: -24pt,
        line(
          length: 390pt,
          angle: 96deg + index * 10deg,
          stroke: 3pt + color,
        ),
      )
    }
    place(
      top + right,
      dx: 36pt,
      dy: -24pt,
      circle(radius: 28pt, fill: color),
    )
  } else if kind == "zen-orbits" {
    for radius in (52pt, 105pt, 172pt) {
      place(
        top + right,
        dx: 28pt,
        dy: -22pt,
        circle(radius: radius, stroke: 1.2pt + color),
      )
    }
    place(
      bottom + left,
      dx: -18pt,
      dy: 22pt,
      circle(radius: 92pt, stroke: 1.2pt + color),
    )
    place(
      bottom + left,
      dx: 42pt,
      dy: -38pt,
      circle(radius: 5pt, fill: color),
    )
  }
}
