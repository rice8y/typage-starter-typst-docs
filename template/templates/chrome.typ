#let asset(site, path) = if site.base_url == "" { path } else { site.base_url + path }

#let package-manifest() = toml("../package/typst.toml").package

#let package-field(name, fallback: none) = package-manifest().at(name, default: fallback)

#let package-name() = package-field("name", fallback: "package")

#let package-version() = package-field("version")

#let package-description() = package-field("description", fallback: "Typst package documentation.")

#let package-repository() = package-field("repository")

#let package-license() = package-field("license")

#let package-entrypoint() = package-field("entrypoint", fallback: "src/lib.typ")

#let page-title(site, title) = if title == none or title == site.title {
  site.title
} else {
  title + " | " + site.title
}

#let icon(site, name, class: "icon", alt: "", size: 18) = html.elem("img", attrs: (
  class: class,
  src: asset(site, "/icons/" + name + ".svg"),
  alt: alt,
  width: str(size),
  height: str(size),
))

#let head(site, title, description: none, canonical: none, generator: "typage") = {
  let href = path => asset(site, path)
  html.elem("head")[
    #html.elem("meta", attrs: (charset: "utf-8"))
    #html.elem("meta", attrs: (name: "viewport", content: "width=device-width, initial-scale=1"))
    #html.elem("meta", attrs: (name: "generator", content: generator))
    #html.elem("meta", attrs: (name: "typage-base-url", content: site.base_url))
    #html.elem("meta", attrs: (name: "theme-color", content: "#ffffff"))
    #if description != none {
      html.elem("meta", attrs: (name: "description", content: description))
    }
    #html.elem("title")[#page-title(site, title)]
    #if canonical != none {
      html.elem("link", attrs: (rel: "canonical", href: href(canonical)))
    }
    #html.elem("link", attrs: (rel: "icon", href: href("/mark.svg"), type: "image/svg+xml"))
    #html.elem("link", attrs: (rel: "stylesheet", href: href("/style.css")))
    #html.elem("script", attrs: (src: href("/search.js"), defer: "defer"))
  ]
}

#let search-box(site) = html.elem("form", attrs: (
  class: "doc-search",
  role: "search",
  data-doc-search: "",
))[
  #html.elem("label", attrs: (class: "visually-hidden", "for": "doc-search-input"))[Search documentation]
  #html.elem("div", attrs: (class: "doc-search__field"))[
    #icon(site, "search", class: "doc-search__icon", size: 16)
    #html.elem("input", attrs: (
      id: "doc-search-input",
      name: "q",
      type: "search",
      role: "combobox",
      placeholder: "Search documentation",
      autocomplete: "off",
      autocapitalize: "none",
      spellcheck: "false",
      aria-autocomplete: "list",
      aria-controls: "doc-search-results",
      aria-expanded: "false",
      data-doc-search-input: "",
    ))
  ]
  #html.elem("div", attrs: (
    id: "doc-search-results",
    class: "doc-search-results",
    role: "listbox",
    aria-label: "Search results",
    data-doc-search-results: "",
    hidden: "hidden",
  ))[]
  #html.elem("div", attrs: (
    class: "visually-hidden",
    aria-live: "polite",
    aria-atomic: "true",
    data-doc-search-status: "",
  ))[]
]

#let header(site, show-menu: true) = {
  let href = path => asset(site, path)
  html.elem("a", attrs: (class: "skip-link", href: "#main-content"))[Skip to content]
  html.elem("header", attrs: (class: "site-header"))[
    #html.elem("div", attrs: (class: "site-header__inner"))[
      #html.elem("a", attrs: (class: "brand", href: href("/api/")))[
        #html.elem("span", attrs: (class: "brand__name"))[#package-name()]
        #if package-version() != none {
          html.elem("span", attrs: (class: "brand__version"))[#package-version()]
        }
      ]
      #if show-menu {
        html.elem("button", attrs: (
          class: "mobile-nav-toggle",
          type: "button",
          aria-controls: "docs-sidebar",
          aria-expanded: "false",
          data-doc-nav-toggle: "",
        ))[
          #html.elem("span")[Browse]
        ]
      }
    ]
  ]
  if show-menu {
    html.elem("div", attrs: (class: "doc-nav-scrim", data-doc-nav-scrim: "", aria-hidden: "true"))[]
  }
}

