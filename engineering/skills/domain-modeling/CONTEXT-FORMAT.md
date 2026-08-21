# CONTEXT.md Format

`CONTEXT.md` lives at the repo root. It is the one file where a person or a skill can
look up what this project calls things, without reading code to find out.

## Shape

```markdown
# <Project Name> — Domain Context

<One line: what this project's domain is, in the words its own team uses for it —
not a restatement of the tech stack.>

| Term | Meaning | Where in code |
|------|---------|----------------|
| <Term> | <What it means in this project, one or two sentences> | <Module, class, or file where the term is the primary, authoritative name> |
```

Keep the purpose line to one sentence. It orients a reader before they hit the table, not
after — someone opening this file for the first time should know what the project is about
before they know what any single term means.

Each glossary row is one term. `Meaning` is the definition as this project actually uses
it, not a dictionary definition — if "order" means something narrower or stranger here
than it does in general use, that's exactly what the row exists to capture. `Where in
code` points at the one place the term is authoritative, not everywhere it happens to be
mentioned — the type, module, or file a reader should open if they want the term's real,
current shape.

## How to keep it current

A glossary that drifts from the code is worse than no glossary at all — it actively
misleads instead of just staying silent. Update the row at the same time the code changes,
not on a later pass: when a rename lands, when a term's meaning narrows or splits into
two, when a term that used to matter stops being used anywhere. If a row's `Where in code`
pointer no longer resolves, that row is due for a look before anyone trusts it again.
