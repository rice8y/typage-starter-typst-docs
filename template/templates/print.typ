#let render(site: (:), document: (:), pages: ()) = {
  set document(title: document.title)
  [= #document.title]

  if document.description != none [
    #document.description
  ]

  for page in pages [
    #page.body
  ]
}
