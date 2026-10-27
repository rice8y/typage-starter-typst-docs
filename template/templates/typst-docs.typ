#import "chrome.typ": breadcrumbs, code-block, docs-sidebar, footer, head, header, kind-label, overview

#let _source-url(page) = {
  if page.api_source_url != none {
    return page.api_source_url
  }
  if page.api_repository == none or page.api_source_path == none or page.api_source_line == none {
    return none
  }
  if not page.api_repository.starts-with("https://github.com/") {
    return none
  }
  let repository = page.api_repository
  if repository.ends-with("/") {
    repository = repository.slice(0, repository.len() - 1)
  }
  if repository.ends-with(".git") {
    repository = repository.slice(0, repository.len() - 4)
  }
  repository + "/blob/main/package/" + page.api_source_path + "#L" + str(page.api_source_line)
}

#let _source-meta(page, source-url) = html.elem("dl", attrs: (class: "source-meta"))[
  #html.elem("div")[
    #html.elem("dt")[Module]
    #html.elem("dd")[#page.api_module]
  ]
  #if page.api_source_path != none and page.api_source_line != none {
    html.elem("div")[
      #html.elem("dt")[Defined in]
      #html.elem("dd")[#(page.api_source_path + ":" + str(page.api_source_line))]
    ]
  }
  #if source-url != none {
    html.elem("div")[
      #html.elem("dt")[Source]
      #html.elem("dd")[
        #html.elem("a", attrs: (href: source-url))[View source]
      ]
    ]
  }
]

#let render(site: (:), page: (:), pages: (), taxonomies: (:), body) = context {
  let symbol-title = if page.api_symbol == none { page.api_module } else { page.api_symbol }
  let symbol-kind = if page.api_symbol_kind == none { "module" } else { page.api_symbol_kind }
  let return-type = page.at("api_return_type", default: none)
  let source-url = _source-url(page)

  if target() == "html" {
    html.elem("html", attrs: (lang: page.lang))[
      #head(site, page.title, description: page.description, canonical: page.url, generator: "typage-plugin-typst-docs")
      #html.elem("body", attrs: (class: "docs-body"))[
        #header(site)
        #html.elem("main", attrs: (id: "main-content", class: "main-grid docs-page"))[
          #docs-sidebar(site, page.api_modules, current: page.api_module, symbols: page.api_symbols, current-symbol: page.api_symbol)
          #html.elem("article", attrs: (class: "docs-main"))[
            #breadcrumbs(site, (
              (label: "API", url: page.api_root_url),
              (label: page.api_module, url: page.api_modules.filter(module => module.name == page.api_module).first().url),
            ))
            #html.elem("header", attrs: (class: "page-title docs-header"))[
              #html.elem("p", attrs: (class: "eyebrow"))[#kind-label(symbol-kind)]
              #html.elem("h1")[#symbol-title]
              #if page.api_signature != none {
                code-block(site, page.api_signature)
              }
            ]
            #html.elem("section", attrs: (class: "docs-section docs-article prose", id: "documentation"))[
              #html.elem("h2")[Overview]
              #body
            ]
            #html.elem("section", attrs: (class: "docs-section source-section", id: "source"))[
              #html.elem("h2")[Source]
              #_source-meta(page, source-url)
            ]
          ]
          #overview((
            (label: "Overview", href: "#documentation"),
            if page.api_params.len() > 0 { (label: "Parameters", href: "#parameters") } else { none },
            if return-type != none { (label: "Returns", href: "#returns") } else { none },
            (label: "Source", href: "#source"),
          ).filter(item => item != none))
        ]
        #footer(site)
      ]
    ]
  } else {
    set document(title: page.title)
    [= #page.title]
    body
  }
}
