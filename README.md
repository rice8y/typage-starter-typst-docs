# typage-starter-typst-docs

A Typage starter for docs.rs-style Typst package documentation.

This starter wires together:

- Typage static pages and templates.
- `typage-plugin-typst-docs` for extracting public Typst API docs.
- Package landing pages at `/` and `/api/` populated from `package/typst.toml`.
- Generated module and symbol reference pages below `/api/.../`.

The starter payload lives in `template/`. Typage expands the contents of that directory into the initialized project root.

## Requirements

Install Typage 0.1.5 or later from crates.io:

```sh
cargo install typage --version 0.1.5 --locked
```

Typst 0.15.0 or later is also required for HTML output.

## Create a site

Create a project directly from this public starter:

```sh
typage init my-typst-docs \
  --starter github:rice8y/typage-starter-typst-docs \
  --install-plugins
cd my-typst-docs
typage build
typage dev
```

The starter uses `typage-plugin-typst-docs` 0.1.3 from its GitHub repository. `--install-plugins` builds and installs the plugin with Cargo and writes its registration to `typage.plugins.toml` in the generated project.

## Layout

```text
.
|-- config.toml
|-- content/
|   |-- index.typ
|   `-- api.typ
|-- package/
|   |-- typst.toml
|   `-- src/
|-- templates/
|   |-- base.typ
|   |-- list.typ
|   |-- package.typ
|   |-- typst-docs.typ
|   `-- print.typ
`-- static/
    |-- mark.svg
    |-- search.js
    `-- style.css
```

The plugin generates `content/api/**` during `typage build`. Those files are marked as generated and should not be edited by hand. The starter-owned `content/index.typ` and `content/api.typ` are intentionally generic; package name, version, description, license, repository, entrypoint, module lists, and symbol lists are read from `package/typst.toml` and generated metadata.

Documentation comments follow the [Tinymist docstring convention](https://myriad-dreamin.github.io/tinymist/feature/docs.html). Use a leading standalone `///` block for module documentation and place a symbol's `///` block immediately before its binding. Parameter annotations use `- name (type): description`, return types use `-> type`, and comment bodies are Typst markup. A blank source line or regular comment ends the current doc-comment block.

```typst
/// Components for package status displays.

/// Render a badge.
///
/// - text (content): Text displayed inside the badge.
/// - tone (str): Visual tone. Use `"info"` or `"warn"`.
/// -> content
#let badge(text, tone: "info") = [...]
```

## Use your package

Replace `package/typst.toml` and `package/**/*.typ` with the package sources to document. For GitHub repositories, generated API pages link to `main/package/{path}` by default using the `repository` field in `package/typst.toml`. If the package source uses another branch or repository layout, override the URL in `typage.plugins.toml`:

```toml
[plugins.typst_docs.config]
source_url_template = "https://github.com/owner/repo/blob/main/package/{path}#L{line}"
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
