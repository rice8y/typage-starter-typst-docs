//! Reusable layout helpers.

/// Render a bordered card.
///
/// - `title`: Heading displayed at the top of the card.
/// - `body`: Content rendered below the heading.
#let card(title, body) = block(
  inset: 12pt,
  radius: 4pt,
  stroke: 0.6pt + luma(190),
)[
  *#title*

  #body
]

/// Stack child content with a configurable gap.
///
/// - gap (length): Vertical space between adjacent children.
/// - `children`: Content values to stack.
#let stack(gap: 0.65em, ..children) = {
  let items = children.pos()
  for item in items [
    #item
    #v(gap)
  ]
}