#let footer(site) = html.elem("footer", attrs: (class: "site-footer"))[
  #html.elem("div", attrs: (class: "site-footer__inner"))[
    #html.elem("a", attrs: (href: "https://github.com/rice8y/typage"))[Built with Typage]
  ]
]

#let breadcrumbs(site, items) = {
  let href = path => asset(site, path)
  html.elem("nav", attrs: (class: "breadcrumbs", aria-label: "Breadcrumbs"))[
    #html.elem("a", attrs: (class: "breadcrumbs__root", href: href("/api/")))[#package-name()]
    #for item in items {
      if item.url != "/api/" {
        html.elem("span", attrs: (class: "breadcrumbs__sep", aria-hidden: "true"))[›]
        html.elem("a", attrs: (href: href(item.url)))[#item.label]
      }
    }
  ]
}

#let kind-label(kind) = if kind == none {
  "module"
} else if kind == "reexport" {
  "re-export"
} else {
  kind
}

#let kind-pill(kind) = html.elem("span", attrs: (class: "pill pill--" + kind-label(kind).replace(" ", "-")))[#kind-label(kind)]

#let symbol-name(symbol) = if "api_symbol" in symbol {
  symbol.api_symbol
} else if "name" in symbol {
  symbol.name
} else if "title" in symbol {
  symbol.title
} else {
  "item"
}

#let symbol-kind(symbol) = if "api_symbol_kind" in symbol {
  symbol.api_symbol_kind
} else if "kind" in symbol {
  symbol.kind
} else {
  "item"
}

#let overview(items) = html.elem("aside", attrs: (id: "page-overview", aria-label: "On this page"))[
  #html.elem("strong")[On this page]
  #html.elem("ul")[
    #for item in items {
      html.elem("li")[
        #html.elem("a", attrs: (href: item.href))[#item.label]
      ]
    }
  ]
]

#let api-symbols(pages) = pages.filter(item => item.at("api_kind", default: none) == "symbol")

#let public-modules(modules) = modules.filter(module => module.at("symbol_count", default: 0) > 0)

#let api-modules(symbols) = if symbols.len() > 0 {
  public-modules(symbols.first().at("api_modules", default: ()))
} else {
  ()
}

#let module-list(modules, current: none, site: (:)) = {
  let href = path => asset(site, path)
  html.elem("nav", attrs: (class: "module-list", aria-label: "Modules"))[
    #for module in public-modules(modules) {
      let is-current = current != none and module.name == current
      html.elem("a", attrs: (
        href: href(module.url),
        class: if is-current { "module-link is-current" } else { "module-link" },
        ..if is-current { (aria-current: "page",) } else { (:) },
      ))[
        #html.elem("span", attrs: (class: "module-link__name"))[#module.name]
        #html.elem("span", attrs: (class: "module-link__meta"))[
          #if module.at("is_entrypoint", default: false) {
            html.elem("span", attrs: (class: "module-link__badge"))[entrypoint]
          }
          #html.elem("span")[#(str(module.symbol_count) + " items")]
        ]
      ]
    }
  ]
}

#let symbol-table(symbols, site: (:), show-module: true) = {
  let href = path => asset(site, path)
  html.elem("div", attrs: (class: "symbol-table", role: "list"))[
    #for symbol in symbols {
      html.elem("a", attrs: (href: href(symbol.url), class: "symbol-row", role: "listitem"))[
        #kind-pill(symbol-kind(symbol))
        #html.elem("span", attrs: (class: "symbol-name"))[#symbol-name(symbol)]
        #if show-module {
          html.elem("span", attrs: (class: "symbol-module"))[#symbol.at("api_module", default: "")]
        }
        #html.elem("span", attrs: (class: "symbol-summary"))[
          #symbol.at("description", default: symbol.at("summary", default: ""))
        ]
      ]
    }
  ]
}

