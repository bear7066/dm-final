// Section jumps, shared by every kit (from jev-experiment-backup-10-13).
// The Contents marks itself; each section page carries a key. A contents entry links to its section
// and shows that page's number, and every section slide links back to the Contents.
// Targets are found with query, so a missing key or Contents leaves plain text instead of an error.

#let _nav-at(key) = {
  let hits = query(metadata).filter(m => m.value == "nav:" + key)
  if hits.len() > 0 { hits.first().location() }
}

// Mark a jump target: section-slide(key: ...) does this itself; use it directly for any other page.
#let section-mark(key) = metadata("nav:" + key)
#let contents-mark = section-mark("contents")

#let nav-link(key, body) = context {
  let at = _nav-at(key)
  if at == none { body } else { link(at, body) }
}

#let nav-page(key) = context {
  let at = _nav-at(key)
  if at == none [–] else [#counter(page).at(at).first()]
}

// Contents entries: (name, page) like a hand-written item, both linked to section `key`.
// A sub-entry carries a third element (true): kits draw it smaller and indented under its chapter.
#let chapter-entry(key, name) = (nav-link(key, name), nav-link(key, nav-page(key)))
#let sub-entry(key, name) = (..chapter-entry(key, name), true)
#let _is-sub(item) = type(item) == array and item.len() > 2 and item.at(2) == true

#let back-to-contents(body) = nav-link("contents", body)
