//! Public entrypoint for the sample package.
//!
//! The docs plugin reads top-level module comments, public `#let` bindings,
//! and simple re-exports from this file.

/// Layout helpers re-exported from `layout.typ`.
#import "layout.typ": card, stack

/// Color tokens re-exported from `theme.typ`.
#import "theme.typ": palette, brand-color

/// Current package version.
#let version = "0.1.0"

/// Draw a compact status badge.
///
/// The badge is useful for labels such as experimental, stable, or deprecated.
///
/// - `text`: Text displayed inside the badge.
/// - tone (str): Visual tone. Use `"info"` or `"warn"`.
#let badge(text, tone: "info") = box(
  inset: (x: 0.42em, y: 0.14em),
  radius: 3pt,
  fill: if tone == "warn" { orange.lighten(78%) } else { aqua.lighten(80%) },
  text(size: 0.82em, weight: "medium", text),
)

/// Render a note block with a title.
///
/// - `title`: Short heading displayed above the note body.
/// - `body`: Content rendered inside the note.
/// - tone (str): Visual tone. Use `"info"` or `"warn"`.
#let note(title, body, tone: "info") = block(
  inset: 10pt,
  radius: 4pt,
  fill: if tone == "warn" { orange.lighten(92%) } else { luma(245) },
)[
  *#title* \
  #body
]
