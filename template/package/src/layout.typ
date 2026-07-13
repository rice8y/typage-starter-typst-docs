/// Reusable layout helpers.

/// Render a bordered card.
///
/// - title (content): Heading displayed at the top of the card.
/// - body (content): Content rendered below the heading.
/// -> content
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
/// - children (arguments): Content values to stack.
/// -> content
#let stack(gap: 0.65em, ..children) = {
  let items = children.pos()
  for item in items [
    #item
    #v(gap)
  ]
}
