# typage-starter-typst-docs

A Typage starter for docs.rs-style Typst package documentation.

## Quick start

```sh
cargo install typage --version 0.2.1 --locked
typage init my-typst-docs \
  --starter github:rice8y/typage-starter-typst-docs \
  --install-plugins
cd my-typst-docs
```

`--install-plugins` installs `typage-plugin-typst-docs` from GitHub using Cargo.

Replace `package/` with your package sources, including `typst.toml`. Run `typage dev` to preview or `typage build` to generate the site in `public/`. Package metadata and public APIs are read automatically; do not edit generated files in `content/api/`.

## Documentation comments

Use [Tinymist-style doc comments](https://myriad-dreamin.github.io/tinymist/feature/docs.html) with Typst markup. A leading standalone `///` block documents the module; comments immediately before a binding document that symbol.

```typst
/// Components for package status displays.

/// Render a badge.
///
/// - text (content): Text displayed inside the badge.
/// - tone (str): Visual tone. Use `"info"` or `"warn"`.
/// -> content
#let badge(text, tone: "info") = [...]
```

## Source links

For GitHub repositories, `View source` uses the `repository` field in `typst.toml` and defaults to `main/package/{path}#L{line}`. Override other branches or layouts in `typage.plugins.toml`:

```toml
[plugins.typst_docs.config]
source_url_template = "https://github.com/owner/repo/blob/main/package/{path}#L{line}"
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