#let source-link(url) = if url != none {
  html.elem("a", attrs: (class: "nav-button source-link", href: url))[Repository]
} else {
  none
}

#let code-block(site, source, lang: "typst") = html.elem("div", attrs: (class: "code-block", data-code-block: ""))[
  #html.elem("pre", attrs: (class: "code-definition"))[
    #if lang == none {
      html.elem("code")[#source]
    } else {
      raw(source, lang: lang)
    }
  ]
  #html.elem("button", attrs: (
    class: "copy-button",
    type: "button",
    title: "Copy code",
    aria-label: "Copy code",
    data-copy-button: "",
  ))[
    #icon(site, "copy", class: "copy-button__icon copy-button__icon--copy", size: 15)
    #icon(site, "check", class: "copy-button__icon copy-button__icon--check", size: 15)
    #html.elem("span", attrs: (data-copy-label: ""))[Copy]
  ]
]

#let pagination(site, page) = {
  let prev = page.at("prev", default: none)
  let next = page.at("next", default: none)
  let current = page.at("page_number", default: 1)
  let total = page.at("total_pages", default: 1)
  if total > 1 {
    html.elem("nav", attrs: (class: "pagination", aria-label: "Pagination"))[
      #if prev != none {
        html.elem("a", attrs: (class: "pagination__button", href: asset(site, prev.url), rel: "prev"))[← Previous]
      } else {
        html.elem("span", attrs: (class: "pagination__button is-disabled", aria-disabled: "true"))[← Previous]
      }
      #html.elem("span", attrs: (class: "pagination__status", aria-current: "page"))[
        #(str(current) + " of " + str(total))
      ]
      #if next != none {
        html.elem("a", attrs: (class: "pagination__button", href: asset(site, next.url), rel: "next"))[Next →]
      } else {
        html.elem("span", attrs: (class: "pagination__button is-disabled", aria-disabled: "true"))[Next →]
      }
    ]
  }
}

#let docs-sidebar(site, modules, current: none, symbols: (), current-symbol: none) = html.elem(
  "aside",
  attrs: (
    id: "docs-sidebar",
    class: "docs-sidebar folding",
    aria-label: "Documentation navigation",
    data-doc-nav: "",
  ),
)[
  #html.elem("div", attrs: (class: "sidebar-heading"))[
    #html.elem("div", attrs: (class: "sidebar-identity"))[
      #html.elem("span", attrs: (class: "sidebar-title"))[Documentation]
    ]
    #html.elem("button", attrs: (
      class: "sidebar-close",
      type: "button",
      title: "Close navigation",
      aria-label: "Close navigation",
      data-doc-nav-close: "",
    ))[
      #icon(site, "x", size: 18)
    ]
  ]
  #search-box(site)
  #html.elem("a", attrs: (
    class: if current == none { "sidebar-overview is-current" } else { "sidebar-overview" },
    href: asset(site, "/api/"),
    ..if current == none { (aria-current: "page",) } else { (:) },
  ))[Overview]
  #html.elem("p", attrs: (class: "sidebar-category"))[Modules]
  #module-list(modules, current: current, site: site)
  #if symbols.len() > 0 {
    html.elem("p", attrs: (class: "sidebar-category sidebar-category--symbols"))[Symbols]
    html.elem("nav", attrs: (class: "symbol-nav", aria-label: "Symbols in module"))[
      #for symbol in symbols.sorted(key: symbol => symbol-name(symbol)) {
        let name = symbol-name(symbol)
        let kind = symbol-kind(symbol)
        let is-current = current-symbol != none and current-symbol == name
        html.elem("a", attrs: (
          href: asset(site, symbol.url),
          title: kind-label(kind) + " " + name,
          class: if is-current { "is-current" } else { "" },
          ..if is-current { (aria-current: "page",) } else { (:) },
        ))[
          #html.elem("span")[#name]
        ]
      }
    ]
  }
]
