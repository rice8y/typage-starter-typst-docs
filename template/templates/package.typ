#import "chrome.typ": api-modules, api-symbols, asset, breadcrumbs, code-block, docs-sidebar, footer, head, header, overview, package-authors, package-description, package-entrypoint, package-license, package-name, package-repository, package-version, source-link, symbol-table

#let _fact(label, value) = if value != none {
  html.elem("div", attrs: (class: "fact"))[
    #html.elem("dt")[#label]
    #html.elem("dd")[#value]
  ]
} else {
  none
}

#let _install-snippet() = {
  let name = package-name()
  let version = package-version()
  if version == none {
    "#import \"@preview/" + name + ":<version>\": *"
  } else {
    "#import \"@preview/" + name + ":" + version + "\": *"
  }
}

#let render(site: (:), page: (:), pages: (), taxonomies: (:), body) = context {
  let href = path => asset(site, path)
  let symbols = api-symbols(pages)
  let modules = api-modules(symbols)
  let title = package-name()
  let description = package-description()
  let authors = package-authors()

  if target() == "html" {
    html.elem("html", attrs: (lang: page.lang))[
      #head(site, title, description: description, canonical: page.url)
      #html.elem("body", attrs: (class: "docs-body"))[
        #header(site)
        #html.elem("main", attrs: (id: "main-content", class: "main-grid package-page"))[
          #docs-sidebar(site, modules)
          #html.elem("article", attrs: (class: "docs-main package-main"))[
            #html.elem("header", attrs: (class: "page-title package-hero"))[
              #html.elem("p", attrs: (class: "eyebrow"))[Typst package]
              #html.elem("h1")[#title]
              #html.elem("p", attrs: (class: "lead"))[#description]
              #html.elem("div", attrs: (class: "page-actions"))[
                #if modules.len() > 0 {
                  html.elem("a", attrs: (class: "nav-button nav-button--primary", href: href(modules.first().url)))[API reference]
                }
                #source-link(package-repository())
              ]
            ]
            #html.elem("section", attrs: (class: "docs-section", id: "install"))[
              #html.elem("h2")[Import]
              #code-block(site, _install-snippet())
            ]
            #html.elem("section", attrs: (class: "docs-section", id: "modules"))[
              #html.elem("h2")[
                Modules
                #html.elem("span", attrs: (class: "section-count"))[#str(modules.len())]
              ]
              #if modules.len() == 0 {
                html.elem("p", attrs: (class: "empty-state"))[No public modules were generated yet.]
              } else {
                html.elem("div", attrs: (class: "module-cards"))[
                  #for module in modules {
                    html.elem("a", attrs: (class: "module-card", href: href(module.url)))[
                      #html.elem("strong")[#module.name]
                      #html.elem("span")[
                        #if module.at("is_entrypoint", default: false) {
                          html.elem("span", attrs: (class: "module-link__badge"))[entrypoint]
                        }
                        #html.elem("span")[#(str(module.symbol_count) + " symbols")]
                      ]
                      #html.elem("span", attrs: (class: "module-card__arrow", aria-hidden: "true"))[→]
                    ]
                  }
                ]
              }
            ]
            #html.elem("section", attrs: (class: "docs-section", id: "public-api"))[
              #html.elem("h2")[
                Public API
                #html.elem("span", attrs: (class: "section-count"))[#str(symbols.len())]
              ]
              #if symbols.len() == 0 {
                html.elem("p", attrs: (class: "empty-state"))[No public symbols were found. Add documented top-level `#let` bindings to the Typst package.]
              } else {
                symbol-table(symbols, site: site, show-module: modules.len() > 1)
              }
            ]
            #html.elem("section", attrs: (class: "docs-section", id: "package-metadata"))[
              #html.elem("h2")[Package information]
              #html.elem("dl", attrs: (class: "facts"))[
                #_fact("Version", package-version())
                #_fact(if authors.len() == 1 { "Author" } else { "Authors" }, if authors.len() > 0 {
                  html.elem("span", attrs: (class: "package-authors"))[#authors.join(", ")]
                } else { none })
                #_fact("License", package-license())
                #_fact("Entrypoint", package-entrypoint())
                #_fact("Repository", source-link(package-repository(), label: package-repository()))
              ]
            ]
          ]
          #overview((
            (label: "Import", href: "#install"),
            (label: "Modules", href: "#modules"),
            (label: "Public API", href: "#public-api"),
            (label: "Package information", href: "#package-metadata"),
          ))
        ]
        #footer(site)
      ]
    ]
  } else {
    set document(title: title)
    [= #title]
    body
  }
}
