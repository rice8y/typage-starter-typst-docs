// Typage reads this file as collection schema metadata.
// The schema identifiers are Typage built-ins and do not need imports.
#let collections = (
  pages: collection.with(schema: (
    title: str,
    description: optional(str),
    template: optional(str),
    weight: optional(int),
    package_name: optional(str),
    package_version: optional(str),
    package_license: optional(str),
    package_repository: optional(str),
    package_entrypoint: optional(str),
  )),
)
