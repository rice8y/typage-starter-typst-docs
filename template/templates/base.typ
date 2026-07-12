#import "chrome.typ": asset, footer, head, header

#let _toc(page) = if page.toc.len() > 0 {
  html.elem("nav", attrs: (class: "toc", aria-label: "Table of contents"))[
    #html.elem("strong")[Contents]
    #html.elem("ol")[
      #for item in page.toc {
        html.elem("li", attrs: (class: "toc-level-" + str(item.level)))[
          #html.elem("a", attrs: (href: "#" + item.id))[#item.text]
        ]
      }
    ]
  ]
} else {
  none
}

#let render(site: (:), page: (:), pages: (), taxonomies: (:), body) = context {
  if target() == "html" {
    html.elem("html", attrs: (lang: page.lang))[
      #head(site, page.title, description: page.description, canonical: page.url)
      #html.elem("body", attrs: (class: "docs-body"))[
        #header(site, show-menu: false)
        #html.elem("main", attrs: (id: "main-content", class: "page-shell"))[
          #html.elem("article", attrs: (class: "page-content"))[
            #html.elem("header", attrs: (class: "page-header"))[
              #html.elem("p", attrs: (class: "eyebrow"))[#if page.section == "pages" { "Page" } else { page.section }]
              #html.elem("h1")[#page.title]
              #if page.description != none {
                html.elem("p", attrs: (class: "lead"))[#page.description]
              }
            ]
            #_toc(page)
            #html.elem("div", attrs: (class: "prose"))[#body]
          ]
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
