#import "chrome.typ": api-modules, api-symbols, asset, breadcrumbs, docs-sidebar, footer, head, header, overview, pagination, symbol-table

#let _current-module(page, modules, page-items) = {
  let matches = modules.filter(module => module.url == page.url)
  if matches.len() > 0 {
    matches.first()
  } else if page-items.len() > 0 {
    let module-name = page-items.first().at("api_module", default: none)
    if module-name == none {
      none
    } else {
      let matches = modules.filter(module => module.name == module-name)
      if matches.len() > 0 { matches.first() } else { none }
    }
  } else {
    none
  }
}

#let _page-list(page, site) = {
  let href = path => asset(site, path)
  html.elem("ol", attrs: (class: "page-list"))[
    #for item in page.items {
      html.elem("li")[
        #html.elem("a", attrs: (class: "page-list__link", href: href(item.url)))[
          #html.elem("span", attrs: (class: "page-list__title"))[#item.title]
          #if item.description != none {
            html.elem("span", attrs: (class: "page-list__desc"))[#item.description]
          }
        ]
      ]
    }
  ]
}

#let render(site: (:), page: (:), pages: (), taxonomies: (:), body) = context {
  let symbols = api-symbols(pages)
  let modules = api-modules(symbols)
  let page-items = page.at("items", default: ())
  let current-module = _current-module(page, modules, page-items)
  let module-symbols = if current-module == none {
    ()
  } else if page-items.len() > 0 and page-items.first().at("api_module", default: none) == current-module.name {
    page-items
  } else {
    symbols.filter(item => item.at("api_module", default: none) == current-module.name)
  }
  let page-number = page.at("page_number", default: 1)
  let total-pages = page.at("total_pages", default: 1)
  let is-paginated = total-pages > 1
  if target() == "html" {
    html.elem("html", attrs: (lang: page.lang))[
      #head(site, page.title, description: page.description, canonical: page.url)
      #html.elem("body", attrs: (class: "docs-body"))[
        #header(site, show-menu: current-module != none)
        #if current-module != none {
          html.elem("main", attrs: (id: "main-content", class: "main-grid docs-page module-page"))[
            #docs-sidebar(site, modules, current: current-module.name, symbols: module-symbols)
            #html.elem("article", attrs: (class: "docs-main"))[
              #breadcrumbs(site, if is-paginated {
                (
                  (label: "API", url: "/api/"),
                  (label: current-module.name, url: current-module.url),
                  (label: "Page " + str(page-number), url: page.url),
                )
              } else {
                (
                  (label: "API", url: "/api/"),
                  (label: current-module.name, url: current-module.url),
                )
              })
              #html.elem("header", attrs: (class: "page-title docs-header"))[
                #html.elem("p", attrs: (class: "eyebrow"))[
                  #(if is-paginated { "Module page " + str(page-number) + " of " + str(total-pages) } else { "Module" })
                ]
                #html.elem("h1")[#current-module.name]
                #if page.description != none {
                  html.elem("p", attrs: (class: "lead"))[#page.description]
                }
              ]
              #html.elem("section", attrs: (class: "docs-section", id: "module-metadata"))[
                #html.elem("h2")[Module metadata]
                #html.elem("dl", attrs: (class: "facts"))[
                  #html.elem("div", attrs: (class: "fact"))[
                    #html.elem("dt")[Path]
                    #html.elem("dd")[#current-module.path]
                  ]
                  #html.elem("div", attrs: (class: "fact"))[
                    #html.elem("dt")[Public items]
                    #html.elem("dd")[#str(current-module.symbol_count)]
                  ]
                  #if current-module.at("is_entrypoint", default: false) {
                    html.elem("div", attrs: (class: "fact"))[
                      #html.elem("dt")[Role]
                      #html.elem("dd")[entrypoint]
                    ]
                  }
                ]
              ]
              #html.elem("section", attrs: (class: "docs-section", id: "public-symbols"))[
                #html.elem("h2")[
                  #(if is-paginated { "Public symbols - page " + str(page-number) } else { "Public symbols" })
                  #html.elem("span", attrs: (class: "section-count"))[#str(module-symbols.len())]
                ]
                #if module-symbols.len() == 0 {
                  html.elem("p", attrs: (class: "empty-state"))[No public symbols were found in this module.]
                } else {
                  symbol-table(module-symbols, site: site, show-module: false)
                }
                #pagination(site, page)
              ]
            ]
            #overview((
              (label: "Module metadata", href: "#module-metadata"),
              (label: "Public symbols", href: "#public-symbols"),
            ))
          ]
        } else {
          html.elem("main", attrs: (id: "main-content", class: "page-shell"))[
            #html.elem("article", attrs: (class: "page-content"))[
              #html.elem("header", attrs: (class: "page-header"))[
                #html.elem("p", attrs: (class: "eyebrow"))[#page.kind]
                #html.elem("h1")[#page.title]
                #if page.description != none {
                  html.elem("p", attrs: (class: "lead"))[#page.description]
                }
              ]
              #_page-list(page, site)
            ]
          ]
        }
        #footer(site)
      ]
    ]
  } else {
    set document(title: page.title)
    [= #page.title]
  }
}
